{ pkgs ? import <nixpkgs> {} }:
let meson = pkgs.meson_0_60.overrideAttrs (
  oldAttrs: rec {
    src = ./meson;
  }
);
dub2nix = import  ./dub2nix {};
in
pkgs.mkShell {
  nativeBuildInputs = [ pkgs.dub pkgs.ldc pkgs.meson_0_60 pkgs.zeromq pkgs.pkg-config pkgs.ninja pkgs.nix-prefetch-git dub2nix ];
}

