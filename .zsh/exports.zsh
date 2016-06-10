export GOPATH="${HOME}/code"            # How can I live without Go?
export CDPATH="${GOPATH}/src:$cdpath"   # Add $GOPATH/src to CDPATH
export MYFS="${HOME}/.filesystem"       # Make sure I always know about my filesystem.
export EDITOR=nvim                      # NeoVim simply rocks!!

function pathmunge() {
  [[ ! -d "${1}" ]] && return
  if ! [[ $PATH =~ (^|:)$1($|:) ]]; then
     if [ "$2" = "after" ] ; then
        PATH=$PATH:$1
     else
        PATH=$1:$PATH
     fi
  fi
}

function pathunmunge() {
  oldpath=("${(@s/:/)PATH}")
  newpath=""
  sep=""
  for p in ${oldpath[*]}; do
    if [[ "x${p}" != "x${1}" ]]; then
      newpath="${newpath}${sep}${p}"
      sep=":"
    fi
  done
  export PATH="${newpath}"
}

# Are we on Mac? Start the path as defined in /etc/paths
if [[ -x /usr/libexec/path_helper ]]; then
  eval `/usr/libexec/path_helper -s`
fi

# We need our bin folder
pathmunge "${HOME}/.bin"

# We need Go's bin folder
pathmunge "${GOPATH}/bin"

# Anything got installed into MYFS?
pathmunge "${MYFS}/bin"
pathmunge "${MYFS}/opt/go_appengine"
if [[ -d "${MYFS}" ]]; then
  if [[ -d "${MYFS}/opt" ]]; then
    for dir in `find "${MYFS}/opt" -maxdepth 1 -mindepth 1 -type d`; do
      if [[ -d "${dir}/bin" ]]; then
        pathmunge "${dir}/bin" after
      fi
    done
  fi

  # Make LD can find our files.
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${HOME}/.filesystem/lib"
fi

# Add all rubygems bin dir
if [[ -d "${HOME}/.gem/ruby" ]]; then
  for dir in $HOME/.gem/ruby/*/bin; do
    pathmunge "${dir}"
  done
fi

pathmunge "${GOPATH}/src/github.com/phacility/arcanist/bin"
pathmunge "${GOPATH}/src/github.com/google/bazel/output"

# Export Github's token if it's readable.
github_token_path="$HOME/.github_token"
if [[ -r "${github_token_path}" ]]; then
  export HOMEBREW_GITHUB_API_TOKEN=`head -1 ${github_token_path}`
fi
unset github_token_path

# Export MySQL credentials if it's readable
mysql_credentials_path="$HOME/.my.cnf"
if [[ -r "${mysql_credentials_path}" ]]; then
  user="`cat "$mysql_credentials_path" | grep "user" | cut -d= -f2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`"
  pass="`cat "$mysql_credentials_path" | grep "password" | cut -d= -f2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`"

  if [ "x${user}" != "x" ]; then
    export MYSQL_USERNAME="${user}"
    export MYSQL_PASSWORD="${pass}"
  fi
  unset user pass
fi
unset mysql_credentials_path

# Export camlistore's secret keyring
# [[ -x "$(brew --prefix)/bin/camput" ]] && export CAMLI_SECRET_RING="${HOME}/.gnupg/secring.gpg"

# Docker Environment Variable export
eval $(docker-machine env)
