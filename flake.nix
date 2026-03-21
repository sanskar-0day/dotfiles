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

    # Nix-index database for faster package searching
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plasma manager for declarative KDE settings
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-index-database,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs unstable; };
        modules = [
          # 1. Import the Main Host Config
          ./hosts/nixos/default.nix

          # 2. Inject Home Manager as a NixOS Module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.sanskar = import ./home/sanskar;

            # Pass pkgs-unstable to home-manager
            home-manager.extraSpecialArgs = { inherit inputs unstable; };
            # Add plasma-manager as a shared module
            home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
          }

          # 3. Nix-index database for faster package searching
          nix-index-database.nixosModules.nix-index
          {
            programs.nix-index-database.comma.enable = true;
          }
        ];
      };

      # Standalone Home Manager (for non-NixOS or quick user rebuilds)
      homeConfigurations.sanskar = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs unstable; };
        modules = [
          ./home/sanskar
          nix-index-database.homeModules.nix-index
          inputs.plasma-manager.homeModules.plasma-manager
        ];
      };

      # ── Packages ────────────────────────────────────────────────
      # `nix build .#docs` — generates a Typst PDF from live config
      packages.${system}.docs = import ./docs/builder.nix {
        inherit (pkgs) lib runCommand typst;
      };

      # ── Development Shells (Project Stacks) ─────────────────────
      # Access via `nix develop .#<name>`
      devShells.${system} = import ./devshells/default.nix { inherit pkgs; };

      # ── Automated Checks ────────────────────────────────────────
      # `nix flake check` — verifies the config builds before deploying
      checks.${system}.nixos-config = self.nixosConfigurations.nixos.config.system.build.toplevel;
    };
}
