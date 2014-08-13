#!/bin/bash
# Git functions
#
#  Copyright (C) 2014 LoVullo Associates, Inc.
#
#  This file is part of git-remerge.
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


declare -rx _gitdir="$1"


##
# Run git command on the appropriate git repository
#
# A simple GIT_DIR export can cause problems when we're working within the
# git-merge repository.
#
git()
{
  command git --git-dir="$_gitdir" "$@"
}


##
# Determine the remote branches merged into the provided ref
#
list-merged-of()
{
  local -r ref="$1" since="$2"
  local ts commit
  local -i curts
  local -A branchts=() branchref=()

  # the awkward use of process substitution is to prevent subshells, which would
  # encapsulate assignments to branchts
  while read ts commit; do
    while read branch; do
      # take only newer merge commits; we do this because commit order does not
      # necessarily represent more recent merges: you can (a) rewrite history of
      # merges or (b) merge older commits rather than the tip of the branch
      curts="${branchts[$branch]}"
      test "$curts" -eq 0 -o "${curts}" -ge "$ts" || continue

      branchts[$branch]="$ts"
      branchref[$branch]="$commit"
    done < <( _get-commit-branch "$commit" )
  done < <( _list-merges-since "$ref" "$since" )

  # we now have a list of branches and the hash of the most recent commit in
  # that branch that was merged into $ref
  for branch in "${!branchref[@]}"; do
    echo "${branchref[$branch]} $branch"
  done
}


##
# List the timestamp and merged commit hash of all merges within the given
# timeframe into $ref
#
_list-merges-since()
{
  local -r ref="$1" since="$2"

  # we can't use %ct here, because that's the time of the merge commit; we want
  # the time of the commit that was merged
  git log --merges --pretty=%P --since="$since" .."$ref" \
    | while read _ commit; do
        echo "$( git log -1 --pretty=%ct "$commit" ) $commit"
      done
}


##
# Determine the branch from which $commit originated
#
# FIXME:
# This assumes that the branch is the only branch that contains the commit as a
# --first-parent; if this is not the case (e.g. branching off of a topic
# branch), this may not give the intended results.
#
# Note that this will only work if the remote ref still exists. Fortunately,
# this is okay, because we wouldn't want to re-merge abandoned branches.
_get-commit-branch()
{
  local -r commit="$1"
  local -i found

  git branch -r --contains "$commit" --no-merged \
    | awk '{print $NF}' \
    | while read branch; do
        git log --first-parent --pretty=%H "$commit"^.."$branch" \
          | grep -q "$commit" \
          || continue

        # the commit is *not* introduced by a merge; we found the branch
        echo "$branch"
        break
      done
}


##
# Attempt to merge the given commit into the checked out tree
#
# If a merge fails, it will be immediately aborted. The result is the branch
# name, followed by either `merged' or `failed', followed by all other arguments
# passed to this function.
#
merge-commit()
{
  local -r commit="$1" branch="$2"
  shift 2

  local -r msg="Re-merged '$branch' at ${commit:0:7}"

  local result=merged
  cd "$_gitdir" \
    && git merge -q --no-ff "$commit" -m"$msg" &>/dev/null || {
      result=failed
      git merge --abort &>/dev/null
    } \
    && cd "$OLDPWD"

  echo "$commit $result $branch" "$@"
}

