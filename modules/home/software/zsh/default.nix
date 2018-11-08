{ config, pkgs, lib, ... }:

with lib;
with pkgs;

let
  ssh-agents = stdenvNoCC.mkDerivation rec {
    name = "ssh-agents-${version}";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "kalbasit";
      repo = "ssh-agents";
      rev = "v${version}";
      sha256 = "1bkzrwlgnsq740868k3ac9bwnkxfbwbyn6dcffnbjafgz6mdr3sc";
    };

    installFlags = [ "PREFIX=$(out)" ];
  };

  myFunctions = stdenvNoCC.mkDerivation rec {
    name = "zsh-functions-${version}";
    version = "0.0.1";
    src = ./plugins/functions;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir $out

      cp $src/* $out/

      rm -f $out/default.nix

      substituteInPlace $out/c \
        --subst-var-by tar_bin ${getBin gnutar}/bin/tar \
        --subst-var-by bzip2_bin ${getBin bzip2}/bin/bzip2 \
        --subst-var-by gzip_bin ${getBin gzip}/bin/gzip \
        --subst-var-by zip_bin ${getBin zip}/bin/zip

      # TODO:
      # --subst-var-by rar_bin {getBin pkgs.}/bin/ \
      # --subst-var-by jar_bin {getBin pkgs.}/bin/ \

      substituteInPlace $out/gcim \
        --subst-var-by git_bin ${getBin git}/bin/git

      substituteInPlace $out/gorder \
        --subst-var-by git_bin ${getBin git}/bin/git \
        --subst-var-by sed_bin ${getBin gnused}/bin/sed

      substituteInPlace $out/gtime \
        --subst-var-by git_bin ${getBin git}/bin/git \
        --subst-var-by sed_bin ${getBin gnused}/bin/sed

      substituteInPlace $out/get_pr \
        --subst-var-by curl_bin ${getBin curl}/bin/curl \
        --subst-var-by git_bin ${getBin git}/bin/git \
        --subst-var-by jq_bin ${getBin jq}/bin/jq \
        --subst-var-by xsel_bin ${getBin xsel}/bin/xsel

      substituteInPlace $out/git_require_clean_work_tree \
        --subst-var-by git_bin ${getBin git}/bin/git

      substituteInPlace $out/git_gopath_formatted_repo_path \
        --subst-var-by git_bin ${getBin git}/bin/git \
        --subst-var-by perl_bin ${getBin perl}/bin/perl

      substituteInPlace $out/jsonpp \
        --subst-var-by python_bin ${getBin python37Full}/bin/python \
        --subst-var-by pygmentize_bin ${getBin python36Packages.pygments}/bin/pygmentize

      substituteInPlace $out/jspp \
        --subst-var-by js-beautify_bin ${getBin python36Packages.jsbeautifier}/bin/js-beautify

      substituteInPlace $out/mkfs.enc \
        --subst-var-by cryptsetup_bin ${getBin cryptsetup}/bin/cryptsetup \
        --subst-var-by mkfs_ext2_bin ${getBin e2fsprogs}/bin/mkfs.ext2

      substituteInPlace $out/mount.enc \
        --subst-var-by cryptsetup_bin ${getBin cryptsetup}/bin/cryptsetup \
        --subst-var-by lpass_bin ${getBin lastpass-cli}/bin/lpass

      substituteInPlace $out/new_pr \
        --subst-var-by curl_bin ${getBin curl}/bin/curl \
        --subst-var-by git_bin ${getBin git}/bin/git \
        --subst-var-by jq_bin ${getBin jq}/bin/jq \
        --subst-var-by xsel_bin ${getBin xsel}/bin/xsel

      substituteInPlace $out/sapg \
        --subst-var-by apg_bin ${getBin apg}/bin/apg

      substituteInPlace $out/sp \
        --subst-var-by ssh-agents_bin ${getBin ssh-agents}/bin/ssh-agents

      substituteInPlace $out/tmycli \
        --subst-var-by mycli_bin ${getBin mycli}/bin/mycli \
        --subst-var-by netstat_bin ${getBin nettools}/bin/netstat \
        --subst-var-by ssh_bin ${getBin openssh}/bin/ssh

      substituteInPlace $out/ulimit_usage \
        --subst-var-by paste_bin ${getBin coreutils}/bin/paste \
        --subst-var-by cut_bin ${getBin coreutils}/bin/cut \
        --subst-var-by awk_bin ${getBin gawk}/bin/awk \
        --subst-var-by lsof_bin ${getBin lsof}/bin/lsof \
        --subst-var-by sed_bin ${getBin gnused}/bin/sed \
        --subst-var-by bc_bin ${getBin bc}/bin/bc

      substituteInPlace $out/umount.enc \
        --subst-var-by cryptsetup_bin ${getBin cryptsetup}/bin/cryptsetup

      substituteInPlace $out/pr \
        --subst-var-by git_bin ${getBin git}/bin/git

      substituteInPlace $out/vim_clean_swap \
        --subst-var-by vim_bin ${getBin vim}/bin/vim

      substituteInPlace $out/xmlpp \
        --subst-var-by xmllint_bin ${getBin libxml2Python}/bin/xmllint
    '';
  };

in {

  home.packages = [
    # packages needed by the extract plugin
    # TODO: move this to the extract plugin instead!
    binutils
    bzip2
    gnutar
    gzip
    p7zip
  ];

  programs.zsh = mkMerge [
    ({ initExtra = optionalString stdenv.isDarwin ''
        # source the nix profiles
        if [[ -r "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh" ]]; then
          source "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh"
        fi
      '';})

    {
      enable = true;

      enableCompletion = true;
      enableAutosuggestions = true;

      shellAliases = {
        cat = "${bat}/bin/bat";
        e = "\${EDITOR:-nvim}";
        gl = "github_commit_link";
        http = "http --print=HhBb";
        kube = "kubectl";
        less = "${bat}/bin/bat";
        ll = "ls -la";
        pw = "ps aux | grep -v grep | grep -e";
        rot13 = "tr \"[A-Za-z]\" \"[N-ZA-Mn-za-m]\"";
        serve_this = "${python3}/bin/python -m http.server";
        utf8test = "${curl}/bin/curl -L https://github.com/tmux/tmux/raw/master/tools/UTF-8-demo.txt";
        vi = "nvim";
        vim = "nvim";

        # for enabling and disabling the current theme. This means go back to a very basic theme
        zsh_theme_enable = "prompt_powerlevel9k_teardown";
        zsh_theme_disable = "prompt_powerlevel9k_setup";

        # TODO: move this to the swm package
        s = "swm tmux switch-client";
        sb = "swm --story base tmux switch-client";
        vim_ready = ""; # TODO: run direnv here

        # TODO: move to docker-config, how to tell ZSH to import them?
        remove_created_containers = "docker rm -v \$(docker ps -a -q -f status=created)";
        remove_dangling_images = "docker rmi \$(docker images -f dangling=true -q)";
        remove_dead_containers = "docker rm -v \$(docker ps -a -q -f status=exited)";

        shabka = "t project:shabka";

        # Always enable colored `grep` output
        # Note: `GREP_OPTIONS = "--color = auto"` is deprecated, hence the alias usage.
        egrep = "egrep --color=auto";
        fgrep = "fgrep --color=auto";
        grep = "grep --color=auto";

        # send_code sends the code to apollo
        send_code = "${rsync}/bin/rsync -avuz --rsync-path=/usr/bin/rsync --delete --exclude=.snapshots/ --exclude=pkg/ --exclude=bin/ \"$CODE_PATH/\" apollo:/volume1/Code/active/";
        # get_code gets code from apollo
        get_code = "${rsync}/bin/rsync -avuz --rsync-path=/usr/bin/rsync --delete --exclude=.snapshots/ --exclude=pkg/ --exclude=bin/ apollo:/volume1/Code/active/ \"$CODE_PATH/\"";

        # OS-Specific aliases
        # TODO: install this only on Mac
        #if [[ "$OSTYPE" = darwin* ]]; then  # Mac only
        #	alias mac_install_cert='sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain'
        #fi

        # use 'fc -El 1' for "dd.mm.yyyy"
        # use 'fc -il 1' for "yyyy-mm-dd"
        # use 'fc -fl 1' for mm/dd/yyyy
        history = "fc -il 1";
      };

      history = {
        expireDuplicatesFirst = true;
        save = 100000000;
        size = 1000000000;
      };

      initExtra = builtins.readFile (substituteAll {
        src = ./init-extra.zsh;

        exa_bin      = "${getBin exa}/bin/exa";
        fortune_bin  = "${getBin fortune}/bin/fortune";
        fzf_bin      = "${getBin fzf}/bin/fzf-tmux";
        home_path    = "${config.home.homeDirectory}";
        jq_bin       = "${getBin jq}/bin/jq";
        tput_bin     = "${getBin ncurses}/bin/tput";
      });

      oh-my-zsh = {
        enable = true;

        plugins = [
          "command-not-found"
          "extract"
          "git"
          "history"
          "kubectl"
          "sudo"
        ];
      };

      plugins = [
        {
          name = "enhancd";
          file = "init.sh";
          src = fetchFromGitHub {
            owner = "b4b4r07";
            repo = "enhancd";
            rev = "fd805158ea19d640f8e7713230532bc95d379ddc";
            sha256 = "0pc19dkp5qah2iv92pzrgfygq83vjq1i26ny97p8dw6hfgpyg04l";
          };
        }

        {
          name = "gitit";
          src = fetchFromGitHub {
            owner = "peterhurford";
            repo = "git-it-on.zsh";
            rev = "4827030e1ead6124e3e7c575c0dd375a9c6081a2";
            sha256 = "01xsqhygbxmv38vwfzvs7b16iq130d2r917a5dnx8l4aijx282j2";
          };
        }

        {
          name = "solarized-man";
          src = fetchFromGitHub {
            owner = "zlsun";
            repo = "solarized-man";
            rev = "a902b64696271efee95f37d45589078fdfbbddc5";
            sha256 = "04gm4qm17s49s6h9klbifgilxv8i45sz3rg521dwm599gl3fgmnv";
          };
        }

        {
          name = "powerlevel9k";
          file = "powerlevel9k.zsh-theme";
          src = fetchFromGitHub {
            owner = "bhilburn";
            repo = "powerlevel9k";
            rev = "571a859413866897cf962396f02f65a288f677ac";
            sha256 = "0xwa1v3c4p3cbr9bm7cnsjqvddvmicy9p16jp0jnjdivr6y9s8ax";
          };
        }

        {
          name = "zsh-completions";
          src = fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-completions";
            rev = "0.27.0";
            sha256 = "1c2xx9bkkvyy0c6aq9vv3fjw7snlm0m5bjygfk5391qgjpvchd29";
          };
        }

        {
          name = "zsh-history-substring-search";
          src = fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-history-substring-search";
            rev = "47a7d416c652a109f6e8856081abc042b50125f4";
            sha256 = "1mvilqivq0qlsvx2rqn6xkxyf9yf4wj8r85qrxizkf0biyzyy4hl";
          };
        }

        {
          name = "zsh-syntax-highlighting";
          src = fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "db6cac391bee957c20ff3175b2f03c4817253e60";
            sha256 = "0d9nf3aljqmpz2kjarsrb5nv4rjy8jnrkqdlalwm2299jklbsnmw";
          };
        }

        {
          name = "nix-shell";
          src = fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "03a1487655c96a17c00e8c81efdd8555829715f8";
            sha256 = "1avnmkjh0zh6wmm87njprna1zy4fb7cpzcp8q7y03nw3aq22q4ms";
          };
        }

        {
          name = "functions";
          src = myFunctions;
        }
      ];
  }];
}
