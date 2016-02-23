#! /bin/sh

# Convert index.php into index.htm and index.html

page=http://localhost/martin/audio/D-D/index.php

all: index.htm index.html

index.html: index.php
	wget -nv -O index.html $(page) || rm $@

index.htm: index.php
	wget -nv -O index.htm $(page)'?audio' || rm $@

pretend:
	make PRETEND=-n update

# quico:audio/D-D/
# 4star: www/D-D
update upload: all
	rsync -av $(PRETEND) --delete \
		--exclude .git\* \
		--exclude anal/\*.jpg anal/\*.png anal/\*.wav \
		--exclude log \
		--exclude scores/doc \
		--exclude VIDEO \
		--exclude \*.flac --exclude \*.wav \
		--exclude rec/TheseHopefulMachines \
		--exclude rec/\*.mp3 \
		--partial --inplace \
		--bwlimit=48 \
		./ delia-derbyshire.net:audio/D-D/


backup:
	# Back up to fon all except generated files
	rsync -av --delete \
		./ fon:audio/D-D/
