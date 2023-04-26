{
  inputs = {
    system-nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = inputs: {
    nixosConfigurations.muriel = import ./hosts/muriel inputs;
    nixosConfigurations.yushamin = import ./hosts/yushamin inputs;
  };
}
