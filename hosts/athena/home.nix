{
  imports = [
    ../../modules/home
  ];

  # TODO: getting an error that this is only compatible with systemd. A port to launchd is probably what I need.
  # mine.gnupg.enable = true;

  # TODO: plug nix-darwin here
  mine.darwinConfig = { todo = "me"; };

  mine.git.enable = true;
  mine.less.enable = true;
  mine.neovim.enable = true;
  mine.pet.enable = true;
  mine.taskwarrior.enable = true;
  mine.timewarrior.enable = true;
  mine.tmux.enable = true;
  mine.useColemakKeyboardLayout = true;
}
