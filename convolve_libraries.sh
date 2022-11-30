#!/bin/bash
################################################################################
# Script to convolve spectral libraries for Tetracorder 5.27a                  #
# 30 November 2022                                                             #
# Version 1                                                                    #
# By ASU Carbon Mapper Land and Oceans Team                                    #
################################################################################

HDR_FILE=${1} # ENVI hdr file with wavelengths and fwhm
SL1_DIR=${2} # path to sl1
TET_CMD_BASE=${3} # path to tetracorder base directory
SENSOR_ID=${4} # sensor ID name
SENSOR_YR=${5} # year for sensor configuration. l
SENSOR_LET=${6} # one letter for sensor configuration version
SETUP_DIR=${7:-tetracorder5.27a.cmds} # folder where cmd-setup-tetrun is
DEL_RANGES=${8:-0-400,1300-1500,1800-2000}

################################################################################
# Help                                                                         #
################################################################################
Help()
{
   # Display Help
   echo "Convolve reference spectral libraries for Tetracorder 5.27a"
   echo "By ASU Carbon Mapper Land and Oceans Team    "
   echo "Version 1, November 2022"
   echo
   echo "Syntax: sh convolve_libraries.sh [-h] [HDR_FILE] [SL1_DIR] [TET_CMD_BASE] "
   echo "             [SENSOR_ID] [SENSOR_YR] [SENSOR_LET] [SETUP_DIR] [DEL_RANGES]"
   echo "inputs:"
   echo "1    ENVI hdr file with wavelengths and resolution in nanometers"
   echo "2    Directory sl1 with reference libraries"
   echo "3    Tetracorder commands base directory"
   echo "4    Short keyword for sensor"
   echo "5    Sensor configuration year"
   echo "6    Letter to indicate sensor configuration version within a year"
   echo "7    (Optional) Version of tetracorder commands"
   echo "8    (Optional) Comma separated list of deleted channel wavelengths in nm"
   echo "options:"
   echo "h     Print this Help."
   echo
    echo "example usage:"
    echo "                              1         2        3            4           5           6          7        8 "
    echo "sh convolve_libraries.sh  HDR_FILE   SL1_DIR  TET_CMD_BASE SENSOR_ID  SENSOR_YR SENSOR_LET [SETUP_DIR] [DEL_RANGES]"
    echo "sh convolve_libraries.sh example.hdr   sl1        t1        anextgen     2020        a   [tetracorder5.27a.cmds] [0-400,1300-1500,1800-2000]"
    echo 
    echo "an example hdr file may be located at: example/input/ang20200712t201415_corr_v2y1_img.hdr "
    echo "default values are indicated for optional inputs: SETUP_DIR and DEL_RANGES"
   echo
}

# Get the options
while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done

if [ -z "$6" ]
then
	echo "ERROR: not enough parameters supplied"
    echo 
	echo "example usage:"
#                                       1         2        3            4           5           6          7        8
	echo "sh convolve_libraries.sh  HDR_FILE   SL1_DIR  TET_CMD_BASE SENSOR_ID  SENSOR_YR SENSOR_LET [SETUP_DIR] [DEL_RANGES]"
    echo "sh convolve_libraries.sh example.hdr   sl1        t1        anextgen     2020        a   [tetracorder5.27a.cmds] [0-400,1300-1500,1800-2000]"
    echo 
	echo "exit 1"
	exit 1
fi

################################################################################
# Setup                                                                        #
################################################################################

# define paths
current_dir=${PWD}
HDR_ABS_FILE=`readlink -f ${HDR_FILE}`
SL1_ABS_DIR=`readlink -f ${SL1_DIR}`
TET_ABS_BASE=`readlink -f ${TET_CMD_BASE}`

# cd into library06.conv dir
cd $SL1_ABS_DIR/usgs/library06.conv

# Save waves.txt and resol.txt                                                 #
echo "Making waves.txt and resol.txt from hdr file"

