{ config, pkgs, lib, ... }:

with lib;

let
  defaultModifier = "Mod4";
  secondModifier = "Shift";
  thirdModifier = "Mod1";
  nosid = "--no-startup-id";
  locker = "${getBin pkgs.xautolock}/bin/xautolock -locknow && sleep 1";

  hostName = if config.mine.nixosConfig != {} then config.mine.nixosConfig.networking.hostName else "";

  intMonitor =
    if hostName == "hades"
    then "eDP-1"
    else if hostName == "cratos"
    then "eDP1"
    else "";

  intMode =
    if hostName == "hades"
    then "1920x1080"
    else if hostName == "cratos"
    then "3200x1800"
    else "";

  intScale =
    if hostName == "hades"
    then "1x1"
    else if hostName == "cratos"
    then "0.6x0.6"
    else "";

  extMonitor =
    if hostName == "hades"
    then "DP-2"
    else if hostName == "cratos"
    then "DP1-2"
    else "";

  extMode = "3440x1440";

  jrnlEntry = pkgs.writeScript "jrnl-entry.sh" ''
    #!/usr/bin/env bash

    set -euo pipefail

    readonly current_workspace="$( ${getBin pkgs.i3}/bin/i3-msg -t get_workspaces | ${getBin pkgs.jq}/bin/jq -r '.[] | if .focused == true then .name else empty end'  )"
    readonly current_profile="$( echo "$current_workspace" | cut -d\@ -f1  )"
    readonly current_story="$( echo "$current_workspace" | cut -d\@ -f2  )"

    # create a temporary file for the jrnl entry
    jrnl_entry="$(mktemp)"
    trap "rm $jrnl_entry" EXIT

    cat <<EOF > "$jrnl_entry"
    # All lines starting with a hash sign are treated as comments and not added to the journal entry.
    # You are adding a journal entry for profile=$current_profile and story=$current_story
    # computed from the workspace $current_workspace

    @$current_story

    EOF

    # open a new terminal window with vim session inside of it to edit the jrnl entry
    readonly line_count="$(wc -l "$jrnl_entry" | awk '{print $1}')"
    ${getBin pkgs.termite}/bin/termite --title jrnl_entry --exec="nvim +$line_count +star -c 'set wrap' -c 'set textwidth=80' -c 'set fo+=t'" "$jrnl_entry"
    readonly content="$( grep -v '^#' "$jrnl_entry" )"

    ${getBin pkgs.jrnl}/bin/jrnl "$current_profile" "$content"
  '';

