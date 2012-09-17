#! /bin/sh

# Convert index.php into index.htm and index.html

page=http:/`pwd | sed s/home/localhost/`/index.php
wget -nv -O index.html $page
wget -nv -O index.htm ${page}'?audio'
