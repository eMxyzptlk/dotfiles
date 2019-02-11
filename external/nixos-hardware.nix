{ fetchpatch, runCommand }:

let
  pinnedVersion = builtins.fromJSON (builtins.readFile ./nixos-hardware-version.json);
  pinned = builtins.fetchTarball {
    inherit (pinnedVersion) url sha256;
  };

  patches = [];

  patched = runCommand "nixos-hardware-${pinnedVersion.rev}"
    {
      inherit pinned patches;

      preferLocalBuild = true;
    }
    ''
      cp -r $pinned $out
      chmod -R +w $out
      for p in $patches; do
        echo "Applying patch $p";
        patch -d $out -p1 < "$p";
      done
    '';

in
  patched
