all: thumb.html toe.html index.html

all: mkthumb.sh mkhtml.sh mkindex.sh header.html footer.html
	sh mkthumb.sh
	sh mkhtml.sh
	# Must run mkthumb before mkindex as it measures the thumbnails
	sh mkindex.sh
