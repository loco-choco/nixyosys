# Nixyosys (Name is WIP)
**Tools to be able to describe how to build HDL projects and load them to FPGAs using Yosys and Nix.**

This project aims to allow the usage of nix as a project builder for HDL projects, easing the use of dependencies and the routing/packing/loading for different FPGAs.

For now only VHDL projects are supported, using ghdl as the compiler, and only the gowin board _Tang Primer 20K_ has been added as a pre-defined board.

Check the example file in `/example/adder.nix` to see how one could call this builder, and run `nix build github:loco-choco/nixyosys#adder` to see the generated .json for Yosys in `result/yosys`, and the board specific scripts inside `result/board`.
