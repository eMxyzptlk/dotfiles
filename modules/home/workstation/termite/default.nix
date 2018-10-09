{ config, pkgs, lib, ... }:

with lib;

{
  options.mine.workstation.termite.enable = mkEnableOption "workstation.termite";

  config = mkIf config.mine.workstation.termite.enable {
    programs.termite = {
      enable = true;
      font = "SourceCodePro Regular 9";

      backgroundColor = "#3a3a3a";
      foregroundColor = "#d0d0d0";
      colorsExtra = ''
        color0     = #4e4e4e
        color10    = #87af87
        color11    = #ffd787
        color12    = #add4fb
        color13    = #ffafaf
        color14    = #87d7d7
        color15    = #e4e4e4
        color1     = #d68787
        color2     = #5f865f
        color3     = #d8af5f
        color4     = #85add4
        color5     = #d7afaf
        color6     = #87afaf
        color7     = #d0d0d0
        color8     = #626262
        color9     = #d75f87
      '';
    };
  };
}
