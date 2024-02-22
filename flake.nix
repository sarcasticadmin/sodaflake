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
        cola = let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
          # ignore the first three and last lines of config.nix to include in image
          # TODO: Make this less of a hack
          truncConfig = pkgs.runCommand "truncate"
          {
            buildInputs = [ pkgs.util-linux pkgs.coreutils-full ];
          }
          ''
            mkdir $out
            awk 'NR>3' ${./config.nix} | head -n -1 > $out/config
          '';
          eConfig = (builtins.readFile "${truncConfig}/config");
        in
          nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # always for us to include a /etc/nixos/configuration.nix
            ({ config, pkgs, ... }: { installer.cloneConfigExtra = eConfig ; })
            "${nixpkgs}/nixos/modules/profiles/clone-config.nix"
            "${nixpkgs}/nixos/modules/virtualisation/kubevirt.nix"
            ./config.nix
          ];
        };
      };
    };
}
