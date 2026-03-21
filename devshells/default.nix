{ pkgs ? import <nixpkgs> {} }:

# This folder holds all your development shell environments.
# They are essentially normal shell.nix files that Flake reads.

{
  ds = import ./ds.nix { inherit pkgs; };
  web = import ./web.nix { inherit pkgs; };
}
