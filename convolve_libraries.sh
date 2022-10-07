WAVES_FILE=${1}
RESOL_FILE=${2}
N_CHANS=${3}
SENSOR_ID=${4}
SENSOR_YR=${5}
SENSOR_LET=${6}

# TODO make sure in LIBRARY06.CONVOL FOLDER 
# TODO test that waves and resol are both length of nchans!!

# define paths
current_dir=${PWD}
WAVES_ABS_FILE=`readlink -f ${WAVES_FILE}`
RESOL_ABS_FILE=`readlink -f ${RESOL_FILE}`

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

# load tetracorder so specpr is available
export MODULEPATH=/data/gdcsdata/CarbonMapper/software/apps/modules:$MODULEPATH
module load tetracorder/latest


# copy WAVES_FILE to waves.txt
cp ${WAVES_ABS_FILE} ${current_dir}/waves.txt

# copy RESOL_FILE to resol.txt
cp ${RESOL_ABS_FILE} ${current_dir}/resol.txt


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

cd ..
cd rlib06

cp ${current_dir}/startfiles/${S_LIBNAME}.start startfiles/${R_LIBNAME}.start

spsettitle startfiles/${R_LIBNAME}.start   1 "Digital Spectral Library: ${R_LIBNAME} " force
spsetwave startfiles/${R_LIBNAME}.start   6  6  12  force
spsetwave startfiles/${R_LIBNAME}.start   12  6  12  force

# copy restart file
cp ${current_dir}/restartfiles/r.${S_LIBNAME} restartfiles/r.${R_LIBNAME}

# make replacements
# TODO CHECK THESE ARE CORRECT
cat restartfiles/r.foo | sed -e "s/ivfl=${S_LIBNAME}/ivfl=${R_LIBNAME}     /" \
		-e "s/iyfl=splib06b/iyfl=sprlb06b/" \
		-e "s/isavt=      ${S_LIBNAME}/isavt=      ${R_LIBNAME}  /" \
		-e "s/irfl=r.${S_LIBNAME}/irfl=r.${R_LIBNAME} /"           \
		-e "s/inmy=       splib06b/inmy=       sprlb06b /" \
		> restartfiles/r.${R_LIBNAME}
		
./mak.convol.library ${R_LIBNAME:0:7} ${LET1} ${N_CHANS} ${SENSOR2}${YR2}${LET1} 12 noX

# TODO make restart= r1-${SENSOR2}${YR2}${LET1}
# saved in t1/tetracorder.cmds/tetracorder5.26e/cmds/DATASETS/${SENSOR_ID}_{SENSOR_YR}{LET1}
# TODO print the name to use for these new convolved libraries... ${SENSOR_ID}_{SENSOR_YR}{LET1}

# TODO ...here? r1- restart file needs correct file paths for convolved libraries
# and they need to be short enough file paths


