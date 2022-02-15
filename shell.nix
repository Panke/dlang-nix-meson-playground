{ pkgs ? import <nixpkgs> {} }:
let meson = pkgs.meson_0_60.overrideAttrs (
  oldAttrs: rec {
    src = ./meson;
  }
);
#dub2nix = import  ./dub2nix {};
dub = pkgs.dub.overrideAttrs (
  oldAttrs: rec {
    src = builtins.path { path= ../dub; name = "source"; };
    doCheck = false;
  }
);
in
pkgs.mkShell {
  nativeBuildInputs = [ dub pkgs.ldc pkgs.meson_0_60 pkgs.zeromq pkgs.pkg-config pkgs.ninja ];
}

