#!/bin/bash
################################################################################
# Script to Run Tetracorder 5.27a                        #
# 30 November 2022                                                             #
# Version 1                                                                    #
# ASU Carbon Mapper Land and Oceans Team                                       #
################################################################################

TET_OUT_DIR=${1} # output directory
REFL_FILE=${2} # reflectance file
DATASET=${3} # instrument and libraries to use
TET_CMD_BASE=${4} # location of t1 eg /data/gdcsdata/CarbonMapper/software/tetracorder-build-527
SCALE=${5:-1} # Scale factor of image
TMP_DIR=${6:-/tmp} # temp directory for copying image 
SETUP_DIR=${7:-tetracorder5.27a.cmds} # folder where cmd-setup-tetrun is
    
################################################################################
# Help                                                                         #
################################################################################
Help()
{
   # Display Help
   echo "Run Tetracorder 5.27a on reflectance file"
   echo "By ASU Carbon Mapper Land and Oceans Team    "
   echo "Version 1 (November 2022)"
   echo
   echo "Syntax: sh run_tetracorder.sh [-h] [TET_OUT_DIR] [REFL_FILE] [DATASET] "
   echo "             [TET_CMD_BASE] [SCALE] [TMP_DIR] [SETUP_DIR]"
   echo "inputs:"
   echo "1    new directory for outputs"
   echo "2    reflectance file to analyze"
   echo "3    dataset keyword"
   echo "4    Tetracorder commands base directory"
   echo "5    (Optional) Image scale factor"
   echo "6    (Optional) Temporary directory to handle file path character limits"
   echo "7    (Optional) Version of tetracorder commands"
   echo "options:"
   echo "h     Print this Help."
   echo
    echo "example usage:"
    echo "                              1                2             3              4           5         6          7     "
    echo "sh run_tetracorder.sh  TET_OUT_DIR        REFL_FILE       DATASET       TET_CMD_BASE  [SCALE] [TMP_DIR]   [SETUP_DIR]"
    echo "sh run_tetracorder.sh example/output  example/input/img anextgen_2020a      .            [1]    [/tmp] [tetracorder5.27a.cmds]"
    echo 
    echo "an example reflectance file is located at: example/input/ang20200712t201415_corr_v2y1_img "
    echo "default values are indicated for optional inputs: SCALE, TMP_DIR, and SETUP_DIR"

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

################################################################################
# Setup Paths and check inputs                                                                 #
################################################################################

if [ -z "$5" ]
then
	echo "ERROR: not enough parameters"
	echo "example usage:"
	echo "sh run_tetracorder.sh [list args]"
	echo "exit 1"
	exit 1
fi

# assumes that sl1 is in TET_CMD_BASE/sl1
#### PREPARE FOR TETRACORDER ####

# define paths
TET_OUT_DIR_ABS=`readlink -f ${TET_OUT_DIR}`
TET_ABS_BASE=`readlink -f ${TET_CMD_BASE}`
TET_SETUP=${TET_ABS_BASE}/tetracorder.cmds/$SETUP_DIR/cmd-setup-tetrun
REFL_ABS_FILE=`readlink -f ${REFL_FILE}`
OUTPUT_ABS_DIR=`readlink -f ${TET_OUT_DIR}`
local_refl=`basename ${REFL_FILE}`
local_output=`basename ${TET_OUT_DIR}`
current_dir=${PWD}

REFL_TMP=${TMP_DIR}/$local_refl
REFL_TMP_LENGTH=`echo $REFL_TMP | awk '{print length}'`

# check if output directory already exists
if [ -d "${TET_OUT_DIR_ABS}" ]
then
	echo "ERROR: Output directory already exists"
	echo "Please specify a new output directory."
	echo "exit 1"
	exit 1
fi

DATASET_PATH=`$TET_ABS_BASE/DATASETS/$DATASET`
# check if dataset keyword is valid
if [ ! -f "$DATASET_PATH" ]
then
	echo "ERROR: Unrecognized dataset keyword: \"$DATASET\""
	echo
	echo "Valid data sets are:"
	ls $TET_ABS_BASE/tetracorder.cmds/$SETUP_DIR/DATASETS
	echo "exit 1"
	exit 1
fi

# check if image file path will be too long
if [ $REFL_TMP_LENGTH -ge 73 ];
then
	echo "ERROR: TMP_DIR + REFL_FILE path longer than 73 char"
	echo "exit 1"
	exit 1
fi

# copy cube and hdr to tmp directory
cd ${TMP_DIR}
cp -rp ${REFL_ABS_FILE} .
cp -rp ${REFL_ABS_FILE}.hdr .
cd $current_dir

echo 'copied cube and hdr to temporary directory ${TMP_DIR}'
date

# replace loctaion of t1 in line 20 of cmd-setup-tetrun
sed -i.bak "20 s,source=/t1,source=$TET_ABS_BASE,g" $TET_SETUP

LIB_CODE=`cat ${TET_ABS_BASE}/tetracorder.cmds/${SETUP_DIR}/DATASETS/${DATASET} | sed 's/restart= r1-//g'`
# copy convolved rlib library to tmp directory
RLIB_PATH=${TMP_DIR}/r06${LIB_CODE}
cp -rp ${TET_ABS_BASE}/sl1/usgs/rlib06/r06${LIB_CODE} $RLIB_PATH
# replace location of convolved rlib in restart file
sed -i.bak " /^iwfl=/c \iwfl=${RLIB_PATH}" $TET_ABS_BASE/tetracorder.cmds/$SETUP_DIR/restart_files/r1-${LIB_CODE}
# copy convolved s06 library to tmp directory
SLIB_PATH=${TMP_DIR}/s06${LIB_CODE}
cp -rp ${TET_ABS_BASE}/sl1/usgs/library06.conv/s06${LIB_CODE} $SLIB_PATH
# replace location of convolved splib06 in restart file
sed -i.bak "/^iyfl=/c \iyfl=${SLIB_PATH}" $TET_ABS_BASE/tetracorder.cmds/$SETUP_DIR/restart_files/r1-${LIB_CODE}

#### SETUP AND RUN TETRACORDER ####

# run cmd-setup-tetrun to copy files and set up run
${TET_SETUP} ${TET_OUT_DIR} ${DATASET} cube ${TMP_DIR}/${local_refl} ${SCALE} -T -20 80 C -P .5 1.5 bar

# cd into tet output directory
cd ${TET_OUT_DIR}
# save filename of cubepath in output directory
echo ${REFL_ABS_FILE} > cubepath.txt

# Run tetracorder
time ./cmd.runtet cube ${TMP_DIR}/${local_refl}  >& cmd.runtet.out
echo 'tetracorder finished'
date

#### POST TETRACORDER ####

# quick check if tetracorder output directory exists

if [ ! -d "${TET_OUT_DIR_ABS}" ]
then
	echo "ERROR: No Tetracorder output"
	echo "exit 1"
	exit 1
fi

cd ${TET_OUT_DIR_ABS}

echo 'starting post tetracorder'

echo 'editing hdr files'
cd ${TET_OUT_DIR_ABS}

# remove extra spaces
sed -s -i.bak 's/^  *//' group.1um/*.hdr
sed -s -i.bak 's/^  *//' group.2um/*.hdr
sed -s -i.bak 's/^  *//' case.veg.type/*.hdr
sed -s -i.bak 's/^  *//' group.1.5um-broad/*.hdr
sed -s -i.bak 's/^  *//' group.2um-broad/*.hdr
sed -s -i.bak 's/^  *//' group.veg/*.hdr

# add map info from original image
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a group.1um/*.hdr >/dev/null
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a group.2um/*.hdr >/dev/null
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a case.veg.type/*.hdr >/dev/null
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a group.1.5um-broad/*.hdr >/dev/null
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a group.2um-broad/*.hdr >/dev/null
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a group.veg/*.hdr >/dev/null

#########################################
# Make output directories
#########################################

mkdir 00_info

mv AAA.info/disabled-materials.txt 00_info/.
mv cubepath.txt 00_info/.
mv cmd.runtet.out 00_info/.
mv tetracorder.out 00_info/.

mkdir 01_tetfits
mkdir 01_tetfits/group1um
mkdir 01_tetfits/group2um

find group.1um/*.fit.gz -exec cp {} 01_tetfits/group1um \;
find group.1um/*.fit.gz.hdr -exec cp {} 01_tetfits/group1um \;

find group.2um/*.fit.gz -exec cp {} 01_tetfits/group2um \;
find group.2um/*.fit.gz.hdr -exec cp {} 01_tetfits/group2um \;

mkdir 01_tetfds
mkdir 01_tetfds/group1um
mkdir 01_tetfds/group2um

find group.1um/*.fd.gz -exec cp {} 01_tetfds/group1um \;
find group.1um/*.fd.gz.hdr -exec cp {} 01_tetfds/group1um \;

find group.2um/*.fd.gz -exec cp {} 01_tetfds/group2um \;
find group.2um/*.fd.gz.hdr -exec cp {} 01_tetfds/group2um \;

mkdir 01_tetdepths
mkdir 01_tetdepths/group1um
mkdir 01_tetdepths/group2um

find group.1um/*.depth.gz -exec cp {} 01_tetdepths/group1um \;
find group.1um/*.depth.gz.hdr -exec cp {} 01_tetdepths/group1um \;

find group.2um/*.depth.gz -exec cp {} 01_tetdepths/group2um \;
find group.2um/*.dpeht.gz.hdr -exec cp {} 01_tetdepths/group2um \;

#########################################
# Mineral only endmembers (no mixtures)
#########################################

rm -rf 02_minerals_only
mkdir 02_minerals_only
mkdir 02_minerals_only/group1um
mkdir 02_minerals_only/group2um

# Group 1 um

# Epidote endmembers
gdal_calc.py -A group.1um/epidote.fit.gz \
-B group.1um/fe2+generic_br33a_bioqtzmonz_epidote.fit.gz \
--outfile=02_minerals_only/group1um/epidote.tif --calc="A+B"

# Goethite endmembers
gdal_calc.py -A group.1um/fe3+_goethite.medgr.ws222.fit.gz \
-B group.1um/fe3+_goethite.fingr.fit.gz \
-C group.1um/fe3+_goethite.medcoarsegr.mpc.trjar.fit.gz \
-D group.1um/fe3+_goethite.coarsegr.fit.gz \
-E group.1um/fe3+_goethite.lepidocrosite.fit.gz \
--outfile=02_minerals_only/group1um/goethite.tif --calc="A+B+C+D+E"

# Hematite endmembers
gdal_calc.py -A group.1um/fe3+_hematite.med.gr.gds27.fit.gz \
-B group.1um/fe3+_hematite.fine.gr.fe2602.fit.gz \
-C group.1um/fe3+_hematite.fine.gr.ws161.fit.gz \
-D group.1um/fe3+_maghemite.fit.gz \
-E group.1um/fe3+_hematite.nano.BR34b2.fit.gz \
-F group.1um/fe3+_hematite.nano.BR34b2b.fit.gz \
-G group.1um/fe3+_hematite.fine.gr.gds76.fit.gz \
--outfile=02_minerals_only/group1um/hematite.tif --calc="A+B+C+D+E+F+G"

# Nontronite endmembers
gdal_calc.py -A group.1um/fe3+_smectite_nontronite.fit.gz \
--outfile=02_minerals_only/group1um/nontronite.tif --calc="A"

# Pyrite endmembers
gdal_calc.py -A group.1um/sulfide_pyrite.fit.gz \
--outfile=02_minerals_only/group1um/pyrite.tif --calc="A"

# Group 2 um

# Alunite endmembers
gdal_calc.py -A group.2um/sulfate_kalun150c.fit.gz \
-B group.2um/sulfate_kalun250c.fit.gz \
-C group.2um/sulfate_kalun450c.fit.gz \
-D group.2um/sulfate_naalun150c.fit.gz \
-E group.2um/sulfate_naalun300c.fit.gz \
-F group.2um/sulfate_naalun450c.fit.gz \
-G group.2um/sulfate_na82alun100c.fit.gz \
-H group.2um/sulfate_na63alun300c.fit.gz \
-I group.2um/sulfate_na40alun400c.fit.gz \
-J group.2um/sulfate_alunNa03.fit.gz \
-K group.2um/sulfate_alunNa56450c.fit.gz \
-L group.2um/sulfate_alunNa78.450c.fit.gz \
--outfile=02_minerals_only/group2um/alunite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L"

# Buddingtonite endmembers
gdal_calc.py -A group.2um/feldspar_buddington.namont2.fit.gz \
--outfile=02_minerals_only/group2um/buddingtonite.tif --calc="A"

# Calcite endmembers
gdal_calc.py -A group.2um/carbonate_calcite.fit.gz \
--outfile=02_minerals_only/group2um/calcite.tif --calc="A"

# Chlorite endmembers
gdal_calc.py -A group.2um/chlorite.fit.gz \
-B group.2um/chlorite_clinochlore.fit.gz \
-C group.2um/chlorite_clinochlore.nmnh83369.fit.gz \
-D group.2um/chlorite_clinochlore.fe.gds157.fit.gz \
-E group.2um/chlorite_clinochlore.fe.sc-cca-1.fit.gz \
-F group.2um/chlorite_cookeite-car-1.a.fit.gz \
-G group.2um/chlorite_cookeite-car-1.c.fit.gz \
-H group.2um/chlorite_thuringite.fit.gz \
--outfile=02_minerals_only/group2um/chlorite.tif --calc="A+B+C+D+E+F+G+H"

# Dickite endmembers
gdal_calc.py -A group.2um/kaolgrp_dickite.fit.gz \
--outfile=02_minerals_only/group2um/dickite.tif --calc="A"

# Dolomite endmembers
gdal_calc.py -A group.2um/carbonate_dolomite.fit.gz \
--outfile=02_minerals_only/group2um/dolomite.tif --calc="A"

# Epidote endmembers
gdal_calc.py -A group.2um/epidote.fit.gz \
--outfile=02_minerals_only/group2um/epidote.tif --calc="A"

# Halloysite endmembers
gdal_calc.py -A group.2um/kaolgrp_halloysite.fit.gz \
--outfile=02_minerals_only/group2um/halloysite.tif --calc="A"

# Illite endmembers
gdal_calc.py -A group.2um/micagrp_illite.fit.gz \
-B group.2um/micagrp_illite.gds4.fit.gz \
-C group.2um/smectite_ammonillsmec.fit.gz \
-D group.2um/micagrp_illite.roscoelite.fit.gz \
--outfile=02_minerals_only/group2um/illite.tif --calc="A+B+C+D"

# Jarosite endmembers
gdal_calc.py -A group.2um/sulfate_ammonjarosite.fit.gz \
-B group.2um/sulfate_jarosite-Na.fit.gz \
-C group.2um/sulfate_jarosite-K.fit.gz \
-D group.2um/sulfate_jarosite-lowT.fit.gz \
--outfile=02_minerals_only/group2um/jarosite.tif --calc="A+B+C+D"

# Kaolinite endmembers
gdal_calc.py -A group.2um/kaolgrp_kaolinite_wxl.fit.gz \
-B group.2um/kaolgrp_kaolinite_pxl.fit.gz \
--outfile=02_minerals_only/group2um/kaolinite.tif --calc="A+B"

# Montmorillonite endmembers
gdal_calc.py -A group.2um/smectite_montmorillonite_na_highswelling.fit.gz \
-B group.2um/smectite_montmorillonite_fe_swelling.fit.gz \
-C group.2um/smectite_montmorillonite_ca_swelling.fit.gz \
-D group.2um/organic_benzene+montswy.fit.gz \
-E group.2um/organic_trichlor+montswy.fit.gz \
-F group.2um/organic_toluene+montswy.fit.gz \
-G group.2um/organic_unleaded.gas+montswy.fit.gz \
-H group.2um/organic_tce+montswy.fit.gz \
--outfile=02_minerals_only/group2um/montmorillonite.tif --calc="A+B+C+D+E+F+G+H"

# Muscovite endmembers
gdal_calc.py -A group.2um/micagrp_muscovite-medhigh-Al.fit.gz \
-B group.2um/micagrp_muscovite-low-Al.fit.gz \
-C group.2um/micagrp_muscoviteFerich.fit.gz \
-D group.2um/prehnite+muscovite.fit.gz \
--outfile=02_minerals_only/group2um/muscovite.tif --calc="A+B+C+D"

# Nontronite endmembers
gdal_calc.py -A group.2um/smectite_nontronite_swelling.fit.gz \
--outfile=02_minerals_only/group2um/nontronite.tif --calc="A"

# Pyrophyllite endmembers
gdal_calc.py -A group.2um/pyrophyllite.fit.gz \
--outfile=02_minerals_only/group2um/pyrophyllite.tif --calc="A"

#########################################
# Minerals and dominant mixtures/coatings
#########################################

rm -rf 03_mineral_mix
mkdir 03_mineral_mix
mkdir 03_mineral_mix/group1um
mkdir 03_mineral_mix/group2um

# Group 1

# Goethite endmembers
gdal_calc.py -A group.1um/fe3+_goethite.medgr.ws222.fit.gz \
-B group.1um/fe3+_goethite.fingr.fit.gz \
-C group.1um/fe3+_goethite.medcoarsegr.mpc.trjar.fit.gz \
-D group.1um/fe3+_goethite.coarsegr.fit.gz \
-E group.1um/fe3+_goethite.lepidocrosite.fit.gz \
-F group.1um/fe3+_goethite+qtz.medgr.gds240.fit.gz \
-G group.1um/fe3+_goethite.thincoat.fit.gz \
-H group.1um/fe2+fe3+_chlor+goeth.propylzone.fit.gz \
--outfile=03_mineral_mix/group1um/goethite.tif --calc="A+B+C+D+E+F+G+H"

# Hematite endmembers
gdal_calc.py -A group.1um/fe3+_hematite.med.gr.gds27.fit.gz \
-B group.1um/fe3+_hematite.fine.gr.fe2602.fit.gz \
-C group.1um/fe3+_hematite.fine.gr.ws161.fit.gz \
-D group.1um/fe3+_maghemite.fit.gz \
-E group.1um/fe3+_hematite.nano.BR34b2.fit.gz \
-F group.1um/fe3+_hematite.nano.BR34b2b.fit.gz \
-G group.1um/fe3+_hematite.fine.gr.gds76.fit.gz \
-H group.1um/fe3+_hematite.thincoat.fit.gz \
-I group.1um/fe2+fe3+mix_with_hematite_br5b.fit.gz \
-J group.1um/fe3+_hematite.lg.gr.br25a.fit.gz \
-K group.1um/fe3+_hematite.med.gr.br25b.fit.gz \
-L group.1um/fe3+_hematite.lg.gr.br25c.fit.gz \
-M group.1um/fe3+_hematite.lg.gr.br34c.fit.gz \
--outfile=03_mineral_mix/group1um/hematite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M"

# Epidote endmembers
gdal_calc.py -A group.1um/epidote.fit.gz \
-B group.1um/fe2+generic_br33a_bioqtzmonz_epidote.fit.gz \
--outfile=03_mineral_mix/group1um/epidote.tif --calc="A+B"

# Nontronite endmembers
gdal_calc.py -A group.1um/fe3+_smectite_nontronite.fit.gz \
--outfile=03_mineral_mix/group1um/nontronite.tif --calc="A"

# Pyrite endmembers
gdal_calc.py -A group.1um/sulfide_copper_chalcopyrite.fit.gz \
-B group.1um/sulfide_pyrite.fit.gz \
--outfile=03_mineral_mix/group1um/pyrite.tif --calc="A+B"

# Group 2

# group 2 even areal mixtures
gdal_calc.py -A group.2um/alunite.5+musc.5.fit.gz \
-B group.2um/alunite.33+kaol.33+musc.33.fit.gz \
-C group.2um/alunite.5+kaol.5.fit.gz \
-D group.2um/pyroph.5+alunit.5.fit.gz \
-E group.2um/alunite+pyrophyl.fit.gz \
-F group.2um/sulfate+kaolingrp_natroalun+dickite.fit.gz \
-G group.2um/carbonate_calcite+dolomite.5.fit.gz \
-H group.2um/calcite+0.5Ca-mont.fit.gz \
-I group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-J group.2um/carbonate_calcite+dolomite.5.fit.gz \
-K group.2um/carbonate_dolo+.5ca-mont.fit.gz \
-L group.2um/carbonate_dolomite.5+Na-mont.5.fit.gz \
-M group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-N group.2um/kaolin.5+muscov.medAl.fit.gz \
-O group.2um/kaolin.5+muscov.medhighAl.fit.gz \
-P group.2um/pyroph.5+mont0.5.fit.gz \
--outfile=03_mineral_mix/group2um/group2_amix.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P"

# group 2 even intimate mixtures
gdal_calc.py -A group.2um/feldspar_buddington.namont2.fit.gz \
-B group.2um/feldspar_buddington.namont.fit.gz \
-C group.2um/talc+carbonate.parkcity.fit.gz \
-D group.2um/muscovite+chlorite.fit.gz \
-E group.2um/kaolin+musc.intimat.fit.gz \
-F group.2um/sulfate+kaolingrp_natroalun+dickite.fit.gz \
-G group.2um/sulfate-mix_gypsum+jar+illite.intmix.fit.gz \
--outfile=03_mineral_mix/group2um/group2_imix.tif --calc="A+B+C+D+E+F+G"

# Alunite endmembers
gdal_calc.py -A group.2um/sulfate_kalun150c.fit.gz \
-B group.2um/sulfate_kalun250c.fit.gz \
-C group.2um/sulfate_kalun450c.fit.gz \
-D group.2um/sulfate_naalun150c.fit.gz \
-E group.2um/sulfate_naalun300c.fit.gz \
-F group.2um/sulfate_naalun450c.fit.gz \
-G group.2um/sulfate_na82alun100c.fit.gz \
-H group.2um/sulfate_na63alun300c.fit.gz \
-I group.2um/sulfate_na40alun400c.fit.gz \
-J group.2um/sulfate_alunNa03.fit.gz \
-K group.2um/sulfate_alunNa56450c.fit.gz \
-L group.2um/sulfate_alunNa78.450c.fit.gz \
-M group.2um/sulfate_alun35K65Na.low.fit.gz \
-N group.2um/sulfate_alun73K27Na.low.fit.gz \
-O group.2um/sulfate_alun66K34Na.low.fit.gz \
-P group.2um/Kalun+kaol.intmx.fit.gz \
-Q group.2um/Na-alun+kaol.intmx.fit.gz \
-R group.2um/sulfate_ammonalunite.fit.gz \
--outfile=03_mineral_mix/group2um/alunite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R"

# Buddingtonite endmembers
gdal_calc.py -A group.2um/feldspar_buddingtonite_ammonium.fit.gz \
--outfile=03_mineral_mix/group2um/buddingtonite.tif --calc="A"

# Calcite endmembers
gdal_calc.py -A group.2um/carbonate_calcite.fit.gz \
-B group.2um/talc+calcite.parkcity.fit.gz \
-C group.2um/calcite+0.2Na-mont.fit.gz \
-D group.2um/carbonate_calcite+0.2kaolwxl.fit.gz \
-E group.2um/carbonate_calcite0.7+kaol0.3.fit.gz \
--outfile=03_mineral_mix/group2um/calcite.tif --calc="A+B+C+D+E"

# Chlorite endmembers
gdal_calc.py -A group.2um/chlorite.fit.gz \
-B group.2um/chlorite_clinochlore.fit.gz \
-C group.2um/chlorite_clinochlore.nmnh83369.fit.gz \
-D group.2um/chlorite_clinochlore.fe.gds157.fit.gz \
-E group.2um/chlorite_clinochlore.fe.sc-cca-1.fit.gz \
-F group.2um/chlorite_cookeite-car-1.a.fit.gz \
-G group.2um/chlorite_cookeite-car-1.c.fit.gz \
-H group.2um/chlorite_thuringite.fit.gz \
-I group.2um/chlorite-skarn.fit.gz \
-J group.2um/prehnite+.50chlorite.fit.gz \
-K group.2um/prehnite+.67chlorite.fit.gz \
-L group.2um/prehnite+.75chlorite.fit.gz \
--outfile=03_mineral_mix/group2um/chlorite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L"

# Dickite endmembers
gdal_calc.py -A group.2um/kaolgrp_dickite.fit.gz \
-B group.2um/dick+musc+gyp+jar.amix.fit.gz \
--outfile=03_mineral_mix/group2um/dickite.tif --calc="A+B"

# Dolomite endmembers
gdal_calc.py -A group.2um/carbonate_dolomite.fit.gz \
--outfile=03_mineral_mix/group2um/dolomite.tif --calc="A"

# Epidote endmembers
gdal_calc.py -A group.2um/epidote.fit.gz \
--outfile=03_mineral_mix/group2um/epidote.tif --calc="A"

# Halloysite endmembers
gdal_calc.py -A group.2um/kaolgrp_halloysite.fit.gz \
--outfile=03_mineral_mix/group2um/halloysite.tif --calc="A"

# Illite endmembers
gdal_calc.py -A group.2um/micagrp_illite.fit.gz \
-B group.2um/micagrp_illite.gds4.fit.gz \
-C group.2um/smectite_ammonillsmec.fit.gz \
-D group.2um/micagrp_illite.roscoelite.fit.gz \
--outfile=03_mineral_mix/group2um/illite.tif --calc="A+B+C+D"

# Jarosite endmembers
gdal_calc.py -A group.2um/sulfate-mix_gyp+jar+musc.amix.fit.gz \
-B group.2um/sulfate_ammonjarosite.fit.gz \
-C group.2um/sulfate_jarosite-Na.fit.gz \
-D group.2um/sulfate_jarosite-K.fit.gz \
-E group.2um/sulfate_jarosite-lowT.fit.gz \
-F group.2um/musc+jarosite.intimat.fit.gz \
--outfile=03_mineral_mix/group2um/jarosite.tif --calc="A+B+C+D+E+F"

# Kaolinite endmembers
gdal_calc.py -A group.2um/kaolgrp_kaolinite_wxl.fit.gz \
-B group.2um/kaolgrp_kaolinite_pxl.fit.gz \
-C group.2um/kaolin.5+smect.5.fit.gz \
-D group.2um/kaolin.3+smect.7.fit.gz \
-E group.2um/kaol.75+alun.25.fit.gz \
-F group.2um/kaol.75+pyroph.25.fit.gz \
--outfile=03_mineral_mix/group2um/kaolinite.tif --calc="A+B+C+D+E+F"

# Montmorillonite endmembers
gdal_calc.py -A group.2um/smectite_montmorillonite_na_highswelling.fit.gz \
-B group.2um/smectite_montmorillonite_fe_swelling.fit.gz \
-C group.2um/smectite_montmorillonite_ca_swelling.fit.gz \
-D group.2um/smectite_beidellite_gds123.fit.gz \
-E group.2um/smectite_beidellite_gds124.fit.gz \
-F group.2um/calcite.25+dolom.25+Na-mont.5.fit.gz \
-G group.2um/carbonate_calcite.25+dolom.25+Ca-mont.5.fit.gz \
-H group.2um/carbonate_smectite_calcite.33+Ca-mont.67.fit.gz \
-I group.2um/organic_drygrass+.17Na-mont.fit.gz \
-J group.2um/organic_benzene+montswy.fit.gz \
-K group.2um/organic_trichlor+montswy.fit.gz \
-L group.2um/organic_toluene+montswy.fit.gz \
-M group.2um/organic_unleaded.gas+montswy.fit.gz \
-N group.2um/organic_tce+montswy.fit.gz \
--outfile=03_mineral_mix/group2um/montmorillonite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N"

# Muscovite endmembers
gdal_calc.py -A group.2um/carbonate_calcite+0.3muscovite.fit.gz \
-B group.2um/sulfate-mix_gyp+jar+musc.amix.fit.gz \
-C group.2um/micagrp_muscovite-medhigh-Al.fit.gz \
-D group.2um/micagrp_muscovite-low-Al.fit.gz \
-E group.2um/micagrp_muscoviteFerich.fit.gz \
-F group.2um/prehnite+muscovite.fit.gz \
-G group.2um/micagrp_muscovite-med-Al.fit.gz \
-H group.2um/musc+pyroph.fit.gz \
-I group.2um/alunite+musc+pyroph.fit.gz \
-J group.2um/musc+gyp+jar+dick.amix.fit.gz \
--outfile=03_mineral_mix/group2um/muscovite.tif --calc="A+B+C+D+E+F+G+H+I+J"

# Nontronite endmembers
gdal_calc.py -A group.2um/smectite_nontronite_swelling.fit.gz \
--outfile=03_mineral_mix/group2um/nontronite.tif --calc="A"

# Pyrophyllite endmembers
gdal_calc.py -A group.2um/pyrophyllite.fit.gz \
-B group.2um/pyroph+tr.musc.fit.gz \
--outfile=03_mineral_mix/group2um/pyrophyllite.tif --calc="A+B"



#########################################
# All endmembers for each mineral
#########################################


rm -rf 04_minerals_all
mkdir 04_minerals_all
mkdir 04_minerals_all/group1um
mkdir 04_minerals_all/group2um

# Group 1um detections

# Epidote endmembers
gdal_calc.py -A group.1um/epidote.fit.gz \
-B group.1um/fe2+generic_br33a_bioqtzmonz_epidote.fit.gz \
--outfile=04_minerals_all/group1um/epidote.tif --calc="A+B"

# Goethite endmembers
gdal_calc.py -A group.1um/fe3+_goethite.medgr.ws222.fit.gz \
-B group.1um/fe3+_goethite.fingr.fit.gz \
-C group.1um/fe3+_goethite.medcoarsegr.mpc.trjar.fit.gz \
-D group.1um/fe3+_goethite.coarsegr.fit.gz \
-E group.1um/fe3+_goethite.lepidocrosite.fit.gz \
-F group.1um/fe3+_goethite+qtz.medgr.gds240.fit.gz \
-G group.1um/fe3+_goethite.thincoat.fit.gz \
-H group.1um/fe3+_goeth+jarosite.fit.gz \
-I group.1um/fe2+_goeth+musc.fit.gz \
-J group.1um/fe2+fe3+_chlor+goeth.propylzone.fit.gz \
--outfile=04_minerals_all/group1um/goethite.tif --calc="A+B+C+D+E+F+G+H+I+J"

# Hematite endmembers
gdal_calc.py -A group.1um/fe3+_hematite.med.gr.gds27.fit.gz \
-B group.1um/fe3+_hematite.fine.gr.fe2602.fit.gz \
-C group.1um/fe3+_hematite.fine.gr.ws161.fit.gz \
-D group.1um/fe3+_maghemite.fit.gz \
-E group.1um/fe3+_hematite.nano.BR34b2.fit.gz \
-F group.1um/fe3+_hematite.nano.BR34b2b.fit.gz \
-G group.1um/fe3+_hematite.fine.gr.gds76.fit.gz \
-H group.1um/fe3+_hematite.thincoat.fit.gz \
-I group.1um/fe2+fe3+mix_with_hematite_br5b.fit.gz \
-J group.1um/fe2+fe3+_hematite_weathering.fit.gz \
-K group.1um/fe3+_hematite.lg.gr.br25a.fit.gz \
-L group.1um/fe3+_hematite.med.gr.br25b.fit.gz \
-M group.1um/fe3+_hematite.lg.gr.br25c.fit.gz \
-N group.1um/fe3+_hematite.lg.gr.br34c.fit.gz \
--outfile=04_minerals_all/group1um/hematite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N"

# Nontronite endmembers
gdal_calc.py -A group.1um/fe3+_smectite_nontronite.fit.gz \
--outfile=04_minerals_all/group1um/nontronite.tif --calc="A"

# Pyrite endmembers
gdal_calc.py -A group.1um/sulfide_copper_chalcopyrite.fit.gz \
-B group.1um/sulfide_pyrite.fit.gz \
--outfile=04_minerals_all/group1um/pyrite.tif --calc="A+B"

# Group 2 detections

# Alunite endmembers
gdal_calc.py -A group.2um/sulfate_kalun150c.fit.gz \
-B group.2um/sulfate_kalun250c.fit.gz \
-C group.2um/sulfate_kalun450c.fit.gz \
-D group.2um/sulfate_naalun150c.fit.gz \
-E group.2um/sulfate_naalun300c.fit.gz \
-F group.2um/sulfate_naalun450c.fit.gz \
-G group.2um/sulfate_na82alun100c.fit.gz \
-H group.2um/sulfate_na63alun300c.fit.gz \
-I group.2um/sulfate_na40alun400c.fit.gz \
-J group.2um/sulfate_alunNa03.fit.gz \
-K group.2um/sulfate_alunNa56450c.fit.gz \
-L group.2um/sulfate_alunNa78.450c.fit.gz \
-M group.2um/sulfate+kaolingrp_natroalun+dickite.fit.gz \
-N group.2um/sulfate_alun35K65Na.low.fit.gz \
-O group.2um/sulfate_alun73K27Na.low.fit.gz \
-P group.2um/sulfate_alun66K34Na.low.fit.gz \
-Q group.2um/alunite+pyrophyl.fit.gz \
-R group.2um/alunite.5+kaol.5.fit.gz \
-S group.2um/Kalun+kaol.intmx.fit.gz \
-T group.2um/Na-alun+kaol.intmx.fit.gz \
-U group.2um/alunite.5+musc.5.fit.gz \
-V group.2um/alunite.33+kaol.33+musc.33.fit.gz \
-W group.2um/sulfate_ammonalunite.fit.gz \
-X group.2um/kaol.75+alun.25.fit.gz \
-Y group.2um/alunite+musc+pyroph.fit.gz \
-Z group.2um/pyroph.5+alunit.5.fit.gz \
--outfile=04_minerals_all/group2um/alunite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T+U+V+W+X+Y+Z"

# Buddingtonite endmembers
gdal_calc.py -A group.2um/feldspar_buddington.namont2.fit.gz \
-B group.2um/feldspar_buddingtonite_ammonium.fit.gz \
-C group.2um/feldspar_buddington.namont.fit.gz \
--outfile=04_minerals_all/group2um/buddingtonite.tif --calc="A+B+C"

# Calcite endmembers
gdal_calc.py -A group.2um/carbonate_calcite.fit.gz \
-B group.2um/talc+calcite.parkcity.fit.gz \
-C group.2um/talc+carbonate.parkcity.fit.gz \
-D group.2um/carbonate_calcite+0.2Ca-mont.fit.gz \
-E group.2um/carbonate_calcite+dolomite.5.fit.gz \
-F group.2um/calcite+0.2Na-mont.fit.gz \
-G group.2um/calcite+0.5Ca-mont.fit.gz \
-H group.2um/carbonate_calcite+0.3muscovite.fit.gz \
-I group.2um/carbonate_calcite+0.2kaolwxl.fit.gz \
-J group.2um/carbonate_calcite0.7+kaol0.3.fit.gz \
-K group.2um/calcite.25+dolom.25+Na-mont.5.fit.gz \
-L group.2um/carbonate_calcite.25+dolom.25+Ca-mont.5.fit.gz \
-M group.2um/carbonate_smectite_calcite.33+Ca-mont.67.fit.gz \
--outfile=04_minerals_all/group2um/calcite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M"

# Chlorite endmembers
gdal_calc.py -A group.2um/chlorite.fit.gz \
-B group.2um/chlorite_clinochlore.fit.gz \
-C group.2um/chlorite_clinochlore.nmnh83369.fit.gz \
-D group.2um/chlorite_clinochlore.fe.gds157.fit.gz \
-E group.2um/chlorite_clinochlore.fe.sc-cca-1.fit.gz \
-F group.2um/chlorite_cookeite-car-1.a.fit.gz \
-G group.2um/chlorite_cookeite-car-1.c.fit.gz \
-H group.2um/chlorite_thuringite.fit.gz \
-I group.2um/chlorite-skarn.fit.gz \
-J group.2um/prehnite+.50chlorite.fit.gz \
-K group.2um/prehnite+.67chlorite.fit.gz \
-L group.2um/prehnite+.75chlorite.fit.gz \
-M group.2um/muscovite+chlorite.fit.gz \
--outfile=04_minerals_all/group2um/chlorite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M"

# Dickite endmembers
gdal_calc.py -A group.2um/sulfate+kaolingrp_natroalun+dickite.fit.gz \
-B group.2um/kaolgrp_dickite.fit.gz \
-C group.2um/dick+musc+gyp+jar.amix.fit.gz \
-D group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-E group.2um/musc+gyp+jar+dick.amix.fit.gz \
--outfile=04_minerals_all/group2um/dickite.tif --calc="A+B+C+D+E"

# Dolomite endmembers
gdal_calc.py -A group.2um/talc+carbonate.parkcity.fit.gz \
-B group.2um/carbonate_calcite+dolomite.5.fit.gz \
-C group.2um/carbonate_dolomite.fit.gz \
-D group.2um/carbonate_dolo+.5ca-mont.fit.gz \
-E group.2um/carbonate_dolomite.5+Na-mont.5.fit.gz \
-F group.2um/calcite.25+dolom.25+Na-mont.5.fit.gz \
-G group.2um/carbonate_calcite.25+dolom.25+Ca-mont.5.fit.gz \
--outfile=04_minerals_all/group2um/dolomite.tif --calc="A+B+C+D+E+F+G"

# Epidote endmembers
gdal_calc.py -A group.2um/epidote.fit.gz \
--outfile=04_minerals_all/group2um/epidote.tif --calc="A"

# Halloysite endmembers
gdal_calc.py -A group.2um/kaolgrp_halloysite.fit.gz \
--outfile=04_minerals_all/group2um/halloysite.tif --calc="A"

# Illite endmembers
gdal_calc.py -A group.2um/micagrp_illite.fit.gz \
-B group.2um/micagrp_illite.gds4.fit.gz \
-C group.2um/smectite_ammonillsmec.fit.gz \
-D group.2um/micagrp_illite.roscoelite.fit.gz \
-E group.2um/sulfate-mix_gypsum+jar+illite.intmix.fit.gz \
--outfile=04_minerals_all/group2um/illite.tif --calc="A+B+C+D+E"

# Jarosite endmembers
gdal_calc.py -A group.2um/sulfate_ammonalunite.fit.gz \
-B group.2um/dick+musc+gyp+jar.amix.fit.gz \
-C group.2um/sulfate-mix_gypsum+jar+illite.intmix.fit.gz \
-D group.2um/sulfate-mix_gyp+jar+musc.amix.fit.gz \
-E group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-F group.2um/sulfate_ammonjarosite.fit.gz \
-G group.2um/sulfate_jarosite-Na.fit.gz \
-H group.2um/sulfate_jarosite-K.fit.gz \
-I group.2um/sulfate_jarosite-lowT.fit.gz \
-J group.2um/musc+jarosite.intimat.fit.gz \
-K group.2um/musc+gyp+jar+dick.amix.fit.gz \
--outfile=04_minerals_all/group2um/jarosite.tif --calc="A+B+C+D+E+F+G+H+I+J+K"

# Kaolinite endmembers
gdal_calc.py -A group.2um/alunite.5+kaol.5.fit.gz \
-B group.2um/Kalun+kaol.intmx.fit.gz \
-C group.2um/Na-alun+kaol.intmx.fit.gz \
-D group.2um/alunite.33+kaol.33+musc.33.fit.gz \
-E group.2um/carbonate_calcite+0.2kaolwxl.fit.gz \
-F group.2um/carbonate_calcite0.7+kaol0.3.fit.gz \
-G group.2um/kaolgrp_kaolinite_wxl.fit.gz \
-H group.2um/kaolgrp_kaolinite_pxl.fit.gz \
-I group.2um/kaolin.5+smect.5.fit.gz \
-J group.2um/kaolin.3+smect.7.fit.gz \
-K group.2um/kaol.75+alun.25.fit.gz \
-L group.2um/kaolin.5+muscov.medAl.fit.gz \
-M group.2um/kaolin.5+muscov.medhighAl.fit.gz \
-N group.2um/kaolin+musc.intimat.fit.gz \
-O group.2um/kaol.75+pyroph.25.fit.gz \
--outfile=04_minerals_all/group2um/kaolinite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O"

# Montmorillonite endmembers
gdal_calc.py -A group.2um/carbonate_calcite+0.2Ca-mont.fit.gz \
-B group.2um/calcite+0.2Na-mont.fit.gz \
-C group.2um/calcite+0.5Ca-mont.fit.gz \
-D group.2um/carbonate_dolo+.5ca-mont.fit.gz \
-E group.2um/carbonate_dolomite.5+Na-mont.5.fit.gz \
-F group.2um/smectite_montmorillonite_na_highswelling.fit.gz \
-G group.2um/smectite_montmorillonite_fe_swelling.fit.gz \
-H group.2um/smectite_montmorillonite_ca_swelling.fit.gz \
-I group.2um/smectite_beidellite_gds123.fit.gz \
-J group.2um/smectite_beidellite_gds124.fit.gz \
-K group.2um/calcite.25+dolom.25+Na-mont.5.fit.gz \
-L group.2um/carbonate_calcite.25+dolom.25+Ca-mont.5.fit.gz \
-M group.2um/carbonate_smectite_calcite.33+Ca-mont.67.fit.gz \
-N group.2um/organic_drygrass+.17Na-mont.fit.gz \
-O group.2um/organic_benzene+montswy.fit.gz \
-P group.2um/organic_trichlor+montswy.fit.gz \
-Q group.2um/organic_toluene+montswy.fit.gz \
-R group.2um/organic_unleaded.gas+montswy.fit.gz \
-S group.2um/organic_tce+montswy.fit.gz \
-T group.2um/pyroph.5+mont0.5.fit.gz \
--outfile=04_minerals_all/group2um/montmorillonite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T"

# Muscovite endmembers
gdal_calc.py -A group.2um/alunite.5+musc.5.fit.gz \
-B group.2um/alunite.33+kaol.33+musc.33.fit.gz \
-C group.2um/carbonate_calcite+0.3muscovite.fit.gz \
-D group.2um/dick+musc+gyp+jar.amix.fit.gz \
-E group.2um/sulfate-mix_gyp+jar+musc.amix.fit.gz \
-F group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-G group.2um/kaolin.5+muscov.medAl.fit.gz \
-H group.2um/kaolin.5+muscov.medhighAl.fit.gz \
-I group.2um/kaolin+musc.intimat.fit.gz \
-J group.2um/micagrp_muscovite-medhigh-Al.fit.gz \
-K group.2um/micagrp_muscovite-low-Al.fit.gz \
-L group.2um/micagrp_muscoviteFerich.fit.gz \
-M group.2um/prehnite+muscovite.fit.gz \
-N group.2um/micagrp_muscovite-med-Al.fit.gz \
-O group.2um/musc+pyroph.fit.gz \
-P group.2um/alunite+musc+pyroph.fit.gz \
-Q group.2um/musc+jarosite.intimat.fit.gz \
-R group.2um/musc+gyp+jar+dick.amix.fit.gz \
-S group.2um/muscovite+chlorite.fit.gz \
-T group.2um/pyroph+tr.musc.fit.gz \
--outfile=04_minerals_all/group2um/muscovite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T"

# Nontronite endmembers
gdal_calc.py -A group.2um/smectite_nontronite_swelling.fit.gz \
--outfile=04_minerals_all/group2um/nontronite.tif --calc="A"

# Pyrophyllite endmembers
gdal_calc.py -A group.2um/alunite+pyrophyl.fit.gz \
-B group.2um/kaol.75+pyroph.25.fit.gz \
-C group.2um/musc+pyroph.fit.gz \
-D group.2um/alunite+musc+pyroph.fit.gz \
-E group.2um/pyrophyllite.fit.gz \
-F group.2um/pyroph.5+mont0.5.fit.gz \
-G group.2um/pyroph.5+alunit.5.fit.gz \
-H group.2um/pyroph+tr.musc.fit.gz \
--outfile=04_minerals_all/group2um/pyrophyllite.tif --calc="A+B+C+D+E+F+G+H"


cd ${current_dir}

date

# remove image from tmp dir
cd ${TMP_DIR}
rm ${local_refl}
rm ${local_refl}.hdr
rm ${SLIB_PATH}
rm ${RLIB_PATH}

cd ${current_dir}

echo 'cleanup finished'
date
