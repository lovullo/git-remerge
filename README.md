# git-remerge
Re-merge branches that have been merged into the given ref within the given
time frame.

The intended use of this script is to create a clean branch that does not
contain feature commits that have been left untested or untouched for too
long; this may be useful on testing brashes that combine a number of
development tasks that may or may not make it into production.


## Usage
```
Usage: git-remerge [-p] ref timespec
Merge into the current branch all remote branches merged into REF within the
past TIMESPEC. The value of TIMESPEC may be anything recognized by `date`.

Options:
  -p  pretend (dry run); show what would be merged, but do not merge
  -V  display version and copyright information

For more information on branching and merging, see `git help branch` and
`git help merge` respectively.
```


## Installation
You may run the binary directly from `bin/`. Alternatively, if you add
`bin/` to your `PATH`, then you may invoke `git-remerge` as `git remerge`
(no dash) just like other Git commands.

Support for tab completion has not yet been added.


## License
git-remerge is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

