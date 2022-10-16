HDR_FILE=${1}
SENSOR_ID=${2}
SENSOR_YR=${3}
SENSOR_LET=${4}

# TODO make sure in LIBRARY06.CONVOL FOLDER or make that an input
# TODO test that waves and resol are both length of nchans!!
# assumes inputs are in nm not microns

# define paths
current_dir=${PWD}
HDR_ABS_FILE=`readlink -f ${HDR_FILE}`

# save wavelengths from hdr
awk '/wavelength =/ {print}' ${HDR_ABS_FILE} | sed -e 's/[^0-9.]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | sed 's/ /\n/g' | awk '{ print $1/1000 }' > waves.txt

# save fwhm from hdr
awk '/fwhm =/ {print}' ${HDR_ABS_FILE} | sed -e 's/[^0-9.]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | sed 's/ /\n/g' | awk '{ print $1/1000 }' > resol.txt

NCHANS=wc -l waves.txt
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

cd ../rlib06

cp ${current_dir}/startfiles/${S_LIBNAME}.start startfiles/${R_LIBNAME}.start

spsettitle startfiles/${R_LIBNAME}.start   1 "Digital Spectral Library: ${R_LIBNAME} " force
spsetwave startfiles/${R_LIBNAME}.start   6  6  12  force
spsetwave startfiles/${R_LIBNAME}.start   12  6  12  force

# copy restart file
cp ${current_dir}/restartfiles/r.${S_LIBNAME} restartfiles/r.${R_LIBNAME}

# make replacements
# TODO CHECK THESE ARE CORRECT
mv restartfiles/r.${R_LIBNAME} restartfiles/r.foo

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
# copy libraries to short paths here? 
# maybe copy to correct place at beginning of run_tetracorder

