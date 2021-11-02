#!/bin/bash

. functions.inc.sh

tileboundary=12288
FORMAT="png"
cmds=""

tmp="tmp/"

export RUNTHREADS=1

while getopts 'r:f:t:' OPTION ; do
	case ${OPTION} in
		r)
			export RUNTHREADS=${OPTARG}
			;;
		t)
			export FORMAT=${OPTARG}
			;;
		t)
			export tileboundary=${OPTARG}
			;;
	esac
done

shift $(( OPTIND - 1 ))

checkOutputFileExists() {
	local x y retVal
	x="${1}"
	y="${2}"
	[ -f "${tmp}/Makefile_${x}_${y}" ] && return 0

	addCmd ${x} ${y} "convert -size ${tileboundary}x${tileboundary} xc:transparent"
	return 0
}
addCmd(){
	local cmd x y
	x="${1}"
	y="${2}"
	shift 2
	cmd="cmd_${x}_${y}"
	if [ "${cmds//${cmd}/}" == "${cmds}" ]; then
		cmds="${cmds} ${cmd} "
	fi
	echo "tmp/output-${x}-${y}.${FORMAT}:" > "${tmp}/Makefile_${x}_${y}"
	eval "${cmd}=\"\${${cmd}} ${@}\""
	if [ $(( $( eval echo "\${${cmd}}" | tr " " '\n' | grep -c page ) % 4 )) -eq 3 ]; then
		eval "${cmd}=\"\${${cmd}} -background transparent -flatten\""
	fi
}
runCmds(){
	echo "Running commands"
	echo -n "all: " >> "${tmp}/Makefile_all"
	if [ -z "${cmds}" ] ; then
		echo "No commands scheduled. Skipping."
		return;
	fi
	echo "Scheduled commands: ${cmds}"
	export MAGICK_MEMORY_LIMIT=$((16/${RUNTHREADS}))G
	for THREAD in $( seq 0 $(( ${RUNTHREADS}-1 )) ); do
		(
			NUMCMD=0
			for var in ${!cmd_*} ; do
				NUMCMD=$((${NUMCMD}+1))
				[ $(( ${NUMCMD} % ${RUNTHREADS} )) -eq ${THREAD} ] || continue
				cmd="${var//_/ }"
				read c x y <<< "${cmd}"
				eval echo -e "\\\\t\${${var}} -background transparent -layers merge -flatten ${FORMAT}:tmp/output-${x}-${y}.${FORMAT}" >> "${tmp}/Makefile_${x}_${y}"
				echo -n "tmp/output-${x}-${y}.${FORMAT} " >> "${tmp}/Makefile_all"
			done | bash
			echo "Thread ${THREAD} finished!"
		) &
	done
	wait
	echo >> "${tmp}/Makefile_all"
	unset cmds ${!cmd_*}
}
if [ -f "result.${FORMAT}" ] ; then
	echo "File \`result.${FORMAT}' still exists from previous run! Aborting!" >&2
	exit
fi

