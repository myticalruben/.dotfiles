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

      # The account inside the test VM. Separate from `username` so the two
      # never have to be the same machine's.
      vmUsername = "ruben";

      # The two configurations below differ only in the arguments they pass,
      # so they cannot drift apart: same modules, same package set, same lock.
      mkHome = args: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit username homeDirectory;
          # The conservative defaults live here, not as `? ` defaults in the
          # module: an argument the module system has to look up in
          # `_module.args` needs `config`, and that is a cycle once the flag
          # decides an option feeding home.file.
          mutableConfigs = true;
          compositorFromNix = false;
        } // args;
        modules = [ ./nix/home.nix ];
      };
    in
    {
      homeConfigurations = {
        # The daily machine. Hyprland still comes from Ubuntu, and the config
        # directories stay symlinked to the checkout so they remain editable.
        ${username} = mkHome { };

        # The VM. Everything comes from Nix, including the compositor, and
        # nothing is editable in place: if this one boots, it boots from the
        # flake alone. That is the claim the VM exists to test.
        #
        # Change vmUsername above if the account inside the VM is not `ruben`;
        # nix/vm/bootstrap.sh checks it and stops early rather than letting
        # home-manager fail halfway through activation.
        vm = mkHome {
          username = vmUsername;
          homeDirectory = "/home/${vmUsername}";
          mutableConfigs = false;
          compositorFromNix = true;
        };
      };

      # Lets you run `nix develop` to get home-manager without installing it.
      devShells.${system}.default = pkgs.mkShell {
        packages = [ home-manager.packages.${system}.default ];
      };
    };
}
