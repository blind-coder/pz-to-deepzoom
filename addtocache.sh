#!/bin/bash

export offx=0 offy=0
function process(){
	rm -f tmp/vectorcache.tmp
	for img in "${@}" ; do
		read cell x y subcell sx sy rest < <( echo "${img##*/}" | tr "_" " " )

		x=$((x*300 + sx*75))
		y=$((y*300 + sy*75))

		newx=$(( (x*64) - (y*64) ))
		newy=$(( (x*32) + (y*32) ))
		echo "${img} $((newx-offx)) $((newy-offy))" >> tmp/vectorcache.tmp
	done
}

process "${@}"
read path z offy < <( sort -nk 3 tmp/vectorcache.tmp )
read path offx z < <( sort -nk 2 tmp/vectorcache.tmp )
export offx offy
process "${@}"
