{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.shabka.fzf;
in {
  options.shabka.fzf.enable = mkEnableOption "Enable fzf - a command-line fuzzy finder.";

  config.programs.fzf = mkIf cfg.enable {
    enable = true;
    defaultCommand = ''(${pkgs.git}/bin/git ls-tree -r --name-only HEAD || ${pkgs.silver-searcher}/bin/ag --hidden --ignore .git -g "")'';
  };
}
