/*
*/
{ pkgs ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv,
  lib ? pkgs.lib,
  dcompiler ? pkgs.ldc,
  dub ? pkgs.dub,
}:

with stdenv;
let
  dep2pair = dubDep: { zip = pkgs.fetchurl { inherit (dubDep.fetch) url name sha256; }; name = dupDep.fetch.name; };
  dep2zip = dubDep: (dep2pair dubDep).zip;

  # The target output of the Dub package
  targetOf = package: "${package.targetPath or "."}/${package.targetName or package.name}";

in {
  mkDubDependenciesDrv = lib.makeOverridable ({
      src, /* a dub.selections.nix file */
      name,
      version,
      nativeBuildInputs ? [],
      passthru ? {},
      ...
    } @ attrs: 
    let 
      selections = import(src);
    in stdenv.mkDerivation {
      dontUnpack = true;
      nativeBuildInputs = nativeBuildInputs ++ [dcompiler dub];
      dubzips = builtins.map dep2zip selections.packages;
      targetnames = builtins.map (x: x.name) selections.targets;
      inherit name version;
      buildPhase = ''
        runHook preBuild
        echo "DEPENDENT PACKAGE"
        mkdir -p deps
        echo DUBZIPS: $dubzips
        for x in $dubzips; do
          fn=$(basename $x)
          pkgname=''${fn:33}
          cp "$x" deps/$pkgname
        done
        chmod -R u+rw deps
        export HOME=$NIX_BUILD_TOP

        dub list --skip-registry=configured --registry=file://deps
        echo "DUB DEP BUILD"
        for target in "$targetnames"; do
          dub build -b release --skip-registry=configured "$target" --registry=file://deps
        done
        dub list --skip-registry=configured --registry=file://deps
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/
        cp -r .dub/packages/* $out/
        mkdir -p $out/nix-support
        echo "mkdir -p \$NIX_BUILD_TOP/.dub/packages" > $out/nix-support/setup-hook
        echo "(cd .dub/packages/; for x in \$(ls @out@); do ln -s @out@/\$x \$x; done;)" >> $out/nix-support/setup-hook
        sed -i -e "s|@out@|$out|g" $out/nix-support/setup-hook
        cat $out/nix*/setup*
	echo $out
        runHook postInstall
      '';
    }
  );
}
