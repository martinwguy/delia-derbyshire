#! /bin/sh

# Convert index.php into index.htm and index.html

page=http://localhost/martin/audio/D-D/index.php

all: index.htm index.html

index.html: index.php
	wget -nv -O index.html $(page)

index.htm: index.php
	wget -nv -O index.htm $(page)'?audio'

# quico:audio/D-D/
# 4star: www/D-D
update upload: all
	rsync -av --delete \
		--exclude iso \
		--exclude LIAF \
		--exclude log \
		--exclude rec \
		--exclude test \
		--exclude video/bbc_delia2_w_sound.mov \
		--exclude WIKI \
		--exclude BBC_RWS_First_25_Years.pdf \
		--exclude papers.zip \
		./ quico:audio/D-D/

backup:
	# Back up to fon all except generated files
	rsync -av --delete \
		--exclude papers/html \
		--exclude papers/toe \
		--exclude papers/thumb \
		./ fon:audio/D-D/