# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    test.sh                                            :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: gshona <gshona@student.21-school.ru>       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/03/17 14:04:59 by gshona            #+#    #+#              #
#    Updated: 2021/03/17 17:45:03 by gshona           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #
#!/bin/bash

############## USER SETTINGS ##########################

#Root of project
#Корневая директория проекта
DIR="../cub_test"

#Name of the executable
#Имя исполняемого файла
EXEC_NAME="cub3d"

#Path to sample to a valid map from DIR directory
#Путь до образца валидной карты от директории DIR
SAMPLE_MAP="maps/1.cub"

#Path to screenshot when executing with "--save" from DIR
#Путь к скриншоту, создаваемому с ключом "--save" из DIR
SCREENSHOT="picture.bmp"

#######################################################



TEMPLATES="map_templates"
SCREENSHOTS="screenshots"
MAP="./map.cub"
SAVE_KEY=""
DISPLAY_MAP=0
fail_count=0


function single_map()
{
	f=$(find map_templates -type f -name '*.cub' | grep $1 | head -n 1)
	#echo "SINGLE " $1  "  " $f
	#TESTNAME= $(basename $f | sed 's/\.cub//g')
	TESTNAME=$(basename $f | sed 's/\.cub//g')
	echo "======================= " $TESTNAME " =========================\n"
	cp $f $MAP
	SHOT=$(basename $f | sed 's/\.cub/\.bmp/g')
	#echo $SHOT ">>>>>>>>>>>>>>"
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

#echo "||||||||  " $@

make -C $DIR

SAMPLE=$DIR/$SAMPLE_MAP

NO=$(cat $SAMPLE | grep 'NO ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
WE=$(cat $SAMPLE | grep 'WE ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
EA=$(cat $SAMPLE | grep 'EA ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
SO=$(cat $SAMPLE | grep 'SO ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
S=$(cat $SAMPLE | grep 'S ' | awk '{print ($2)}' | sed 's/\.\///g' | sed 's/\//\\\//g')
#echo $DIR\/$S"<<<<<<< "
DIR_S=$(echo $DIR | sed 's/\./\\\./g' | sed 's/\//\\\//g')

#echo $DIR_S "==============="

for arg in $@ ; do
	case $arg in
		"--save")SAVE_KEY='--save';;
		"--map")DISPLAY_MAP=1;;
	esac
done


if [ -z $1 ]
then
SAVE_KEY=""
else
	if [[ $1 == '--save' ]]
	then
		SAVE_KEY='--save'
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


function common_step()
{
	f=$1
	#TESTNAME= $(basename $f | sed 's/\.cub//g')
	TESTNAME=$(basename $f | sed 's/\.cub//g')
	echo "======================= " $TESTNAME " =========================\n"
	cp $f $MAP
	SHOT=$(basename $f | sed 's/\.cub/\.bmp/g')
	#echo $SHOT ">>>>>>>>>>>>>>"
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
echo "+++++++++++++++++ VALID MAPS +++++++++++++++++++++++\n"
for f in $TEMPLATES/valid/*; do
	common_step $f
done

echo "+++++++++++++++++ INVALID MAPS +++++++++++++++++++++++\n"
for f in $TEMPLATES/invalid/*; do
	common_step $f
done

echo "+++++++++++++++++ UNDEFINED MAPS +++++++++++++++++++++++\n"
for f in $TEMPLATES/undefined/*; do
	common_step $f
done
rm $MAP
