#!/bin/bash
# Git functions
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

test -z "$__INC_GITREMERGE_GIT" || return 0
__INC_GITREMERGE_GIT=1


declare -rx GIT_DIR="${1:-GIT_DIR}"


##
# Determine the remote branches merged into the provided ref
#
list-merged-of()
{
  local -r ref="$1"

  # some lines are of the form "local -> remote"; awk will therefore take the
  # last field
  git branch -r --merged "$ref" \
    | awk '{print $NF}'
}


##
# Attempt to merge the given branch into the checked out tree
#
# If a merge fails, it will be immediately aborted. The result is the branch
# name, followed by either `merged' or `failed', followed by all other arguments
# passed to this function.
#
merge-branch()
{
  local -r branch="$1"
  shift

  local result=merged
  git merge -q --no-ff "$branch" &>/dev/null || {
    result=failed
    git merge --abort &>/dev/null
  }

  echo "$branch $result" "$@"
}


##
# Filter a branch based on the commit timestamp of the tip
#
# If the tip of the branch is older than the provided timestamp, then there
# will be no output; otherwise, the branch name will be echoed along with all
# other arguments passed to this function.
#
filter-branch-ts()
{
  local -r oldts="$1" branch="$2"
  local -r ts="$( git log -1 --pretty="%ct" "$branch" )" || return
  shift 2

  test -n "$ts" || {
    echo "warning: failed to retrieve timestamp of \`$branch'" >&2
    return 1
  }

  # keep only branches that are >= the given date
  test "$ts" -ge "$oldts" || return 0
  echo "$branch" "$@"
}

