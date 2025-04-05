commit="$(git log --grep="run in $1" -n 1 --pretty=format:"%h")"
git checkout $commit