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
	cp -v "tmp/output-${maxx}-${maxy}.png" "tmp/max-${x}-${y}.png"
else
	for img in tmp/max-*; do
		cp -v "${img}" "tmp/output-${img#tmp/max-}"
	done
fi
