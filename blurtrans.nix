with import <nixpkgs> {};
with lib;

let
  bin = "${import ./bin.nix}/bin/blurtrans";
in

{ filea ? ./a.png
, fileb ? ./b.png
, resolution ? "1440x900"
, stepcount ? 1
, blurfactor ? 1
, blurquality ? 2
}:
runCommand "blurtrans-${toString resolution}-${toString stepcount}" {} ''

  tmp=$(mktemp -d)
  ${bin} ${filea} ${fileb} $tmp ${resolution} \
    ${toString stepcount} ${toString blurfactor} ${toString blurquality}

  ${ffmpeg}/bin/ffmpeg -r 20 -f image2 -s ${resolution} \
    -i $tmp/%02d.png -vcodec libx264 -crf 15  -pix_fmt yuv420p -f mp4 $out
''
