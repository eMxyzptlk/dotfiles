{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.mine.neovim;

in {
  options.mine.neovim = {
    enable = mkEnableOption "neovim";

    extraRC = mkOption {
      type = types.str;
      default = "";
      description = ''
        Extra NeoVim init configuration.
      '';
    };

    extraKnownPlugins = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Extra NeoVim known plugins.
      '';
    };

    extraPluginDictionaries = mkOption {
      type = with types; listOf attrs;
      default = [];
      description = ''
        Extra NeoVim plugin dictionary.
      '';
    };

    keyboardLayout = mkOption {
      type = types.enum [ "colemak" "qwerty" ];
      default = if config.mine.useColemakKeyboardLayout then "colemak" else "qwerty";
      description = ''
        The keyboard layout to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = mkMerge [
      (import ../../../neovim {
        inherit lib pkgs;

        config.shabka.neovim = {
          inherit (cfg) enable extraRC extraKnownPlugins extraPluginDictionaries keyboardLayout;
        };
      }).config

      { enable = true; }
    ];
  };
}
