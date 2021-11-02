#!/bin/bash

maxx=0 maxy=0
first=0
for img in tmp/output-*; do
	if [ ${first} -eq 0 ]; then
		read sizex sizey < <( identify ${img} | cut -f 3 -d' ' | tr 'x' ' ' )
		export sizex sizey
		first=1
	fi
	img=${img##tmp/output-}
	img=${img%.*}
	img=${img/-/ }
	read x y <<< "${img}"
	[ $x -gt ${maxx} ] && maxx=${x}
	[ $y -gt ${maxy} ] && maxy=${y}
done

for x in $(seq 0 ${sizex} ${maxx}) ; do
	for y in $(seq 0 ${sizey} ${maxy}) ; do
		if [ ! -e "tmp/output-${x}-${y}.png" ]; then
			convert xc:transparent -resize 12288x12288 tmp/output-${x}-${y}.png
		fi
	done
done