awk '/wavelength =/, /}/ {print}' ${HDR_ABS_FILE} | \
	sed -e 's/[^0-9.]/ /g' -e 's/^ *//g' -e 's/ *$//g' | \
	tr -s ' ' | sed 's/ /\n/g' | \
	sed '/^$/d' | \
	awk '{ print $1/1000 }' \
	> waves.txt

# save resol.txt from hdr
awk '/fwhm =/, /}/ {print}' ${HDR_ABS_FILE} | \
	sed -e 's/[^0-9.]/ /g' -e 's/^ *//g' -e 's/ *$//g' | \
	tr -s ' ' | sed 's/ /\n/g' | \
	sed '/^$/d' | \
	awk '{ print $1/1000 }' \
	> resol.txt

# define number of channels
N_CHANS=`wc -l waves.txt | sed 's/[^0-9]/ /g'`

# define 2 letter sensor ID
SENSOR2=${SENSOR_ID:0:2}
# define 2 digit year ID as last 2 digits of year
YR2=${SENSOR_YR: -2}
# make sure sensor letter is one letter
LET1=${SENSOR_LET:0:1}

# define spectal library 6 name
S_LIBNAME=s06${SENSOR2}${YR2}${LET1}
# define research library name
R_LIBNAME=r06${SENSOR2}${YR2}${LET1}

################################################################################
# SPECTRAL LIBRARY 06 CONVOLUTIONS #
################################################################################

# replace first line with copy of second line in splib06b.list-h.1
NEWLINE=`head -2 splib06b.list-h.1 | tail -1`
sed -i.bak "/98  Acmite/c\\${NEWLINE}" splib06b.list-h.1

# make start file 
./make.new.convol.library.start.file  ${S_LIBNAME} ${N_CHANS} \
	"Convolved ${SENSOR_ID} ${SENSOR_YR} ${N_CHANS} ch library" \
	"Wavelengths in microns ${N_CHANS} ch ${SENSOR_ID}${YR2}${LET1}" \
	"Resolution in microns ${N_CHANS} ch ${SENSOR_ID}${YR2}${LET1}" force

# set pointers for wavelength and resolution
spsetwave startfiles/${S_LIBNAME}.start   6  6  12  force
spsetwave startfiles/${S_LIBNAME}.start   12  6  12  force
spsetwave startfiles/${S_LIBNAME}.start   18  6  12  force

# make convolved library 06
./mak.convol.library ${S_LIBNAME:0:7} ${LET1} ${N_CHANS} ${SENSOR_ID}${YR2} 12 noX

echo "Spectral Library 06 convolution complete"
echo "Moving onto Research Library 06 convolution"

################################################################################
# RESEARCH LIBRARY 06 CONVOLUTIONS #
################################################################################

# change to research library directory
cd $SL1_ABS_DIR/usgs/rlib06

# copy startfile 
cp $SL1_ABS_DIR/usgs/library06.conv/startfiles/${S_LIBNAME}.start startfiles/${R_LIBNAME}.start

# set title 
spsettitle startfiles/${R_LIBNAME}.start 1 "Digital Spectral Library: ${R_LIBNAME} " force
# set pointers for wavelength and resolution
spsetwave startfiles/${R_LIBNAME}.start   6  6  12  force
spsetwave startfiles/${R_LIBNAME}.start   12  6  12  force

# copy restart file
cp $SL1_ABS_DIR/usgs/library06.conv/restartfiles/r.${S_LIBNAME} restartfiles/r.${R_LIBNAME}

# make replacements in restart file
mv restartfiles/r.${R_LIBNAME} restartfiles/r.foo
cat restartfiles/r.foo | sed -e "s/ivfl=${S_LIBNAME}/ivfl=${R_LIBNAME}     /" \
		-e "s/iyfl=splib06b/iyfl=sprlb06b/" \
		-e "s/isavt=      ${S_LIBNAME}/isavt=      ${R_LIBNAME}  /" \
		-e "s/irfl=r.${S_LIBNAME}/irfl=r.${R_LIBNAME} /"           \
		-e "s/inmy=       splib06b/inmy=       sprlb06b /" \
		> restartfiles/r.${R_LIBNAME}

