{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Languages
    nodejs_22
    bun
    python313Packages.pip
    racket
    sbcl
    
    # IDEs
    jetbrains.pycharm
    vscode
    
    # Dev Tools
    vulkan-loader
    ollama
    typst
  ];
}