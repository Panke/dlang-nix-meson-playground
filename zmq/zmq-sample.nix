{pkgs, dub ? pkgs.dub, stdenv ? pkgs.stdenv, dcompiler ? pkgs.ldc}:
with (import ./mkDubDependencies.nix {
    inherit pkgs dcompiler dub;
});
let 
    deps = mkDubDependenciesDrv {
        inherit (pkgs dcompiler);
        src = ./dub.selections.nix;
        version = "0.0.1";
        name = "dub2nix-deps";
    };
in
stdenv.mkDerivation {
    name = "zmq-sample";
    version = "1.0.0";
    src = ./.;
    nativeBuildInputs = [ pkgs.zeromq dcompiler dub deps];
    buildPhase = ''
        echo BUILD YEAH: $out
	mkdir $out
        HOME=$NIX_BUILD_TOP dub --skip-registry=all describe > $out/dub
    '';
    dontInstall = true;
}
