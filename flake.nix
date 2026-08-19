{
  description = "Hyprland desktop configuration, managed with home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Change these two on a new machine, or add a second entry below.
      username = "ruben-alexander";
      homeDirectory = "/home/${username}";
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit username homeDirectory; };
        modules = [ ./nix/home.nix ];
      };

      # Lets you run `nix develop` to get home-manager without installing it.
      devShells.${system}.default = pkgs.mkShell {
        packages = [ home-manager.packages.${system}.default ];
      };
    };
}
