#!/bin/bash -e

maxx=0
maxy=0
tlw=1024
tlh=1024
tmp="$(mktemp -d)"
mkdir -p ${tmp}/map_files/21
trap "rm -rf ${tmp}" EXIT

while read file; do 
	touch "${tmp}/map_files/21/${file}"
	file=${file%.*}
	read x y <<< "${file/_/ }"
	[ ${x} -gt ${maxx} ] && maxx=${x}
	[ ${y} -gt ${maxy} ] && maxy=${x}
done < <( ls -1 map_files/21/ | grep 'jpg$')

cd ${tmp}
for lvl in $(seq 20 -1 0); do
	mkdir -p map_files/${lvl}
	maxx=$((${maxx}/2))
	maxy=$((${maxy}/2))
	[ $((${maxx}%2)) -eq 1 ] && maxx=$((${maxx}+1))
	[ $((${maxy}%2)) -eq 1 ] && maxy=$((${maxy}+1))
	while read x ; do
		while read y ; do
			tl="map_files/$((${lvl}+1))/$((${x}+0))_$((${y}+0)).jpg"
			tr="map_files/$((${lvl}+1))/$((${x}+1))_$((${y}+0)).jpg"
			bl="map_files/$((${lvl}+1))/$((${x}+0))_$((${y}+1)).jpg"
			br="map_files/$((${lvl}+1))/$((${x}+1))_$((${y}+1)).jpg"
			n="map_files/${lvl}/$((x/2))_$((y/2)).jpg"
			[ -f ${tl} -o -f ${tr} -o -f ${bl} -o -f ${br} ] || continue
			echo -en "${n}: "
			[ -f "${tl}" ] && echo -en "${tl} "
			[ -f "${tr}" ] && echo -en "${tr} "
			[ -f "${bl}" ] && echo -en "${bl} "
			[ -f "${br}" ] && echo -en "${br} "
			echo
			echo -en "\tconvert xc:transparent -background transparent "
			[ -f "${tl}" ] && echo -n " -page +0+0 ${tl} "
			[ -f "${tr}" ] && echo -n " -page +${tlw}+0 ${tr} "
			[ -f "${bl}" ] && echo -n " -page +0+${tlh} ${bl} "
			[ -f "${br}" ] && echo -n " -page +${tlw}+${tlh} ${br} "
			echo " -layers merge +repage -resize 50% jpg:${n}"
			touch ${n}
		done < <( seq 0 2 ${maxy} )
	done < <( seq 0 2 ${maxx} )
done
cd - > /dev/null
