{ system-nixpkgs, nixos-hardware, ... }:

system-nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
  ];
}