# make convolved research library	
./mak.convol.library ${R_LIBNAME:0:7} ${LET1} ${N_CHANS} ${SENSOR2}${YR2}${LET1} 12 noX

echo "Research Library 06 convolution complete"
echo "Libary convolutions complete for ${SENSOR_ID}_${SENSOR_YR}${LET1}"
echo "Moving onto making other necessary files"

####################################
# OTHER NECESSARY FILES            #
####################################

# Make DATASETS file
echo "restart= r1-${SENSOR2}${YR2}${LET1}" \
	> $TET_ABS_BASE/tetracorder.cmds/$SETUP_DIR/DATASETS/${SENSOR_ID}_${SENSOR_YR}${LET1}

echo "DATASETS file made to use ${SENSOR_ID}_${SENSOR_YR}${LET1}"

# path to restart file in t1 directory
RESTART_PATH=$TET_ABS_BASE/tetracorder.cmds/$SETUP_DIR/restart_files/r1-${SENSOR2}${YR2}${LET1}

# Copy restart file from 06.conv to t1 directory
cp $SL1_ABS_DIR/usgs/library06.conv/restartfiles/r.$S_LIBNAME $RESTART_PATH

# correct restart file name in restart file
sed -i.bak "12 s/irfl=r.s06/irfl=r1-/g" $RESTART_PATH
# correct rlib name in restart file
sed -i.bak "26 s/*unasnd\*/$R_LIBNAME/g" $RESTART_PATH
# correct slib name in restart file
sed -i.bak "29 s/splib06b/$S_LIBNAME/g" $RESTART_PATH

##############################################
# Make DELETED.CHANNELS file using waves.txt #
##############################################
cd $SL1_ABS_DIR/usgs/library06.conv

make_del_range () {
    # Get band numbers from a wave definition file (arg 1) for start / end pair of wavelengths (args 2-3)
    # example usage:
    # make_del_range waves.txt 0 400
    DEL1ID=$(awk ' {print $1*1000}' "$1" | awk -v del1="$2" -v del2="$3" '$1 > del1 && $1 < del2 { print NR}' | sort -n | head -1)
    DEL2ID=$(awk ' {print $1*1000}' "$1" | awk -v del1="$2" -v del2="$3" '$1 > del1 && $1 < del2 { print NR}' | sort -n | tail -1)
    if [ "$2" == "" ]; then
        echo "ERROR: No band found for starting wavelength $2" >&2
        exit 1
    elif [ "$3" == "" ]; then
        echo "ERROR: No band found for ending wavelength $3" >&2
        exit 2
    fi
    echo ${DEL1ID}t${DEL2ID}
}

make_del_channels () {
    # Create deleted channels file (arg 1) from wavelen def file (arg 2) and ranges specified with a comma-delimited list (arg 3)
    # example usage:
    # make_del_channels output.txt waves.txt "0-400, 1300-1500, 1800-2000"

    # For each row of del_ranges, with del1 and del2
    rm -f $1
    echo ${DEL_RANGES} | sed 's/,/\n/g' | sed 's/[^0-9]/ /g' | awk '{print $1, $2}' | \
    while read range; do
        res=$(make_del_range waves.txt ${range})
        echo -n $res" " >> $1
    done
    echo  " c # ${SENSOR_ID}_${SENSOR_YR}${LET1}" >> $1
}
## Overall call:
make_del_channels $TET_ABS_BASE/tetracorder.cmds/$SETUP_DIR/DELETED.channels/delete_${SENSOR_ID}_${SENSOR_YR}${LET1} waves.txt ${DEL_RANGES}

echo "DELETED.channels file made for ${SENSOR_ID}_${SENSOR_YR}${LET1}"

cd $current_dir


echo "Libary convolutions complete for ${SENSOR_ID}_${SENSOR_YR}${LET1}"
echo "Use dataset keyword ${SENSOR_ID}_${SENSOR_YR}${LET1} to use these libraries in tetracorder"
echo "Dataset is at path: $TET_ABS_BASE/tetracorder.cmds/$SETUP_DIR/DATASETS/${SENSOR_ID}_${SENSOR_YR}${LET1}


