{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin"];

      perSystem = {system, ...}: let
        overlays = [inputs.rust-overlay.overlays.default];
        pkgs = import inputs.nixpkgs {
          inherit system overlays;
        };

        rustToolchain = (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml).override {
          extensions = ["rust-src"];
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs;
            [
              xorg.libX11
              xorg.libXcursor
              xorg.libXi
              libxkbcommon
              xorg.libxcb
              libGL
              pango
              gdk-pixbuf
              gdk-pixbuf-xlib
              gtk3
              wayland
              wayland-protocols
              wayland-scanner
              openssl
              perl
              cmake
              pkg-config
              sqlite
              alsa-lib
            ]
            ++ [rustToolchain];

          packages = with pkgs; [
            gdb
            python3
          ];

          LD_LIBRARY_PATH = with pkgs;
            pkgs.lib.makeLibraryPath [
              libxkbcommon
              libGL
              wayland
            ];

          shellHook = ''
            export PS1="(env:shell) $PS1"
          '';
        };
      };
    };
}
