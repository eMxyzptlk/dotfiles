{ config, pkgs, lib, ... }:

with lib;

let
  sshKeys = [
    (builtins.readFile (builtins.fetchurl {
      url = "https://github.com/kalbasit.keys";
      sha256 = "033rs0pnm8aiycrfmx04qx8fmnkfdhp4hy3kdpgil3cgbgff9736";
    }))
  ];

  makeUser = name: attrs: nameValuePair
    (name)
    ({
      inherit (attrs) uid;

      group = "mine";
      extraGroups = [
        "docker"
        "fuse"
        "libvirtd"
        "networkmanager"
        "vboxusers"
        "video"
      ] ++ (if attrs.isAdmin then ["wheel"] else []);

      shell = pkgs.zsh;
      hashedPassword = "$6$0bx5eAEsHJRxkD8.$gJ7sdkOOJRf4QCHWLGDUtAmjHV/gJxPQpyCEtHubWocHh9O7pWy10Frkm1Ch8P0/m8UTUg.Oxp.MB3YSQxFXu1";
      isNormalUser = true;

      openssh.authorizedKeys.keys = sshKeys;
    });

  makeHM = name: attrs: nameValuePair
    (name)
    (config.mine.home-manager.config {
      inherit (attrs) uid isAdmin;
      inherit name;
      nixosConfig = config;
    });

  defaultUsers = {
    # TODO: remove this once I move to yl users
    kalbasit      = { uid = 1026; isAdmin = true; };

    yl            = { uid = 2000; isAdmin = false; };
    yl_admin      = { uid = 2001; isAdmin = true; };
    yl_opensource = { uid = 2002; isAdmin = false; };
    yl_publica    = { uid = 2016; isAdmin = false; };
  };

in {
  options.mine.users = mkOption {
    type = types.attrs;
    default = defaultUsers;
    defaultText = ''
      The default users are ${builtins.concatStringsSep " " (builtins.attrNames defaultUsers)}
    '';
    description = ''
      The list of users to create.
    '';
  };

  config = {
    # set the initial password of the root user
    security.initialRootPassword = "$6$0bx5eAEsHJRxkD8.$gJ7sdkOOJRf4QCHWLGDUtAmjHV/gJxPQpyCEtHubWocHh9O7pWy10Frkm1Ch8P0/m8UTUg.Oxp.MB3YSQxFXu1";

    users = {
      mutableUsers = false;

      groups = {
        mine = {
          gid = 2000;
        };
      };

      users = {
        root = { openssh.authorizedKeys.keys = sshKeys; };
      } // (mapAttrs' makeUser config.mine.users);
    };

    home-manager.users = mapAttrs' makeHM config.mine.users;
  };
}
