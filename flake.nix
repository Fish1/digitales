{
  description = "digitales";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    zigflake.url = "github:silversquirl/zig-flake/compat";
    zlsflake.url = "github:zigtools/zls";

    zigflake.inputs.nixpkgs.follows = "nixpkgs";
    zlsflake.inputs.nixpkgs.follows = "nixpkgs";
    zlsflake.inputs.zig-overlay.follows = "zigflake";
  };

  outputs =
    {
      self,
      nixpkgs,
      zigflake,
      zlsflake,
    }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      zig = zigflake.packages.x86_64-linux."0.16.0";
      # zls = zlsflake.packages.x86_64-linux.zls;

      defaultFhsEnvArgs = pkgs.appimageTools.defaultFhsEnvArgs;

      fhs = pkgs.buildFHSEnv (
        defaultFhsEnvArgs
        // {
          name = "fhs";
          targetPkgs =
            pkgs:
            (defaultFhsEnvArgs.targetPkgs pkgs)
            ++ [
              pkgs.python3
              pkgs.libz
            ];
          profile = "export FHS=1";
          runScript = "fish";
        }
      );
    in
    {
      packages.x86_64-linux = {
        default = zig.makePackage {
          pname = "digitales";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [
            fhs
            zig
            pkgs.zls
            pkgs.libGL
            pkgs.wayland-scanner
            pkgs.wayland
            pkgs.libxkbcommon
          ];
          zigReleaseMode = "fast";
          # buildPhase = ''
          #  						export ZIG_GLOBAL_CACHE_DIR=$out
          #  						zigBuildPhase()
          #  					'';
          # installPhase = ''
          #   											mkdir -p $out/bin
          #  											cp ./zig-out/bin/raylib $out/bin
          #  										'';
          # depsHash = "sha256-3vxgOZT4XYckGYd9jJC6zF2odptDlCUg/UQ5AeSNesA=";
        };
      };

      devShells.x86_64-linux = {
        default = pkgs.mkShell {
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.alsa-lib
          ];
          packages = [
            fhs
            zig
            pkgs.zls
            pkgs.libGL
            pkgs.wayland-scanner
            pkgs.wayland
            pkgs.libxkbcommon
          ];
        };
      };
    };
}