in {
  enable = true;

  config = {
    fonts = [ "pango:SourceCodePro Regular 8" ];

    window = {
      commands = [
        { command = "floating enable"; criteria = { workspace = "^studio$"; }; }

        { command = "floating enable"; criteria = { class = "^Arandr"; }; }
        { command = "floating enable"; criteria = { class = "^Pavucontrol"; }; }
        { command = "floating enable"; criteria = { class = "^ROX-Filer$"; }; }
        { command = "floating enable"; criteria = { class = "^SimpleScreenRecorder$"; }; }
        { command = "floating enable"; criteria = { class = "^Tor Browser"; }; }
        { command = "floating enable"; criteria = { class = "^net-filebot-Main$"; }; }
        { command = "floating enable"; criteria = { title = "^jrnl_entry$"; }; }

        { command = "sticky enable, floating enable, move scratchpad"; criteria = { class = "^whats-app-nativefier*"; }; }
        { command = "sticky enable, floating enable, move scratchpad"; criteria = { class = "astroid"; }; }
        { command = "sticky enable, floating enable, move scratchpad"; criteria = { class = "Ptask"; }; }
        { command = "sticky enable, floating enable, move scratchpad"; criteria = { class = "pulse-sms"; }; }
      ] ++ optionals config.mine.keybase.enable [
        { command = "sticky enable, floating enable, move scratchpad"; criteria = { class = "Keybase"; }; }
      ];
    };

    floating = { modifier = "${defaultModifier}"; };

    focus = {
      # focus should not follow the mouse pointer
      followMouse = false;

      # on window activation, just set the urgency hint. The default behavior is to
      # set the urgency hint if the window is not on the active workspace, and to
      # focus the window on an active workspace. It does surprise me sometimes and I
      # would like to keep it simple by having to manually switch to the urgent
      # window.
      newWindow="urgent";
    };

    assigns = {
      "charles"    = [{ class = "^com-xk72-charles-gui-.*$"; }];
      "discord"    = [{ class = "^discord$"; }];
      "slack"      = [{ class = "^Slack$"; }];
      "studio"     = [{ class = "^obs$"; }];
      "tor"        = [{ class = "^Tor Browser"; }];
      "virtualbox" = [{ class = "^VirtualBox"; }];
    };

    modifier  = "Mod4";

    keybindings = {
      # change focus
      "${defaultModifier}+n" = "focus left";
      "${defaultModifier}+e" = "focus down";
      "${defaultModifier}+i" = "focus up";
      "${defaultModifier}+o" = "focus right";

      # move focused window
      "${defaultModifier}+${secondModifier}+n" = "move left";
      "${defaultModifier}+${secondModifier}+e" = "move down";
      "${defaultModifier}+${secondModifier}+i" = "move up";
      "${defaultModifier}+${secondModifier}+o" = "move right";

      # split in horizontal orientation
      "${defaultModifier}+h" = "split h";

      # split in vertical orientation
      "${defaultModifier}+v" = "split v";

      # change focus between output
      "${defaultModifier}+${thirdModifier}+o" = "focus output right";
      "${defaultModifier}+${thirdModifier}+n" = "focus output left";

      # move workspaces between monitors
      "${defaultModifier}+${secondModifier}+${thirdModifier}+o" = "move workspace to output right";
      "${defaultModifier}+${secondModifier}+${thirdModifier}+n" = "move workspace to output left";

      # toggle sticky
      "${defaultModifier}+s" = "sticky toggle";

      # toggle tiling / floating
      "${thirdModifier}+${secondModifier}+space" = "floating toggle";

      # jrnl entry
      "${thirdModifier}+j" = "exec ${jrnlEntry}";

      # change focus between tiling / floating windows
      "${thirdModifier}+space" = "focus mode_toggle";

      # enter fullscreen mode for the focused container
      "${defaultModifier}+f" = "fullscreen toggle";

      # kill focused window
      "${defaultModifier}+${secondModifier}+q" = "kill";

      # rbrowser
      "${defaultModifier}+b" = "exec ${pkgs.nur.repos.kalbasit.rbrowser}/bin/rbrowser";

      # rofi run
      "${defaultModifier}+r" = "exec ${pkgs.rofi}/bin/rofi -show run";

      # list open windows to switch to
      "${thirdModifier}+Tab" = "exec ${pkgs.rofi}/bin/rofi -show window";

      # switch between the current and the previously focused one
      "${defaultModifier}+Tab" = "workspace back_and_forth";
      "${defaultModifier}+${secondModifier}+Tab" = "move container to workspace back_and_forth";

      # dynamic workspaces
      "${defaultModifier}+space" = "exec ${pkgs.rofi}/bin/rofi -show i3Workspaces";
      "${defaultModifier}+${secondModifier}+space" = "exec ${pkgs.rofi}/bin/rofi -show i3MoveContainer";
      "${defaultModifier}+${thirdModifier}+space" = "exec ${pkgs.rofi}/bin/rofi -show i3RenameWorkspace";

      # change container layout (stacked, tabbed, toggle split)
      "${defaultModifier}+l" = "layout stacking";
      "${defaultModifier}+u" = "layout tabbed";
      "${defaultModifier}+y" = "layout toggle split";

      # focus the parent container
      "${defaultModifier}+a" = "focus parent";

      # focus the child container
      "${defaultModifier}+d" = "focus child";

      # start a region screenshot
      "${defaultModifier}+${secondModifier}+4" = "exec ${getBin pkgs.flameshot}/bin/flameshot gui --delay 500 --path ${config.home.homeDirectory}/Desktop";

      # start a screen recorder
      "${defaultModifier}+${secondModifier}+5" = "exec ${getBin pkgs.simplescreenrecorder}/bin/simplescreenrecorder";

      # focus the urgent window
      "${defaultModifier}+x" = "[urgent=latest] focus";

      # mark current window / goto mark
      # https://github.com/tybitsfox/i3msg/blob/master/.i3/config
      "${defaultModifier}+m" = "exec i3-input -F 'mark %s' -l 1 -P 'Mark: '";
      "${defaultModifier}+apostrophe" = "exec i3-input -F '[con_mark=\"%s\"] focus' -l 1 -P 'Go to: '";

      # volume support
      "XF86AudioRaiseVolume" = "exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ false, exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ false, exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "exec ${nosid} ${getBin pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

      # brightness support
      "XF86MonBrightnessUp" = "exec ${nosid} ${getBin pkgs.brightnessctl}/bin/brightnessctl s +5%";
      "XF86MonBrightnessDown" = "exec ${nosid} ${getBin pkgs.brightnessctl}/bin/brightnessctl s 5%-";
      "${secondModifier}+XF86MonBrightnessUp" = "exec ${nosid} ${getBin pkgs.brightnessctl}/bin/brightnessctl s +1%";
      "${secondModifier}+XF86MonBrightnessDown" = "exec ${nosid} ${getBin pkgs.brightnessctl}/bin/brightnessctl s 1%-";

      # sleep support
      "XF86PowerOff" = "exec ${nosid} ${locker} && systemctl suspend";

      # clipboard history
      "${defaultModifier}+${thirdModifier}+c" = "exec ${getBin pkgs.rofi}/bin/rofi -modi \"clipboard:${getBin pkgs.haskellPackages.greenclip}/bin/greenclip print\" -show clipboard";

      # Terminals
      "${defaultModifier}+Return" = "exec ${getBin pkgs.termite}/bin/termite";
      "${defaultModifier}+${secondModifier}+Return" = "exec ${getBin pkgs.alacritty}/bin/alacritty";

      # Modes
      "${defaultModifier}+${thirdModifier}+r" = "mode resize";
      "${defaultModifier}+${thirdModifier}+m" = "mode move";

      # Make the currently focused window a scratchpad
      "${defaultModifier}+Shift+minus" = "move scratchpad";

      # Show the next scratchpad windows
      "${defaultModifier}+minus" = "scratchpad show";

      # Short-cuts for windows hidden in the scratchpad.
      "${thirdModifier}+w" = "[class=\"^whats-app-nativefier*\"] scratchpad show";
      "${thirdModifier}+m" = "[class=\"astroid\"] scratchpad show";
      "${thirdModifier}+p" = "[class=\"pulse-sms\"] scratchpad show";
      "${thirdModifier}+t" = "[class=\"Ptask\"] scratchpad show";
    } // (if config.mine.keybase.enable == true then {
      "${thirdModifier}+k" = "[class=\"Keybase\"] scratchpad show";
    } else {});

    modes = {
      resize = {
        # Micro resizement
        "Control+n" = "resize shrink width 10 px or 1 ppt";
        "Control+e" = "resize grow height 10 px or 1 ppt";
        "Control+i" = "resize shrink height 10 px or 1 ppt";
        "Control+o" = "resize grow width 10 px or 1 ppt";

        # Normal resizing
        "n" = "resize shrink width 50 px or 5 ppt";
        "e" = "resize grow height 50 px or 5 ppt";
        "i" = "resize shrink height 50 px or 5 ppt";
        "o" = "resize grow width 50 px or 5 ppt";

        # Macro resizing
        "${secondModifier}+n" = "resize shrink width 100 px or 10 ppt";
        "${secondModifier}+e" = "resize grow height 100 px or 10 ppt";
        "${secondModifier}+i" = "resize shrink height 100 px or 10 ppt";
        "${secondModifier}+o" = "resize grow width 100 px or 10 ppt";

        # back to normal: Enter or Escape
        "Return" = "mode default";
        "Escape" = "mode default";
      };

      move = {
        # Micro movement
        "Control+n" = "move left 10 px";
        "Control+e" = "move down 10 px";
        "Control+i" = "move up 10 px";
        "Control+o" = "move right 10 px";

        # Normal resizing
        "n" = "move left 50 px";
        "e" = "move down 50 px";
        "i" = "move up 50 px";
        "o" = "move right 50 px";

        # Macro resizing
        "${secondModifier}+n" = "move left 100 px";
        "${secondModifier}+e" = "move down 100 px";
        "${secondModifier}+i" = "move up 100 px";
        "${secondModifier}+o" = "move right 100 px";

        # back to normal: Enter or Escape
        "Return" = "mode default";
        "Escape" = "mode default";
      };
    };

    startup = [
      { command = "${getBin pkgs.xlibs.xset}/bin/xset r rate 300 30"; always = false; notification = false; }
      { command = "${getBin pkgs.xcape}/bin/xcape -e 'Control_L=Escape'"; always = false; notification = false; }
      { command = "${getBin pkgs.haskellPackages.greenclip}/bin/greenclip daemon"; always = false; notification = false; }
      { command = "i3-msg \"workspace personal@base; exec ${nosid} ${getBin pkgs.termite}/bin/termite\""; always = false; notification = true; }
    ];
  };

  extraConfig = ''
    # keep the urgency border of a window for 500ms
    # TODO: move this to the i3 module via PR
    force_display_urgency_hint 500 ms

    # This option determines in which mode new containers on workspace level will
    # start.
    # TODO: move this to the i3 module via PR
    workspace_layout tabbed

    #########
    # Modes #
    #########

    # Daemon launcher
    set $mode_daemon Launch: (x) Xcape, (g) Greenclip
    mode "$mode_daemon" {
      bindsym x exec ${nosid} ${getBin pkgs.xcape}/bin/xcape -e 'Control_L=Escape', mode default
      bindsym g exec ${nosid} ${getBin pkgs.haskellPackages.greenclip}/bin/greenclip daemon, mode default

      # back to normal: Enter or Escape
      bindsym Return mode default
      bindsym Escape mode default
    }
    bindsym ${defaultModifier}+${thirdModifier}+l mode "$mode_daemon"

    # Window Manager mode, this mode allows me to control i3
    set $mode_wm WM: (r) Reload i3, (e) Restart i3
    mode "$mode_wm" {
      bindsym r reload; exec ${nosid} ${getBin pkgs.libnotify}/bin/notify-send 'i3 configuration reloaded', mode default
      bindsym e restart; exec ${nosid} ${getBin pkgs.libnotify}/bin/notify-send 'i3 restarted', mode default

      # back to normal: Enter or Escape
      bindsym Return mode default
      bindsym Escape mode default
    }
    bindsym ${defaultModifier}+${thirdModifier}+w mode "$mode_wm"

    # Application launcher
    set $mode_apps Launch: (a) ARandR, (d) Discord, (i) Irc${optionalString config.mine.keybase.enable ", (k) Keybase"}, (m) Mail, (s) Studio, (t) TaskWarrior, (w) Work IM
    mode "$mode_apps" {
      bindsym a exec ${getBin pkgs.arandr}/bin/arandr, mode default
      bindsym d exec ${getBin pkgs.discord}/bin/Discord, mode default
      bindsym i exec ${getBin pkgs.termite}/bin/termite --title=irc --exec=weechat, mode default
      ${optionalString config.mine.keybase.enable "bindsym k exec ${getBin pkgs.keybase-gui}/bin/keybase-gui, mode default"}
      bindsym m exec astroid, mode default
      bindsym s exec ${getBin pkgs.obs-studio}/bin/obs, mode default
      bindsym t exec ${getBin pkgs.ptask}/bin/ptask, mode default
      bindsym w exec ${getBin pkgs.slack}/bin/slack, mode default

      # back to normal: Enter or Escape
      bindsym Return mode default
      bindsym Escape mode default
    }
    bindsym ${defaultModifier}+${thirdModifier}+a mode "$mode_apps"

    # Display mode allows output/resolution selection
    set $mode_display (a) Auto, (l) Laptop screen, (m) Multiple screen, (w) Wide screen
    mode "$mode_display" {
      bindsym a exec ${nosid} ${getBin pkgs.autorandr}/bin/autorandr --change, mode default
      bindsym l exec ${nosid} ${getBin pkgs.xlibs.xrandr}/bin/xrandr --output ${intMonitor} --mode ${intMode} --scale ${intScale} --output ${extMonitor} --off, mode default
      bindsym m exec ${nosid} ${getBin pkgs.xlibs.xrandr}/bin/xrandr --output ${intMonitor} --mode ${intMode} --scale ${intScale} --output ${extMonitor} --primary --mode 3440x1440 --right-of ${intMonitor}, mode default
      bindsym w exec ${nosid} ${getBin pkgs.xlibs.xrandr}/bin/xrandr --output ${intMonitor} --off --output ${extMonitor} --mode ${extMode}, mode default

      # back to normal: Enter or Escape
      bindsym Return mode default
      bindsym Escape mode default
    }
    bindsym ${defaultModifier}+${thirdModifier}+d mode "$mode_display"

    ## Management of power
    set $mode_power System: (l) lock, (o) logout, (s) suspend, (h) hibernate, (r) reboot, (${secondModifier}+s) shutdown
    mode "$mode_power" {
      bindsym l exec ${nosid} ${locker}, mode default
      bindsym o exit
      bindsym s exec ${nosid} ${locker} && systemctl suspend, mode default
      bindsym h exec ${nosid} ${locker} && systemctl hibernate, mode default
      bindsym r exec ${nosid} systemctl reboot
      bindsym ${secondModifier}+s exec ${nosid} systemctl poweroff -i

      # back to normal: Enter or Escape
      bindsym Return mode default
      bindsym Escape mode default
    }
    bindsym ${defaultModifier}+${thirdModifier}+p mode "$mode_power"

    # CPU governor selection
    set $mode_cpugovernor CPU Scaling governor: (p) Performance, (o) Powersave
    mode "$mode_cpugovernor" {
      bindsym p exec ${nosid} ${getBin pkgs.gksu}/bin/gksudo -- ${getBin pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set --governor performance, mode default
      bindsym o exec ${nosid} ${getBin pkgs.gksu}/bin/gksudo -- ${getBin pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set --governor powersave, mode default

      # back to normal: Enter or Escape
      bindsym Return mode default
      bindsym Escape mode default
    }
    bindsym ${defaultModifier}+${thirdModifier}+g mode "$mode_cpugovernor"

    ########################
    # Workspace assignment #
    ########################

    # assign important spaces to my external monitor
    workspace irc output ${extMonitor}
    workspace keeptruckin@base output ${extMonitor}
    workspace mail output ${extMonitor}
    workspace personal@base output ${extMonitor}
    workspace publica@base output ${extMonitor}
  '';
}
