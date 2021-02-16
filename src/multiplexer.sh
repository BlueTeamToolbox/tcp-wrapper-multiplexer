#!/usr/bin/env bash

# ---------------------------------------------------------------------------------------- #
# Description                                                                              #
# ---------------------------------------------------------------------------------------- #
# Implement a multiplexer to allow multiple TCP Wrappers to be execute in sequence.        #
#                                                                                          #
# This will only capture and work with the exit code of the called filter.                 #
# ---------------------------------------------------------------------------------------- #
# TCP Wrapper config:                                                                      #
#                                                                                          #
# /etc/hosts.allow                                                                         #
#      sshd: ALL: aclexec /usr/local/sbin/multiplexer %a                                   #
#                                                                                          #
# /etc/hosts.deny                                                                          #
#      sshd: ALL                                                                           #
# ---------------------------------------------------------------------------------------- #

FILTERS=""
FILTER_PATH="/usr/local/sbin"

# ---------------------------------------------------------------------------------------- #
# In terminal                                                                              #
# ---------------------------------------------------------------------------------------- #
# A wrapper to check if the script is being run in a terminal or not.                      #
# ---------------------------------------------------------------------------------------- #

function in_terminal
{
    [[ -t 1 ]] && return 0 || return 1;
}

# ---------------------------------------------------------------------------------------- #
# Debug                                                                                    #
# ---------------------------------------------------------------------------------------- #
# Show output only if we are running in a terminal, but always log the message.            #
# ---------------------------------------------------------------------------------------- #

function debug()
{
    local message="${1:-}"

    if [[ -n "${message}" ]]; then
        if in_terminal; then
            echo "${message}"
        fi
        logger "${message}"
    fi
}

# ---------------------------------------------------------------------------------------- #
# Run Filters                                                                              #
# ---------------------------------------------------------------------------------------- #
# Run each of the filters in sequence. If the filter 'denies' the connection then bubble   #
# that failure up. Ignore 'allows' ($? == 0) as this is the default return from the filter #
# when a 'deny' isn't explicitly found. If no filter 'denies' the connection then return   #
# a default of allow, in the same was as the individual filters.                           #
# ---------------------------------------------------------------------------------------- #

function run_filters()
{
    IFS=', ' read -r -a filters <<< "${FILTERS}"

    for filter in "${filters[@]}"; do
        cmd="${FILTER_PATH}/${filter}"

        if [[ -x "${cmd}" ]]; then
            if ! output=$( "$cmd" "${IP}" 'MUX' 2>&1 ); then
                debug "${output}"
                exit 1
            fi
        fi
    done
}

# ---------------------------------------------------------------------------------------- #
# Main()                                                                                   #
# ---------------------------------------------------------------------------------------- #
# The main function where all of the heavy lifting and script config is done.              #
# ---------------------------------------------------------------------------------------- #

function main()
{
    #
    # NO IP given - error and abort
    #
    if [[ $# -ne 1 ]]; then
        debug 'Ip addressed not supplied - Aborting'
        exit 0
    fi

    #
    # Set a variable (Could pass it at function call)
    #
    declare -g IP="${1}"

    #
    # Run the actual filters
    #
    run_filters

    # Default allow
    exit 0
}

# ---------------------------------------------------------------------------------------- #
# Main()                                                                                   #
# ---------------------------------------------------------------------------------------- #
# The actual 'script' and the functions/sub routines are called in order.                  #
# ---------------------------------------------------------------------------------------- #

main "${@}"

# ---------------------------------------------------------------------------------------- #
# End of Script                                                                            #
# ---------------------------------------------------------------------------------------- #
# This is the end - nothing more to see here.                                              #
# ---------------------------------------------------------------------------------------- #
