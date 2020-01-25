#!/bin/sh

# Usage: mkrelease.sh [TAG]
# Creates a subdirectory under "releases" with a copy of the EMMO repository.
# If 'TAG' is given, a copy of that tag is created, otherwise the latest master
# created.

set -x

rootdir="$(git rev-parse --show-toplevel)"  # git root dir
releasesdir=$rootdir/.github/releases

# Clone github pages repo to 'releasesdir' if it doesn't already exists
if [ ! -d $releasesdir ]; then
    #git clone https://github.com/emmo-repo/emmo-repo.github.io.git $releasesdir
    git clone git@github.com:emmo-repo/emmo-repo.github.io.git $releasesdir
fi

# Create a subdirectory under 'releasesdir' for current release
if [ -z "$1" ]; then
    src=$rootdir
    release=latest
else
    tag=$1
    mkdir -p $rootdir/.github/tmp
    src=$rootdir/.github/tmp/$tag
    if [ ! -d $src ]; then
        git clone --branch=$tag --depth=1 file://$rootdir $src
    fi
    release=$tag
fi
python3 $rootdir/.github/repocopy.py $src $releasesdir/$release

# TODO: generate documentation

# Generate html release table file
mkdir -p $releasesdir/html
reltable=$releasesdir/html/releasetable.html
echo "<head>" >$reltable
echo "  <link rel=\"stylesheet\" type=\"text/css\" href=\"../css/style.css\">" >>$reltable
echo "</head>"
echo "<table class\"reltable\">" >>$reltable
echo "  <tr>" >>$reltable
echo "  <th>Name</th>" >>$reltable
echo "  <th>URL</th>" >>$reltable
echo "  </tr>" >>$reltable
for owlfile in $releasesdir/*/emmo.owl; do
    reldir=$(dirname $owlfile)
    rel=$(basename $reldir)
    emmourl="http://emmo.info/$rel/emmo.owl"
    emmoref="../$rel/emmo.owl"
    echo "  <tr>" >>$reltable
    echo "  <td>$rel</td>" >>$reltable
    echo "  <td><a href=\"$emmoref\" target=\"_blank\">$emmourl</a></td>" >>$reltable
    echo "  </tr>" >>$reltable
done
echo "</table>" >>$reltable


# Push updates to github pages
cd $releasesdir
git add $release $reltable
git commit -m 'Added/updated release $release'
git push origin
