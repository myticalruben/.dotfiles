{
  description = "Hyprland desktop configuration, managed with home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Wraps GPU-touching programs so they use the host's drivers instead of
    # nixpkgs' Mesa. Needed on any non-NixOS machine; see nix/README.md.
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixgl, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nixgl.overlay ];
      };

      # Change these two on a new machine, or add a second entry below.
      username = "ruben";
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
