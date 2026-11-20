# The size-risk repo, where Git does not ignore .cookbook/: no exclude entry, and the machine's global ignore file is off for this repo.
. "$(dirname "$0")/../size-risk/setup.sh"
: > .git/info/exclude
git config core.excludesFile /dev/null
