#! /bin/sh

# Ensure that all index entries in mkindex.sh correspond to existing photos
# as a check for typoes.

for a in `sed -n '/^\([0-9][0-9]*\)).*/s//\1/p' mkindex.sh`
do
	test -f "maxi/dd$a.jpg" || vi "+/^$a/" mkindex.sh
done
