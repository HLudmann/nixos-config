{
  inputs = {
    system-nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    system-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = inputs: {
    nixosConfigurations.muriel = import ./hosts/muriel inputs;
    nixosConfigurations.yushamin = import ./hosts/yushamin inputs;
  };
}
