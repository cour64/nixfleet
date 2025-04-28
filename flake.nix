{
  description = "Brendans nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nix-homebrew, nixpkgs, ... }:
    {
      darwinConfigurations = {
        workmac = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; username = "brendan"; };
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            ./hosts/workmac.nix
          ];
        };
      };
      nixosConfigurations = {
        devbox = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; username = "brendan"; };
          system = "aarch64-linux";
          modules = [
            ./hosts/devbox-vmware/configuration.nix
          ];
        };
      };
    };
}
