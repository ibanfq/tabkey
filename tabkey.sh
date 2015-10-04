#!/usr/bin/env bash

## Tabkey
##
## A library for autocomplete terminal commands using the tab key
## compatible with `bash` and `zsh`.
##
## Usage:
##
## tabkey on (command) (callback)
##
##     command => name of command to autocomplete.
##     callback => function to call when key tab is pressed.
##
##     Return 0 for success or 1 for failure.
##
##
## tabkey pressed
##
##     Set $TABKEY_WORDS with the words in current command
##     and $TABKEY_CUR with the current cursor position.
##
##     Return 0 if tabkey was pressed or 1 otherwise.
##
##
## tabkey suggest [dirs] [files] [-- command_1 command_2 ...]
##
##     Return 0 for success or 1 for failure.
##

typeset -a TABKEY_WORDS
typeset -i TABKEY_CUR

tabkey() {
    case "$1" in
        on)
            if (( $# == 3 )); then
                if alias "$2" &>/dev/null; then
                    if ! type compdef &>/dev/null && ! type compctl &>/dev/null; then
                        complete -o filenames -F "$3" "$2"
                    fi
                    return 0
                else
                    if type compdef &>/dev/null; then
                        compdef "$3" "$2"
                    elif type compctl &>/dev/null; then
                        compctl -S '' -K "$3" "$2"
                    else
                        shopt -s progcomp
                        complete -o filenames -F "$3" "$2"
                    fi
                    return 0
                fi
            fi
            return 1
        ;;

        pressed)
            TABKEY_WORDS=()
            TABKEY_CUR=0

            if type compdef &>/dev/null; then
                # shellcheck disable=SC2154
                if [ ! -z "$words" ]; then
                    TABKEY_WORDS=("${words[@]}")
                    TABKEY_CUR=$CURRENT
                    return 0
                fi
            elif type compctl &>/dev/null; then
                # shellcheck disable=SC2162
                if read -Ac TABKEY_WORDS &>/dev/null; then
                    # shellcheck disable=SC2162
                    read -cn TABKEY_CUR
                    return 0
                fi
            elif [ ! -z "$COMP_WORDS" ]; then
                # shellcheck disable=SC2034
                TABKEY_WORDS=(_ "${COMP_WORDS[@]}")
                unset TABKEY_WORDS[0]
                # shellcheck disable=SC2034
                TABKEY_CUR=$((COMP_CWORD+1))
                return 0
            fi
            return 1
        ;;

        suggest)
            while (( $# > 1 )); do
                shift
                case "$1" in
                    'files')
                        if type compdef &>/dev/null; then
                            compinit
                            _path_files
                        elif type compctl &>/dev/null; then
                            # shellcheck disable=SC2162
                            read <<< "${TABKEY_WORDS[$TABKEY_CUR]}" #unescape
                            for path in "$REPLY"*; do
                                [ -d "$path" ] && path=$path/
                                reply+=($path)
                            done
                        else
                            typeset IFS=$'\n'
                            COMPREPLY+=( $(compgen -f -- "${TABKEY_WORDS[$TABKEY_CUR]}") )
                        fi
                    ;;

                    'dirs')
                        if type compdef &>/dev/null; then
                            _path_files -/
                        elif type compctl &>/dev/null; then
                            # shellcheck disable=SC2162
                            read <<< "${TABKEY_WORDS[$TABKEY_CUR]}" #unescape
                            reply+=("$REPLY"*/)
                        else
                            typeset IFS=$'\n'
                            COMPREPLY+=( $(compgen -d -- "${TABKEY_WORDS[$TABKEY_CUR]}") )
                        fi
                    ;;

                    '--')
                        shift 
                        if type compdef &>/dev/null; then
                            compadd -- "$@"
                        elif type compctl &>/dev/null; then
                            reply+=("$@")
                        else
                            typeset IFS=$'\n'
                            COMPREPLY+=( $(compgen -W "$(printf '%q\n' "$@")" -- "${TABKEY_WORDS[$TABKEY_CUR]}") )
                        fi
                        return 0
                    ;;
                esac
            done
            return 0
        ;;
    esac
}
