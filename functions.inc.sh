#!/bin/bash

getMatch(){ #{{{
	# Now run the match binary on the .pgm and the SIFT .keys files
	# This gives us a list of translation matrices of the form
	# SRC_POINT_XxSRC_POINT_Y -> DEST_POINT_XxDEST_POINT_Y
	# First, we eneed 8-bit .pgm files for the sift binary
	pic1="${1}"
	pic2="${2}"
	read x y count rest < <( grep "'${pic1}' - '${pic2}'" vectorcache.txt )

	if [ -n "${x}" ]; then
		echo "${x} ${y} ${count} (cached)"
		return;
	fi

	# Not cached, so calculate it
	[ ! -f "${pic1}.pgm" ] && convert "${pic1}" -depth 8 pgm:"${pic1}.pgm"
	[ ! -f "${pic2}.pgm" ] && convert "${pic2}" -depth 8 pgm:"${pic2}.pgm"

	# Then we run the SIFT algorithm on them
	[ ! -f "${pic1}.keys" ] && ./sift < "${pic1}.pgm" > "${pic1}.keys"
	[ ! -f "${pic2}.keys" ] && ./sift < "${pic2}.pgm" > "${pic2}.keys"

	read count y x < <(
		./match -im1 "${pic1}.pgm" -k1 "${pic1}.keys" -im2 "${pic2}.pgm" -k2 "${pic2}.keys" 2>&1 >/dev/null | grep -v Found | \
			while read src arrow dest ; do
				srcx="${src%x*}";
				srcy="${src#*x}";
				destx="${dest%x*}";
				desty="${dest#*x}";
				# We calculate and echo the translation vector
				echo -e "\t$((${srcx}-${destx})) $((${srcy}-${desty}))";
				# and the sort and count the vectors and then return them with the
				# most often found vector first
			done | sort | uniq -c | sort -rn | head -1
	)
	# We use the most often found vector and add it to the cache
	echo "${x} ${y} ${count} '${pic1}' - '${pic2}'" >> vectorcache.txt
	echo "${x} ${y} ${count}"
} # }}}

getAllMatches(){ #{{{
	pic1="${1}"
	pic2="${2}"
	# Not cached, so calculate it
	[ ! -f "${pic1}.pgm" ] && convert "${pic1}" -depth 8 pgm:"${pic1}.pgm"
	[ ! -f "${pic2}.pgm" ] && convert "${pic2}" -depth 8 pgm:"${pic2}.pgm"

	# Then we run the SIFT algorithm on them
	[ ! -f "${pic1}.keys" ] && ./sift < "${pic1}.pgm" > "${pic1}.keys"
	[ ! -f "${pic2}.keys" ] && ./sift < "${pic2}.pgm" > "${pic2}.keys"
	./match -k1 "${pic1%.keys}.keys" -k2 "${pic2%.keys}.keys" 2>&1 | grep -v Found | \
		while read src arrow dest ; do
			srcx="${src%x*}";
			srcy="${src#*x}";
			destx="${dest%x*}";
			desty="${dest#*x}";
			echo -e "\t$((${srcx}-${destx})) $((${srcy}-${desty}))";
		done | sort | uniq -c | sort -n
} #}}}

addPOI(){
	# 344753.91401622095 58560.80256128633 2136.4363636363996 978.6763636363612 West Point: Elementary School
	read x y width height text <<< "${@}"
	x="${x%.*}"
	y="${y%.*}"
	width="${width%.*}"
	height="${height%.*}"
	ox=$((${x}-(${x}%25600)))
	oy=$((${y}-(${y}%25600)))

	read id < <( echo "${text//[^A-Za-z0-9-]/-}" | tr '[A-Z]' '[a-z]' | sed -e 's,-\+,-,g' )
	while grep -q -- "${id}" *lays ; do
		echo "ID '${id}' already exists:"
		grep -H -- "${id}" *lays
		read -p 'Please enter new Text> ' text
		read id < <( echo "${text//[^A-Za-z0-9-]/-}" | tr '[A-Z]' '[a-z]' | sed -e 's,-\+,-,g' )
	done
	echo "Adding to current-${ox}-${oy}.overlays"
	echo $((${x}%25600)) $((${y}%25600)) ${width} ${height} ${id} ${text} >> current-${ox}-${oy}.overlays
	tail -1 current-${ox}-${oy}.overlays
}

matchAll(){
	THREADS=4
	lastpic="${1}"
	shift

	for THREAD in $( seq 0 $((${THREADS}-1)) ); do
		(
		numpic=0
		for pic in "${@}" ; do
			numpic=$((${numpic}+1))
			if [ $((${numpic}%${THREADS})) -eq ${THREAD} ] ; then
				read count y x < <( getMatch "${lastpic%.keys}" "${pic%.keys}" )
				echo "T:${THREAD} ${x} ${y} ${count} ${lastpic%.keys} ${pic%.keys}"
			fi
			lastpic="${pic}"
		done
		) &
	done
	wait
}

createOverlaysJSON(){
	echo -n "[" > overlays.json
	first=1
	for file in *.overlays ; do
		x=${file#*-}
		x=${x%-*}
		y=${file%.overlays}
		y=${y##*-}
		while read ox oy w h id text ; do
			[ ${first} -eq 0 ] && echo -n "," >> overlays.json
			first=0
			echo -n "{\"id\":\"overlay-${id}\",\"text\":\"${text}\",\"px\":$((${ox}+${x})),\"py\":$((${oy}+${y})),\"width\":${w},\"height\":${h},\"className\":\"highlight\"}" >> overlays.json
		done < "${file}"
	done
	echo -n "]" >> overlays.json
}
