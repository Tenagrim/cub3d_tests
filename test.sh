# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test.sh                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: gshona <gshona@student.21-school.ru>       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/03/17 14:04:59 by gshona            #+#    #+#              #
#    Updated: 2021/03/17 18:54:11 by gshona           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #
#!/bin/bash









############## USER SETTINGS ##########################

#Root of project
DIR="../cub_test"

#Name of the executable
EXEC_NAME="cub3d"

#Path to sample to a valid map from DIR directory
SAMPLE_MAP="maps/1.cub"

#Path to screenshot when executing with "--save" from DIR
SCREENSHOT="picture.bmp"

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

function single_map()
{
	f=$(find map_templates -type f -name '*.cub' | grep $1 | head -n 1)
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
		cat $MAP
		echo ''
	fi
	$DIR/$EXEC_NAME $MAP $SAVE_KEY
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
		cat $MAP
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

if [ -z $1 ]
then
SAVE_KEY=""
else
	if [[ $(echo $1 | cut -c -2) == '--' ]]
	then
		echo ''
		for arg in $@ ; do
			case $arg in
				"--save")SAVE_KEY='--save';;
				"--map")DISPLAY_MAP=1;;
				"--valid")only_valid=1;skip=1;;
				"--invalid")only_invalid=1;skip=1;;
				"--undefined")only_undef=1;skip=1;;
				*)echo "unrecognized key: " $arg; exit 2;;
			esac
		done
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

make -C $DIR
mkdir $SCREENSHOTS 2> /dev/null
SAMPLE=$DIR/$SAMPLE_MAP

NO=$(cat $SAMPLE | grep 'NO ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
WE=$(cat $SAMPLE | grep 'WE ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
EA=$(cat $SAMPLE | grep 'EA ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
SO=$(cat $SAMPLE | grep 'SO ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
S=$(cat $SAMPLE | grep 'S ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
DIR_S=$(echo $DIR | sed 's/\./\\\./g' | sed 's/\//\\\//g')

if (( skip == 0 || (skip == 1 && only_valid == 1 ) )); then
echo "+++++++++++++++++ VALID MAPS +++++++++++++++++++++++\n"
for f in $TEMPLATES/valid/*; do
	common_step $f
done
fi

if (( skip == 0 || (skip == 1 && only_invalid == 1 ) )); then
echo "+++++++++++++++++ INVALID MAPS +++++++++++++++++++++++\n"
for f in $TEMPLATES/invalid/*; do
	common_step $f
done
fi

if (( skip == 0 || (skip == 1 && only_undef == 1 ) )); then
echo "+++++++++++++++++ UNDEFINED MAPS +++++++++++++++++++++++\n"
for f in $TEMPLATES/undefined/*; do
	common_step $f
done
rm $MAP
fi
