self: super:

{
  sway-config        = self.callPackage ./sway-config {};
  task-config        = self.callPackage ./task-config {};
  termite-config     = self.callPackage ./termite-config {};
  tmux-config        = self.callPackage ./tmux-config {};
  zsh-config         = self.callPackage ./zsh-config {};
}
