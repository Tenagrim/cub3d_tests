# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test.sh                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: gshona <gshona@student.21-school.ru>       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/03/17 14:04:59 by gshona            #+#    #+#              #
#    Updated: 2021/03/18 13:15:12 by gshona           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #
#!/bin/bash

############## USER SETTINGS ##########################

#Root of project
DIR="../cub3d"


#Name of the executable
EXEC_NAME="cub3d"



#Path to sample to a valid map from DIR directory
SAMPLE_MAP="maps/1.cub"
# for example: if your executable is in DIR and your map is in DIR/maps
# then thi value must be maps/map.cub



#Name of screenshot which generated when executing with "--save" from DIR
SCREENSHOT="picture.bmp"

#######################################################

############# KEYS ####################################
#
#		--map		# prints map to stdin
#		--save		# runs cub3D with --save key
#		--valid		# runs cub3D with only valid maps
#		--invalid	# runs cub3D with only invalid maps
#		--undefined	# runs cub3D with only maps wich are nither valid nor invalid
#		--leaks		# runs cub3D and checks leaks (not implemented yet)
#
#######################################################

############# EXAMPLES ################################
#
# ./test.sh                    # run all maps
# ./test.sh --save             # run all maps with --save key
# ./test.sh --map              # run all tests and print maps to stdout
# ./test.sh squares            # run only one map called squares.cub
# ./test.sh squares --save     # same as previous but with --save key
# ./test.sh --valid --save     # run only valid maps with --save key
# ./test.sh --valid            # run only valid maps playable
#
#######################################################















############ VVVV!!! DANGER ZONE !!!VVVV ############

TEMPLATES="map_templates"
SCREENSHOTS="screenshots"
MAP="./map.cub"
SAVE_KEY=""
DISPLAY_MAP=0
fail_count=0
only_valid=0
only_ivalid=0
only_undef=0
skip=0
check_leaks=0
map_count=0

function single_map()
{
	f=$(find map_templates -type f -name '*.cub' | grep $1 | tail -n 1)
	#echo $f " <<<<<<<<<<<< "
	#echo $WE " <<<<<<<<<<<<<<<"
	common_step $f
}

function common_step()
{
	f=$1
	TESTNAME=$(basename $f | sed 's/\.cub//g')
	echo "======================= " $TESTNAME " =========================\n"
	cp $f $MAP
	SHOT=$(basename $f | sed 's/\.cub/\.bmp/g')
	sed -i '' "s/NNNNN/$DIR_S\/$NO/g" map.cub
	sed -i '' "s/WWWWW/$DIR_S\/$WE/g" map.cub
	sed -i '' "s/EEEEE/$DIR_S\/$EA/g" map.cub
	sed -i '' "s/SSSSS/$DIR_S\/$SO/g" map.cub
	sed -i '' "s/SPSPSP/$DIR_S\/$S/g" map.cub
	if (($DISPLAY_MAP == 1)); then
		echo "filename: " $f
		cat $MAP
		echo ''
	fi
	$DIR/$EXEC_NAME $MAP $SAVE_KEY
	if (( $? != 0)); then
		echo "FAIL"
		(( fail_count++ ))
	fi
	if [[ $SAVE_KEY == '--save' ]]
	then
		if test -f "$SCREENSHOT"; then
			mv $SCREENSHOT $SCREENSHOTS/$SHOT
		else
			echo "SCREENSHOT IS MISSING"
		fi
	fi
	echo ''
}


for arg in $@ ; do
	if [[ $(echo $arg | cut -c -2) == '--' ]] ; then
	case $arg in
		"--save")SAVE_KEY='--save';;
		"--map")DISPLAY_MAP=1;;
		"--leaks")check_leaks=1;;
		"--valid")only_valid=1;skip=1;;
		"--invalid")only_invalid=1;skip=1;;
		"--undefined")only_undef=1;skip=1;;
		*)echo "unrecognized key: " $arg; exit 2;;
	esac
fi
done





make -C $DIR
mkdir $SCREENSHOTS 2> /dev/null
SAMPLE=$DIR/$SAMPLE_MAP

NO=$(cat $SAMPLE | grep 'NO ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
WE=$(cat $SAMPLE | grep 'WE ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
EA=$(cat $SAMPLE | grep 'EA ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
SO=$(cat $SAMPLE | grep 'SO ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
S=$(cat $SAMPLE | grep 'S ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
DIR_S=$(echo $DIR | sed 's/\./\\\./g' | sed 's/\//\\\//g')








if [ -z $1 ]
then
SAVE_KEY=""
else
	if [[ $(echo $1 | cut -c -2) == '--' ]]
	then
		echo ''
	else
		if [[ -z $(find map_templates -type f -name '*.cub' | grep $1) ]]; then
			echo "Unknown argument " $1
			exit 1
		else
			single_map $1;
			exit 0
		fi
	fi
fi



if (( skip == 0 || (skip == 1 && only_valid == 1 ) )); then
echo "+++++++++++++++++ VALID MAPS +++++++++++++++++++++++\n"
map_count=$(ls -1 $TEMPLATES/valid | grep '.cub' | wc -l)
i=1
for f in $TEMPLATES/valid/*; do
	echo "======= [ " $i " / " $map_count " ] ======"
	common_step $f
	(( i++ ))
done
fi

if (( skip == 0 || (skip == 1 && only_invalid == 1 ) )); then
echo "+++++++++++++++++ INVALID MAPS +++++++++++++++++++++++\n"
map_count=$(ls -1 $TEMPLATES/invalid | grep '.cub' | wc -l)
i=1
for f in $TEMPLATES/invalid/*; do
	echo "======= [ " $i " / " $map_count " ] ======"
	common_step $f
	(( i++ ))
done
fi

if (( skip == 0 || (skip == 1 && only_undef == 1 ) )); then
echo "+++++++++++++++++ UNDEFINED MAPS +++++++++++++++++++++++\n"
map_count=$(ls -1 $TEMPLATES/undefined | grep '.cub' | wc -l)
i=1
for f in $TEMPLATES/undefined/*; do
	echo "======= [ " $i " / " $map_count " ] ======"
	common_step $f
	(( i++ ))
done
rm $MAP
fi
