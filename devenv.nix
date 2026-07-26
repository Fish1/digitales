{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  base = pkgs.appimageTools.defaultFhsEnvArgs;
  fhs = pkgs.buildFHSEnv (
    base
    // {
      name = "fhs";
      targetPkgs =
        pkgs:
        (base.targetPkgs pkgs)
        ++ (with pkgs; [
          python3
          libz
        ]);
      profile = "export FHS=1";
      runScript = "fish";
    }
  );
in
{
  env = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.alsa-lib
    ];
  };

  packages = [
    fhs
    pkgs.git
    pkgs.libGL
    pkgs.wayland-scanner
    pkgs.wayland
    pkgs.libxkbcommon
  ];

  languages = {
    zig.enable = true;
  };

  scripts.welcome.exec = ''
    echo ENV: Zig / Raylib
    echo GIT: $(git --version)
    echo ZIG: $(zig version)
  '';

  enterShell = ''
    welcome
  '';

  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';
}
