{ pkgs }:

# Web freelancing stack
pkgs.mkShell {
  packages = with pkgs; [
    nodejs_22
    bun
    git
    just
  ];
}
