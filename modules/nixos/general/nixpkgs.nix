{ lib, ... }:

with lib;

let

  pinnedNixpkgs = import ../../../external/nixpkgs-stable.nix {};
  pinnedNUR = import ../../../external/nur.nix;
  pinnedKalbasitNUR = import ../../../external/kalbasit-nur.nix;

in {
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      nur = recursiveUpdate
        (import pinnedNUR { inherit pkgs; })
        ({
          repos = {
            kalbasit = import pinnedKalbasitNUR { inherit pkgs; };
          };
        });
    };
  };

  nixpkgs.overlays = import ../../../overlays;

  # TODO: This is not working!!
  system.activationScripts = {
    nixpkgsPin = {
      text = ''
        ln -sfn ${pinnedNixpkgs} /etc/nixpkgs
      '';
      deps = [];
    };
  };
}
