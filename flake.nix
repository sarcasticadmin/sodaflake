{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs =
    { self
    , nixpkgs
    }@inputs: {
      packages.x86_64-linux = {
        colaImage = (self.nixosConfigurations.cola.config.system.build.kubevirtImage);
      };

      nixosConfigurations = {
        cola = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/virtualisation/kubevirt.nix"
            ./config.nix
          ];
        };
      };
    };
}
