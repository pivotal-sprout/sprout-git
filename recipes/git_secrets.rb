Chef::Log.warn(<<-EOF)
The sprout-git::git_secrets recipe is now DEPRECATED!

Git 2.9 added new configuration options that made the configuration of hooks far
simpler. This is now the recommended way to add git hooks. At the same time we
have made our own credential scanner which we are going to distribute separately
from sprout-git.

The new configuration options are used in the new sprout-git::git_hooks_core
recipe. It provides a more opinionated but far less complex method of installing
system-wide git hooks.

You can remove the existing git hooks by deleting the following directories.
Make sure that you have backed up any custom hooks that you would like to keep!

* /usr/local/share/githooks
* $HOME/.githooks
* [YOUR_PROJECTS...]/githooks

Or, if you trust us, (please review the script for safety anyway) you can run
the script linked below which will remove the default hooks that were added and
warn about any custom hooks that should be backed up and migrated.

  https://github.com/pivotal-sprout/sprout-git/blob/master/share/remove_git_hooks.sh

We're sorry for any inconvenience but we hope you'll like the far simpler new
approach.
EOF
