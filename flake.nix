{
  description = "Nixified HDL Workflow";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlay = final: prev: {
          buildVHDLYosys = final.pkgs.callPackage ./lib/buildVHDLYosys.nix { };
          adder = final.pkgs.callPackage ./example/adder.nix { };
        };
        pkgs = (import nixpkgs) {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        inherit overlay;
        packages = {
          adder = pkgs.adder;
        };
      }
    );
}
