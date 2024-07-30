topLevel: board: family: device: cst: {
  synth = ''
    mkdir -p ./board/${board}
    # synthesizing for the gowin boards
    yosys -p 'read_json ./${topLevel}.json; synth_gowin -json ./board/${board}/${topLevel}.json'
  '';
  route = ''
    # routing based on the device, family, and the cst file
    nextpnr-gowin --json ./board/${board}/${topLevel}.json \
                  --write ./board/${board}/pnr${topLevel}.json \
                  --family ${family} \
                  --device ${device} \
                  --cst ${cst}
  '';
  pack = ''
    #packaging for the board
    gowin_pack -d ${family} -o ./board/${board}/${topLevel}.fs \
                ./board/${board}/pnr${topLevel}.json
  '';
  install = ''
    mkdir -p $out/board/${board}
    cp ./board/${board}/${topLevel}.fs $out/board/${board}/${topLevel}.fs
  '';
  loader.sram = ''
    openFPGALoader -b ${board} ./${topLevel}.fs
  '';
  loader.flash = ''
    openFPGALoader -b ${board} -f ./${topLevel}.fs
  '';
}
