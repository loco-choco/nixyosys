{ fetchFromGitHub, buildVHDLYosys }:
# TODO maybe we can generalize for both vhdl and verilog? for now ghdl only
buildVHDLYosys {
  pname = "vhdl-adder";
  version = "0-unstable-2024-07-17";
  src = fetchFromGitHub {
    owner = "loco-choco";
    repo = "ghdl-project-template";
    rev = "03a1c612e71c5d7ee19ac513c713de2dc74cc632";
    hash = "sha256-13HMIHx85cMrLWJM8wn7MY7e4ury3OTr+tx1slMs/A4="; 
  };

  work = "work";
  std = "93";
  topLevel = "adder";
  files = [ "src/*.vhdl" ];
  # optional if you want to add more yosys steps in the middle of the synthesis
  # can also be a file
  #yosysSynthesisCommands = ''
  #  
  #'';

  boards = {
    tangprimer20k = {
      #family = "GW2A-18"; # for known board, optional
      #device = "GW2A-LV18PG256C8/I7"; # for known board, optional
      # either in plain text, or path to file
      #cst = ./adder/cst/tangprimer20k.cst;

      cst = ''
        IO_LOC "i0" D7;
        IO_LOC "i1" T2;
        IO_LOC "ci" T10;
        IO_LOC "s"  L14;
        IO_LOC "co" L16;
      '';

      #name of option WIP
      #synthesizer = "gowin"; # for known board, optional, chooses the synthesizer, router, packer and the upload method for the board
    };
  };
}
