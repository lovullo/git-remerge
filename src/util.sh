#!/bin/bash
# Utility functions
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

test -z "$__INC_GITREMERGE_UTIL" || return 0
__INC_GITREMERGE_UTIL=1


##
# Invoke a callback for each line of input
#
# The arguments passed to the callback will first be the arguments provided to
# for-each, followed by an argument for each word read from the line of input.
#
for-each()
{
  local -r callback="$1"
  local -a args=()
  shift

  while read -a args; do
    "$callback" "$@" "${args[@]}" || return
  done
}

