#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

rm -f node-env.nix
node2nix -8 -i node-packages-v8.json -o node-packages-v8.nix -c composition-v8.nix
