with import <nixpkgs> {};
with lib;
with builtins;

folder:

let
  steps = 30;

  defaultOptions = {
    resolution = "1440x900";
    stepcount = steps;
    blurfactor = 10;
    blurquality = 2;
  };

  files' = builtins.attrNames (builtins.readDir folder);

  files = take 8 files';

  combos' = fs: if length fs < 2 then [] else
    let
      h = head fs;
      t = tail fs;
      headcombos = map (e: [ h e ]) t;
      tailcombos = combos t;
    in
      headcombos ++ tailcombos;

  combos'' = fs: concatLists (flip map fs (a:
    flip map fs (b: [ a b ])
  ));

  blurtrans' = a: b:
    import ./blurtrans.nix ({
      filea = a;
      fileb = b;
    } // defaultOptions);

  blurtrans = a: b: let
    result = blurtrans' (min a b) (max a b);
  in if a < b then result else runCommand "mirrored" {} ''
    mkdir $out && cd $out
    for k in $(seq -f "%02g" 1 ${toString steps}); do
      j=$(printf "%02g" $((${toString steps} - "10#$k" + 1)))
      ln -vs ${result}/$k.png $j.png
    done
  '';

  combos = fs: genAttrs fs (a:
    genAttrs (filter (x: x != a) fs) (b:
      blurtrans "${folder}/${a}" "${folder}/${b}"
    )
  );

  comboresult = combos files;

  transitions = runCommand "combos-${baseNameOf folder}" {} ''
    mkdir $out && cd $out
      ${concatMapStringsSep "\n" (a: let
        v = comboresult.${a};
      in ''
        mkdir '${a}' && pushd '${a}'
        ${concatMapStringsSep "\n" (b: ''
          ln -s ${v.${b}} ${b}
        '') (attrNames v)}
        popd
      '') (attrNames comboresult)}
  '';

  script = writeScript "rantrans" ''
    #!${bash}/bin/bash

    cur=$(ls @out@/wallpapers | shuf | head -1)

    while true; do
      ${feh}/bin/feh --bg-fill "@out@/wallpapers/$cur"
      sleep ''${1:-10}

      next=$(ls "@out@/transitions/$cur" | shuf | head -1)
      for f in @out@/transitions/$next/$cur/*; do
        ${feh}/bin/feh --bg-fill "$f"
        sleep ''${2:-0.1}
      done
      cur="$next"
    done
  '';

  drv = runCommand "transitions-${baseNameOf folder}" {} ''
    mkdir $out
    ln -s ${transitions} $out/transitions
    mkdir $out/wallpapers
      ${concatMapStringsSep "\n" (f: ''
        ln -s "${folder}/${f}" "$out/wallpapers/${f}"
      '') files}

    mkdir $out/bin
    substitute ${script} $out/bin/rantrans --subst-var-by out $out
    chmod +x $out/bin/rantrans
  '';
in
  drv
