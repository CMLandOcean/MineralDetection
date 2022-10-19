HDR_FILE=${1}
SL1_DIR=${2} # path to sl1
TET_CMD_BASE=${3} # path to t1
SENSOR_ID=${4} # sensor ID name eg GAO. first two letters used for ID
SENSOR_YR=${5}
SENSOR_LET=${6}
SETUP_DIR=${7:-tetracorder5.27a.cmds} # folder where cmd-setup-tetrun is

# TODO test that waves and resol are both length of nchans!!
# assumes inputs are in nm not microns

# define paths
current_dir=${PWD}
HDR_ABS_FILE=`readlink -f ${HDR_FILE}`
SL1_ABS_DIR=`readlink -f ${SL1_DIR}`

# cd into library06.conv dir
cd $SL1_ABS_DIR/usgs/library06.conv

# save waves.txt from hdr
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
# TODO check that waves and resol are same length
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

# make start file 
./make.new.convol.library.start.file  ${S_LIBNAME}  ${N_CHANS} \
"Convolved ${SENSOR_ID} ${SENSOR_YR} ${N_CHANS} ch library" \
"Wavelengths in microns ${N_CHANS} ch ${SENSOR_ID}${YR2}${LET1}" \
"Resolution in microns ${N_CHANS} ch ${SENSOR_ID}${YR2}${LET1}" force

# set pointers for wavelength and resolution
spsetwave startfiles/${S_LIBNAME}.start   6  6  12  force
spsetwave startfiles/${S_LIBNAME}.start   12  6  12  force
spsetwave startfiles/${S_LIBNAME}.start   18  6  12  force

# make library 06
./mak.convol.library ${S_LIBNAME:0:7} ${LET1} ${N_CHANS} ${SENSOR_ID}${YR2} 12 noX

# change to research library directory

cd $SL1_ABS_DIR/usgs/rlib06

cp $SL1_ABS_DIR/usgs/library06.conv/startfiles/${S_LIBNAME}.start startfiles/${R_LIBNAME}.start

spsettitle startfiles/${R_LIBNAME}.start   1 "Digital Spectral Library: ${R_LIBNAME} " force
spsetwave startfiles/${R_LIBNAME}.start   6  6  12  force
spsetwave startfiles/${R_LIBNAME}.start   12  6  12  force

# copy restart file
cp $SL1_ABS_DIR/usgs/library06.conv/restartfiles/r.${S_LIBNAME} restartfiles/r.${R_LIBNAME}

# make replacements
mv restartfiles/r.${R_LIBNAME} restartfiles/r.foo
cat restartfiles/r.foo | sed -e "s/ivfl=${S_LIBNAME}/ivfl=${R_LIBNAME}     /" \
		-e "s/iyfl=splib06b/iyfl=sprlb06b/" \
		-e "s/isavt=      ${S_LIBNAME}/isavt=      ${R_LIBNAME}  /" \
		-e "s/irfl=r.${S_LIBNAME}/irfl=r.${R_LIBNAME} /"           \
		-e "s/inmy=       splib06b/inmy=       sprlb06b /" \
		> restartfiles/r.${R_LIBNAME}
		
./mak.convol.library ${R_LIBNAME:0:7} ${LET1} ${N_CHANS} ${SENSOR2}${YR2}${LET1} 12 noX

echo "Libary convolutions complete for ${S_LIBNAME} and ${R_LIBNAME}. Use as  ${SENSOR_ID}_${SENSOR_YR}${LET1}"

# Make DATASETS file
echo "restart= r1-${SENSOR2}${YR2}${LET1}" > $TET_CMD_BASE/tetracorder.cmds/$SETUP_DIR/DATASETS/${SENSOR_ID}_${SENSOR_YR}${LET1}

# path to restart file in t1 directory
RESTART_PATH=$TET_CMD_BASE/tetracorder.cmds/$SETUP_DIR/restart_files/r1-${SENSOR2}${YR2}${LET1}

# Copy restart file from 06.conv to t1 directory
cp $SL1_ABS_DIR/usgs/library06.conv/restartfiles/r.$S_LIBNAME $RESTART_PATH

# correct restart file name
sed -i.bak "12 s/irfl=r.s06/irfl=r1/g" $RESTART_PATH
# correct rlib name
sed -i.bak "26 s/*unasnd*/$R_LIBNAME/g" $RESTART_PATH
# correct slib name
sed -i.bak "29 s/splib06b/$S_LIBNAME/g" $RESTART_PATH

# Create deleted channels file




