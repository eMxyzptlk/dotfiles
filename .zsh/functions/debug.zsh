#
# vim:ft=sh:fenc=UTF-8:ts=4:sts=4:sw=4:expandtab:foldmethod=marker:foldlevel=0:
#
# Some functions are taken from
#       http://phraktured.net/config/
#       http://www.downgra.de/dotfiles/

function debug() {
    if isTrue "${DEBUG}"; then
        echo -e "[DEBUG][${funcstack[2]}()] ${@}"
    fi
}
