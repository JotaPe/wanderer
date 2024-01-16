{
  description = "Star Sailor";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gomod2nix.url = "github:nix-community/gomod2nix";
  };

  outputs = { self, nixpkgs, flake-utils, gomod2nix }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ gomod2nix.overlays.default ];
        };
      in rec {
        packages.starsail = pkgs.buildGoApplication {
          pname = "wanderer.starsail";
          version = "0.1.0";
          pwd = ./starsail/.;
          src = ./starsail/.;
          subPackages = [ "." ];
          allowGoReference = true;
          modules = ./starsail/gomod2nix.toml;
        };

        packages.containerStarsail = pkgs.dockerTools.buildImage {
          name = "wanderer.starsail";
          tag = "0.1.0";
          created = "now";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [packages.wanderer];
            pathsToLink = ["/bin"];
          };
          config = {
            Cmd = ["${packages.wanderer}/bin/wanderer.starsail"];
            ExposedPorts = {"80/tcp" = { }; "443/tcp" = { }; };
          };
        };

        devShell = pkgs.mkShell {
          packages = with pkgs; [
            git
            jq
            nixpkgs-fmt
            go
            pkgs.gomod2nix
            gopls
            delve
          ];
          shellHook = ''
          export DEV=1
          '';
        };
      }
    );
}