maxx=0
maxy=0
for current in current-*png ; do
	[ -e "${current}" ] || continue
	currX=${current#*-}; currX=${currX%%-*};
	currY=${current##*-}; currY=${currY%.png};
	[ ${currX} -gt ${maxx} ] && maxx=${currX}
	[ ${currY} -gt ${maxy} ] && maxy=${currY}
done
echo "Max X-Y: ${maxx}x${maxy}"

trap 'kill 0; exit 1' SIGTERM SIGINT

for pic in "${@}" ; do
	echo "Processing '${pic}'"
	read width height < <( identify -format "%w %h" "${pic}" )
	read a x y < <( grep "^${pic} " tmp/vectorcache.txt )

	# Check if ${pic} is overlapping tile boundaries
	overlaps=0
	[ $(( ${x} / ${tileboundary} )) -ne $(( ( ${x} + ${width} -1 ) / ${tileboundary} )) ] && overlaps=1 # overlaps to the right!
	[ $(( ${y} / ${tileboundary} )) -ne $(( ( ${y} + ${height} -1 ) / ${tileboundary} )) ] && overlaps=1 # overlaps to the bottom!
	if [ ${overlaps} -eq 0 ] ; then # does not overlap
		tilex=$(( ( ${x} / ${tileboundary} ) * ${tileboundary} ))
		tiley=$(( ( ${y} / ${tileboundary} ) * ${tileboundary} ))
		checkOutputFileExists ${tilex} ${tiley}
		px=$((${x}-${tilex})); [ ${px} -ge 0 ] && px="+${px}"
		py=$((${y}-${tiley})); [ ${py} -ge 0 ] && py="+${py}"
		addCmd ${tilex} ${tiley} "-page ${px}${py} \"${pic}\""
		echo -e "\tNo overlap, stitching on output-${tilex}-${tiley} at ${px}${py}"
	else # ${pic} overlaps tile boundaries
		if [ ${overlaps} -eq 1 ]; then
			tilex=$(( ( ${x} / ${tileboundary} ) * ${tileboundary} ))
			tiley=$(( ( ${y} / ${tileboundary} ) * ${tileboundary} ))

			cutX=$(( ${width} - ( ${x} + ${width} ) % ${tileboundary} ))
			cutY=$(( ${height} - ( ${y} + ${height} ) % ${tileboundary} ))
			if [ $(( ${x} / ${tileboundary} )) -ne $(( ( ${x} + ${width} -1 ) / ${tileboundary} )) -a \
				   $(( ${y} / ${tileboundary} )) -ne $(( ( ${y} + ${height} -1 ) / ${tileboundary} )) ]; then
				# create 4 crops for top-left top-right bottom-left bottom-right
				echo -e "\tOverlap on 2 edges"
				checkOutputFileExists ${tilex} ${tiley}
				checkOutputFileExists $((${tilex}+${tileboundary})) ${tiley}
				checkOutputFileExists $((${tilex}+${tileboundary})) $((${tiley}+${tileboundary}))
				checkOutputFileExists ${tilex} $((${tiley}+${tileboundary}))
				px=$((${x}-${tilex})); [ ${px} -ge 0 ] && px="+${px}"
				py=$((${y}-${tiley})); [ ${py} -ge 0 ] && py="+${py}"
				addCmd ${tilex} ${tiley} "-page ${px}${py} \"${pic}\""
				echo -e "\tstitching on output-${tilex}-${tiley} at ${px}${py}"
				tilex=$((${tilex}+${tileboundary}))
				px=$((${x}-${tilex})); [ ${px} -ge 0 ] && px="+${px}"
				py=$((${y}-${tiley})); [ ${py} -ge 0 ] && py="+${py}"
				addCmd ${tilex} ${tiley} "-page ${px}${py} \"${pic}\""
				echo -e "\tstitching on output-${tilex}-${tiley} at ${px}${py}"
				tilex=$((${tilex}-${tileboundary}))
				tiley=$((${tiley}+${tileboundary}))
				px=$((${x}-${tilex})); [ ${px} -ge 0 ] && px="+${px}"
				py=$((${y}-${tiley})); [ ${py} -ge 0 ] && py="+${py}"
				addCmd ${tilex} ${tiley} "-page ${px}${py} \"${pic}\""
				echo -e "\tstitching on output-${tilex}-${tiley} at ${px}${py}"
				tilex=$((${tilex}+${tileboundary}))
				px=$((${x}-${tilex})); [ ${px} -ge 0 ] && px="+${px}"
				py=$((${y}-${tiley})); [ ${py} -ge 0 ] && py="+${py}"
				addCmd ${tilex} ${tiley} "-page ${px}${py} \"${pic}\""
				echo -e "\tstitching on output-${tilex}-${tiley} at ${px}${py}"
				tilex=$((${tilex}-${tileboundary}))
				tiley=$((${tiley}-${tileboundary}))
			elif [ $(( ${x} / ${tileboundary} )) -ne $(( ( ${x} + ${width} -1 ) / ${tileboundary} )) ]; then # overlaps to the right!
				echo -e "\tOverlap on the right"
				checkOutputFileExists ${tilex} ${tiley}
				checkOutputFileExists $((${tilex}+${tileboundary})) ${tiley}
				px=$((${x}-${tilex})); [ ${px} -ge 0 ] && px="+${px}"
				py=$((${y}-${tiley})); [ ${py} -ge 0 ] && py="+${py}"
				addCmd ${tilex} ${tiley} "-page ${px}${py} \"${pic}\""
				echo -e "\tstitching on output-${tilex}-${tiley} at ${px}${py}"
				tilex=$((${tilex}+${tileboundary}))
				px=$((${x}-${tilex})); [ ${px} -ge 0 ] && px="+${px}"
				py=$((${y}-${tiley})); [ ${py} -ge 0 ] && py="+${py}"
				addCmd ${tilex} ${tiley} "-page ${px}${py} \"${pic}\""
				echo -e "\tstitching on output-${tilex}-${tiley} at ${px}${py}"
				tilex=$((${tilex}-${tileboundary}))
			elif [ $(( ${y} / ${tileboundary} )) -ne $(( ( ${y} + ${height} -1 ) / ${tileboundary} )) ]; then # overlaps to the bottom!
				echo -e "\tOverlap on the bottom"
				checkOutputFileExists ${tilex} ${tiley}
				checkOutputFileExists ${tilex} $((${tiley}+${tileboundary}))
				px=$((${x}-${tilex})); [ ${px} -ge 0 ] && px="+${px}"
				py=$((${y}-${tiley})); [ ${py} -ge 0 ] && py="+${py}"
				addCmd ${tilex} ${tiley} "-page ${px}${py} \"${pic}\""
				echo -e "\tstitching on output-${tilex}-${tiley} at ${px}${py}"
				tiley=$((${tiley}+${tileboundary}))
				px=$((${x}-${tilex})); [ ${px} -ge 0 ] && px="+${px}"
				py=$((${y}-${tiley})); [ ${py} -ge 0 ] && py="+${py}"
				addCmd ${tilex} ${tiley} "-page ${px}${py} \"${pic}\""
				echo -e "\tstitching on output-${tilex}-${tiley} at ${px}${py}"
				tiley=$((${tiley}-${tileboundary}))
			fi
		fi
	fi
done
runCmds

cat "${tmp}/"Makefile* > Makefile.stitch
rm "${tmp}/"Makefile*

echo "Finished!"
exit 0
