{ assertMsg
, pkgs
}:

with pkgs;
with pkgs.lib;

let
  pinnedVersion = builtins.fromJSON (builtins.readFile ./home-manager-version.json);
  pinned = builtins.fetchGit {
    inherit (pinnedVersion) url rev;
  };

  importPinned = import pinned {};

  mkAssertMsg = name: "${name} is available upsteam, kill this patch";

  patches = [
    # https://github.com/rycee/home-manager/pull/474
    (
      pkgs.fetchpatch {
        url = "https://github.com/rycee/home-manager/pull/474.patch";
        sha256 = "01rnl2c9k3kx0s33ap81p02ijjxciak2y1cvl553i45xx4g8siw1";
      }
    )
  ];

  patched = runCommand "home-manager-${pinnedVersion.rev}"
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
