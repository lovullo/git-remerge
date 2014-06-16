#!/bin/bash
# Command-line processing
#
#  Copyright (C) 2014 LoVullo Associates, Inc.
#
#  This file is part of boilerepo.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

test -z "$__INC_GITREMERGE_CMDLINE" || return 0
__INC_GITREMERGE_CMDLINE=1

declare -ri EX_USAGE=64

declare -r _progver="$1"
declare -r _optstr=pV


##
# Output standard usage information
#
usage()
{
  local progname="${1:-$( basename "$0" )}"

  cat <<EOU
Usage: $progname [-p] ref timespec
Merge into the current branch all remote branches merged into REF within the
past TIMESPEC. The value of TIMESPEC may be anything recognized by \`date\`.

Options:
  -p  pretend (dry run); show what would be merged, but do not merge
  -V  display version and copyright information

For more information on branching and merging, see \`git help branch\` and
\`git help merge\` respectively.
EOU
}


##
# Output version information and copyright
#
# This is the standard version format used by GNU.
#
version()
{
  cat <<EOV
git-merge $_progver
Copyright (C) LoVullo Associates, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Mike Gerwitz <gerwitzm@lovullo.com>.
EOV
}


##
# Process command-line options into the array of the provided name and then
# invoke the callback with all remaining arguments
#
cmdline()
{
  local -r optdest="$1" callback="$2"
  local opt
  shift 2

  test $# -ge 2 || {
    usage
    return $EX_USAGE
  }

  while getopts "$_optstr" opt; do
    case "$opt" in
      p) _set-opt "$optdest" dryrun 1;;
      V)
        version
        return
        ;;
      *)
        usage
        return $EX_USAGE
        ;;
    esac
  done

  shift $((OPTIND-1))

  # invoke main program; command-line args will be available in the provided
  # array name
  "$callback" "$@"
}


##
# Set option value in array of the given name
#
# This is a safe eval method: %q is used to ensure proper quoting to avoid shell
# injection. $optdest is assumed to be a safe identifier; it is up to the caller
# to ensure that.
#
_set-opt()
{
  local -r optdest="$1" var="$2" val="$3"
  eval "$( printf "$optdest[%q]=%q" "$var" "$val" )"
}

