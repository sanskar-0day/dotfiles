{
  description = "NixOS Configuration";

  inputs = {
    # NixOS 25.11 (Stable)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # NixOS Unstable (for specific packages)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager for user-space config
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs pkgs-unstable; };
      modules = [
        # 1. Import the Main Host Config
        ./hosts/nixos/default.nix

        # 2. Inject Home Manager as a NixOS Module
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.sanskar = import ./home/sanskar;
          
          # Pass pkgs-unstable to home-manager
          home-manager.extraSpecialArgs = { inherit inputs pkgs-unstable; };
        }
      ];
    };
  };
}