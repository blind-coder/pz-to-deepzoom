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
	[ ${y} -gt ${maxy} ] && maxy=${y}
done < <( ls -1U map_files/21/ | grep 'jpg$')

cd ${tmp}
for lvl in $(seq 20 -1 0); do
	mkdir -p map_files/${lvl}
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
			echo -e "# X ${x}/${maxx} Y ${y}/${maxy}"
			echo -en "\tconvert xc:transparent -background transparent "
			[ -f "${tl}" ] && echo -n " -page +0+0 ${tl} "
			[ -f "${tr}" ] && echo -n " -page +${tlw}+0 ${tr} "
			[ -f "${bl}" ] && echo -n " -page +0+${tlh} ${bl} "
			[ -f "${br}" ] && echo -n " -page +${tlw}+${tlh} ${br} "
			echo " -layers merge +repage -resize 50% jpg:${n}"
			if [ ${x} -ne ${maxx} -o ${y} -ne ${maxy} ]; then

if false; then
	read dimx dimy < <( identify -format "%w %h" "map_files/15/10_9.jpg" )
	ndimx=${dimx}
	ndimy=${dimy}
	[ 20 -ne 48 ] && ndimx=1024
	[ 18 -ne 31 ] && ndimy=1024
	if [ ${ndimx} -ne ${dimx} -o ${ndimy} -ne ${dimy} ]; then
		convert -size ${ndimx}x${ndimy} xc:transparent -page +0+0 map_files/15/10_9.jpg -background transparent -flatten -background transparent -layers merge -flatten jpg:map_files/15/10_9.jpg
	fi
fi
				echo -en "\tbash -c 'read dimx dimy < <( identify -format \"%w %h\" \"${n}\" ); "
				echo -en "ndimx=\$\${dimx}; "
				echo -en "ndimy=\$\${dimy}; "
				echo -en "[ $((${x}+1)) -lt ${maxx} ] && ndimx=1024; "
				echo -en "[ $((${y}+1)) -lt ${maxy} ] && ndimy=1024; "
				echo -en "if [ \$\${ndimx} -ne \$\${dimx} -o \$\${ndimy} -ne \$\${dimy} ]; then ";
					echo -en "convert -size \$\${ndimx}x\$\${ndimy} xc:transparent -page +0+0 ${n} -background transparent -flatten -background transparent -layers merge -flatten jpg:${n}; "
				echo -en "fi;' "
				echo
			fi
			touch ${n}
		done < <( seq 0 2 ${maxy} )
	done < <( seq 0 2 ${maxx} )

	maxx=0
	maxy=0
	while read file; do 
		file=${file%.*}
		read x y <<< "${file/_/ }"
		[ ${x} -gt ${maxx} ] && maxx=${x}
		[ ${y} -gt ${maxy} ] && maxy=${y}
	done < <( ls -1U "map_files/${lvl}/" | grep 'jpg$')
done
cd - > /dev/null
