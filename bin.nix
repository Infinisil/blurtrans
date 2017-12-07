with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "blurtrans";

  src = lib.cleanSource ./.;

  magick = imagemagick7Big;
  zsh = "${zsh}/bin/zsh";
  bc = bc;

  buildPhase = ''
    substituteInPlace blurtrans \
      --subst-var magick \
      --subst-var zsh \
      --subst-var bc
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp blurtrans $out/bin
  '';
}
