with import <nixpkgs> {};
with lib;

let
  bin = "${import ./bin.nix}/bin/blurtrans";
in

{ filea ? ./a.png
, fileb ? ./b.png
, resolution ? "1440x900"
, stepcount ? 30
, blurfactor ? 20
, blurquality ? 2
}:
runCommand "blurtrans-${toString
resolution}-${toString stepcount}" {} ''
  
  ${bin} ${filea} ${fileb} $out ${resolution} \
    ${toString stepcount} ${toString blurfactor} ${toString blurquality}

''
