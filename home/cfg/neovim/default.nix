{ pkgs, ... }:

let
  my_plugins = import ./plugins.nix { inherit (pkgs) vimUtils fetchFromGitHub stdenv;  };
in {
  programs.neovim = {
    enable = true;

    withPython = true;
    extraPythonPackages = [pkgs.python27Packages.neovim];

    withPython3 = true;
    extraPython3Packages = [pkgs.python36Packages.neovim];

    configure = {
      customRC = builtins.readFile (pkgs.substituteAll {
        src = ./init.vim;

        gocode_bin = "${pkgs.gocode}/bin/gocode";
        neovim_node_host_bin = "${pkgs.nodePackages.neovim}/bin/neovim-node-host";
        typescript_server_bin = "${pkgs.nodePackages.typescript}/bin/tsserver";
        xsel_bin = "${pkgs.xsel}/bin/xsel";
      });

      vam.knownPlugins = pkgs.vimPlugins // my_plugins;
      vam.pluginDictionaries = [
        {
          names = [ # vimPlugins
            "Gist"
            "Gundo"
            "LanguageClient-neovim"
            "ack-vim"
            "ale"
            "auto-pairs"
            "caw"
            "easy-align"
            "easymotion"
            "editorconfig-vim"
            "fugitive"
            "fzf-vim"
            "fzfWrapper"
            "multiple-cursors"
            "nvim-completion-manager"
            "polyglot"
            "repeat"
            "rhubarb"
            "sleuth"
            "surround"
            "vim-airline"
            "vim-airline-themes"
            "vim-eunuch"
            "vim-go"
            "vim-markdown"
            "vim-signify"
            "vim-speeddating"

            ## DeoPlete completion support
            "deoplete-nvim"

            # Golang support
            "deoplete-go"

            # required by Gist
            # TODO: https://github.com/NixOS/nixpkgs/pull/43399
            "webapi-vim"

            "vim-maktaba"
            "vim-bazel"
          ] ++ [ # my_plugins
            "airline-seoul256-theme"
            "vim-PreserveNoEOL"
            "vim-better-whitespace"
            "vim-colemak"
            "vim-color-seoul256"
            "vim-csv"
            "vim-emmet"
            "vim-pig"
            "vim-terraform"
            "vim-vissort"
            "vim-zoomwintab"

            # Typescript support
            # "vim-typescript"    # TODO: https://github.com/kalbasit/dotfiles/issues/15
            "vim-yats"
          ];
        }
      ];
    };
  };
}
