{ pkgs ? import <nixpkgs> {} }:
let dub = (pkgs.dub.overrideAttrs (oldAttrs: rec {
    src = builtins.path { path= /home/tobias/dlang/dub; name = "source"; };
    doCheck = true;
  }))
.override { dcompiler = pkgs.dmd; };
in
pkgs.callPackage ./zmq-sample.nix { dub = dub; dcompiler = pkgs.dmd; }
