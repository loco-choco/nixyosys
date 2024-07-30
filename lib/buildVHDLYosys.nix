{
  stdenv,
  ghdl,
  yosys,
  nextpnr,
  python312Packages,
  openfpgaloader,
}:
{
  src,
  name ? "${attrs.pname}-${attrs.version}",
  work ? "work",
  std,
  topLevel,
  files,
  ...
}@attrs:
let
  projFiles = builtins.concatStringsSep " " files;
  boardPackers = import ./boards.nix;
  boards = builtins.mapAttrs (
    name: value:
    let
      family = value.family or boardPackers.${name}.family;
      device = value.device or boardPackers.${name}.device;
      synthesizerName = value.synthesizer or boardPackers.${name}.synthesizer;
      cst = if builtins.isPath value.cst then value.cst else builtins.toFile "${name}.cst" value.cst;
    in
    boardPackers.synthesizers.${synthesizerName} topLevel name family device cst
  ) attrs.boards;
  concatBoardScripts =
    f:
    builtins.concatStringsSep "\n" (
      builtins.concatMap (board: f board boards.${board}) (builtins.attrNames boards)
    );
in
stdenv.mkDerivation {
  inherit name src;
  buildInputs = [
    ghdl
    (yosys.withPlugins [ yosys.allPlugins.ghdl ])
    nextpnr
    python312Packages.apycula
    openfpgaloader
  ];

  buildPhase =
    ''
      echo "VHDL Phase:"
      mkdir -p work
      # importing the project files in files
      ghdl -i --std=${std} --workdir=./work --work=${work} ${projFiles}
      # compiling the toplevel entity
      ghdl -m --std=${std} --workdir=./work --work=${work} ${topLevel}
      # synthesizing using yosys down to a hdl independent json
      cd work
      yosys -m ghdl -p 'ghdl ${topLevel}; prep -top ${topLevel}; write_json ../${topLevel}.json'
      cd ..
    ''
    + concatBoardScripts (
      name: board: [
        ''echo "${name} Packing"''
        board.synth
        board.route
        board.pack
      ]
    );
  installPhase =
    ''
      echo "VHDL Yosys synth install"
      mkdir -p $out/yosys
      cp ${topLevel}.json $out/yosys
    ''
    + concatBoardScripts (
      name: board: [
        ''echo "${name} Install"''
        board.install
        (builtins.concatStringsSep "\n" (
          map (script: ''
            echo "#!bin/bash" > $out/board/${name}/${script}.sh
            echo "cd $out" >> $out/board/${name}/${script}.sh
            printf "${boards.${name}.loader.${script}}" >> $out/board/${name}/${script}.sh
          '') (builtins.attrNames boards.${name}.loader)
        ))
      ]
    );
}
