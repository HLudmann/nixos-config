{
  system-nixpkgs,
  system-unstable,
  nixos-hardware,
  sops-nix,
  ...
}: let
  system = "x86_64-linux";
in
  system-nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      ./configuration.nix
      sops-nix.nixosModules.sops
      (_: {
        _module.args = {
          unstablePkgs = system-unstable.legacyPackages.${system};
          unstableSys = system-unstable;
        };
      })
    ];
  }
