#!/bin/bash

LAYER="${1}"

maxx=0
maxy=0
if [ "${LAYER}" == "0" ] ; then
	for img in tmp/output-*-*.png; do
		img="${img#tmp/output-}"
		img="${img%.png}"
		read x y <<< "${img/-/ }"
		[ ${x} -gt ${maxx} ] && maxx=${x}
		[ ${y} -gt ${maxy} ] && maxy=${y}
	done
	[ -e tmp/transparent.png ] || convert xc:transparent -resize 12288x12288 tmp/transparent.png
	if [ ! -e "tmp/output-0-0.png" ] ; then
		cp tmp/transparent.png "tmp/output-0-0.png"
	fi
	if [ ! -e "tmp/output-${maxx}-${maxy}.png" ] ; then
		cp tmp/transparent.png "tmp/output-${maxx}-${maxy}.png"
	fi
	cp -v "tmp/output-${maxx}-${maxy}.png" "tmp/max-${maxx}-${maxy}.png"
else
	for img in tmp/max-*; do
		cp -v "${img}" "tmp/output-${img#tmp/max-}"
	done
fi
