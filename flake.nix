{
  description = "Hyprland desktop configuration, managed with home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixgl, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # These two are the only values that differ between machines. They are
      # read with --impure so one output serves every user:
      #
      #   nix run .#home-manager -- switch --flake .#default --impure
      #
      # Without --impure the fallback is used, which keeps `nix flake check`
      # pure. Every package still comes from flake.lock; only the account
      # name and home directory come from the environment.
      env = name: fallback:
        let value = builtins.getEnv name;
        in if value == "" then fallback else value;

      username = env "USER" "ruben";
      homeDirectory = env "HOME" "/home/${username}";

      hm = home-manager.packages.${system}.home-manager;

      home = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit username homeDirectory nixgl; };
        modules = [ ./nix/home.nix ];
      };
    in
    {
      # `nix run .#home-manager` uses the home-manager revision in flake.lock,
      # not whatever `master` is on the day you run it.
      apps.${system} = {
        home-manager = {
          type = "app";
          program = "${hm}/bin/home-manager";
        };
        default = {
          type = "app";
          program = "${hm}/bin/home-manager";
        };
      };

      # One configuration for VM, laptop and desktop. The differences are
      # username/homeDirectory, supplied by the environment; nothing else.
      homeConfigurations.default = home;

      devShells.${system}.default = pkgs.mkShell {
        packages = [ home-manager.packages.${system}.default ];
      };
    };
}
