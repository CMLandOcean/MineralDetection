#!/bin/sh

cmdver="5.27a"
tetver=5.27

##Directory where tetracorder source will be downloaded and compiled
TC_BUILD_DIR=/data/gdcsdata/CarbonMapper/software/tetracorder-build-527
##Install prefix - tetracorder will be installed at 
## ${TCPREFIX/bin}
TCPREFIX=/data/gdcsdata/CarbonMapper/software/apps/tetracorder/${tetver}

## Various data files and the USGS library will be placed here
TC_DATA=/data/gdcsdata/CarbonMapper/software/tetracorder-essentials

## Clone the tetracorder repository to the build directory
git clone https://github.com/PSI-edu/spectroscopy-tetracorder "${TC_BUILD_DIR}/"
cd "${TC_BUILD_DIR}"

## Make the output prefix folder
mkdir -p "${TCPREFIX}"


################################################################################
## Dependency Ratfor
################################################################################
##Need original, not ratfor90
mkdir -p dependencies/ratfor
pushd dependencies/ratfor 
wget http://sepwww.stanford.edu/lib/exe/fetch.php?media=sep:software:ratfor77.tar.gz -O ratfor77.tar.gz
tar -xzf ratfor77.tar.gz
pushd ratfor77
# ./configure --prefix "${TCPREFIX}"
SEPBINDIR=. make
mkdir -p "${TCPREFIX}/bin"
mv ratfor77 "${TCPREFIX}/bin"
pushd "${TCPREFIX}/bin"
ln -s ratfor77 ratfor
popd
popd
popd




################################################################################
## Dependency - Davinci
################################################################################
mkdir -p dependencies/davinci
pushd dependencies/davinci  

wget http://software.mars.asu.edu/davinci/davinci-2.27-1.el7.centos.x86_64.rpm -O davinci-2.27-1.el7.centos.x86_64.rpm
rpm2cpio davinci-2.27-1.el7.centos.x86_64.rpm | cpio -idmv
rsync -av usr/ "${TCPREFIX}/"
mv "${TCPREFIX}/lib64" "${TCPREFIX}/lib" 
popd


################################################################################
## Dependency - SPECPR
################################################################################

## Set up the environment
#########################
export PATH="${TCPREFIX}/bin:$PATH"
export LD_LIBRARY_PATH="${TCPREFIX}/lib:$LD_LIBRARY_PATH"
export MANPATH="${TCPREFIX}/share/man:$MANPATH"

#modified from etc/bash.bashrc
##############################
# note: in SSPPFLAGS, set TERMDELAY if you need extra delays by the
# cpu for graphics terminal graphics.
export SSPPFLAGS='LINUX -INTEL -XWIN '
export RANDRET=32767
export SPECPR="${TC_BUILD_DIR}/specpr"
export SP_LOCAL="${TCPREFIX}/"
export SP_BIN=securebin

##This code has only been tested on Centos 7 OS
export SP_LDFLAGS=' '
export SP_LDLIBS='-lX11'

#
# The following should be fine as is, except FFLAGS might need
#               floating point accelerator flags
#               (e.g. on sun add -ffpa if you have an accelerator)
#
export SPSDIR=syslinux
export SPSYSOBJ='${SP_OBJ}/syslinux.o'
export RANLIB='ranlib'
export SSPP='sspp'
export SP_DBG="${SPECPR}/debug"
export SP_TMP="${SPECPR}/tmp"
export SP_OBJ="${SPECPR}/obj"
export SP_LIB="${SPECPR}/lib"

export F77=gfortran
export CC='cc'
export AR='ar'
export RF='ratfor'
export YACC=yacc
export LEX=flex

# export SP_FFLAGS='-C -O -m64 -ffree-form -std=f2003'
export SP_FFLAGS='-C -O -m64'
export SP_FFLAGS1='-C -m64'
export SP_FFLAGS2='-C -m64'
export SPKLUDGE=LINUX

# Added to following to not interrupt a backslash
export BSLASH='-fno-backslash'

export SP_FOPT='-O'
export SP_FOPT1='-O'
export SP_FOPT2='-O'
export SP_RFLAGS='<'
export SP_CFLAGS='-O -m64'
export SP_ARFLAGS='rv'
export SP_GFLAGS='-s'
export SP_LFLAGS=' '
export SP_YFLAGS=' '

# for davinci:
# export LD_RUN_PATH='/usr/local/lib'
export LD_RUN_PATH="${TCPREFIX}/lib64"

##Copy files to install dir ahead of time - change hardcoding of path to davinci
###################################################################################
for f in "${TC_BUILD_DIR}/tetracorder.cmds/tetracorder${cmdver}.cmds/davinci-cmds.for.usr.local.bin-pre-env8.30"/*; do
    echo $f
    sed 's~/usr/local/bin/davinci~/usr/bin/env davinci~' $f > "${TCPREFIX}/bin/$(basename $f)"
    chmod +x "${TCPREFIX}/bin/$(basename $f)"
done


##Attempt to build
##################

mkdir -p "${SP_LOCAL}"
echo "\$SP_LOCAL = $SP_LOCAL"

for var in  SSPPFLAGS SSPP CC F77 SP_OBJ SP_LIB RF SP_RFLAGS SPSDIR SP_FFLAGS \
            SP_FFLAGS1 SP_FFLAGS2 SPKLUDGE SP_FOPT SP_FOPT1 SP_FOPT2 SP_CFLAGS \
            SP_GFLAGS SP_LDFLAGS SP_LDLIBS AR SP_ARFLAGS RANLIB; do
    # echo $var
	if [ "$var" == "" ]; then
	    echo "$var NOT SET.  Exiting"
	fi
done

# cd "${TC_BUILD_DIR}/specpr"
#./AAA.INSTALL.specpr+support-progs-linux-upgrade.1.7.sh |& tee ./AAA.INSTALL.specpr+support-progs-linux-upgrade.1.7.sh.out.txt

cp "${SPECPR}/utility/check_env" "${SP_LOCAL}/bin/"

pushd "${SPECPR}/src.sspp"
make
# make install
mv -f sspp "${TCPREFIX}/bin"
chmod 555 "${TCPREFIX}/bin/sspp"
popd


echo "###################   "${SPECPR}/src.lib" ######################"
##Manually make the lib dir
mkdir -p "${SPECPR}/lib"
pushd "${SPECPR}/src.lib"
make
cp -a "${SPECPR}/lib/sputil.a" "${TCPREFIX}/lib/"
popd


echo "###################   "${SPECPR}/src.specpr" ######################"
##Manually make the obj dir
mkdir -p "${SPECPR}/obj"
pushd "${SPECPR}/src.specpr/"
make
make install
popd

echo "###################   "${SPECPR}/src.stamp" ######################"
pushd "${SPECPR}/src.sp_stamp"
make
make install
popd

echo "###################   "${SPECPR}/src.spprint" ######################"
pushd "${SPECPR}/src.spprint/SRC"
make
make install
popd

echo "###################   "${SPECPR}/src.spsetwave" ######################"
pushd "${SPECPR}/src.spsetwave/SRC"
make
make install
popd
        
echo "###################   "${SPECPR}/src.spsettitle" ######################"
pushd "${SPECPR}/src.spsettitle/SRC"
make
make install
popd

echo "###################   "${SPECPR}/src.spratio2spectra" ######################"
pushd "${SPECPR}/src.spratio2spectra/SRC"
make
make install
popd

echo "###################   "${SPECPR}/src.spfeatures" ######################"
pushd "${SPECPR}/src.spfeatures/SRC"
make
make install
popd

echo "###################   "${SPECPR}/src.fstospecpr" ######################"
echo "ASD field spectrometer to specpr format conversion"
pushd "${SPECPR}/src.fstospecpr"
make
# make install
cp -a fstospecpr "${TCPREFIX}/bin/fstospecpr"
popd

echo "###################   "${SPECPR}/src.tgifdaemon" ######################"
echo "Plotting package for use with tgif"
pushd "${SPECPR}/src.tgifdaemon"
make
make install
popd

echo "###################   "${SPECPR}/src.psplotdaemon" ######################"
echo "Plotting package for postscript"
pushd "${SPECPR}/src.psplotdaemon"
make
make install
popd

# uncomment if needed

echo "###################   "${SPECPR}/src.asciitosp" ######################"
echo "uncomment asciitosp section if needed"
pushd "${SPECPR}/src.datatran/SRC.asciitosp"
make
make install
popd

echo "###################   "${SPECPR}/src.sptoasci" ######################"
echo "uncomment sptoascii section if needed"
pushd "${SPECPR}/src.datatran/SRC.sptoascii"
make
make install
popd

echo "###################   "${SPECPR}/src.oceanopticstospecpr" ######################"
pushd "${SPECPR}/src.oceanopticstospecpr"
make
# make install
cp -a oceanopticstospecpr "${TCPREFIX}/bin/oceanopticstospecpr"
cp -a oceanopticstospecpr-multiple "${TCPREFIX}/bin/oceanopticstospecpr-multiple"
popd


for i in specpr dspecpr radtran dradtran spfind sp_spool rule \
	spedit fstospecpr-multiple logtetracorder specprhelp specprnt 
do
		echo "cp ${SPECPR}/utility/$i ${SP_LOCAL}/bin/"
		cp "${SPECPR}/utility/$i" "${SP_LOCAL}/bin/"
		if [ "$?" -ne 0 ]; then
			echo "ERROR copying ${SPECPR}/utility/$i to ${SP_LOCAL}/bin/"
		fi
done

##One more davinci script to copy with updated paths
sed 's~/usr/local/bin/davinci~/usr/bin/env davinci~' "${SPECPR}/utility-davinci/davinci.print.specpr.to.ascii" > "${TCPREFIX}/bin/davinci.print.specpr.to.ascii"

################## man pages##########################

mkdir -p "${TCPREFIX}/share/man/man1"

for i in $(find -name \*.1)
do
    echo "cp -a $i ${TCPREFIX}/share/man/man1/"
    cp -a $i "${TCPREFIX}/share/man/man1/"
done

##Modify hardcoding of prefix in specpr scripts
mkdir -p "${TCPREFIX}/opt/specprdev"
rsync -a "${SPECPR}"/{msgs,src.specpr,src.radtran} "${TCPREFIX}/opt/specprdev/" -v
for script in specpr dspecpr dradtran radtran; do
    sed -i.hardcodedbin 's~exedir=.*$~#\0\nexedir=`dirname $0`~' "${TCPREFIX}/bin/$script"
    chmod 660 "${TCPREFIX}/bin/${script}.hardcodedbin"
    chmod 770 "${TCPREFIX}/bin/${script}"
done


################################################################################
################################################################################
## Tetracorder!!
################################################################################
################################################################################
pushd "${TC_BUILD_DIR}/tetracoder${tetver}"

##modify makefile so all entries with /usr/local are changed to $(PREFIX)
sed -i.orig 's~/usr/local~$(PREFIX)~g' makefile

# Tetracorder must be compiled twice, once for single spectrum mode, once for cubes
# with some manual line commenting/uncommmenting needed between builds
# Here I try to automate this, but it might go wrong with any future changes to 
# the multmap.h file


##Here we find the lines
ASTART=$(awk '/huge cubes/ {print NR}' multmap.h)
ARANGE="$(expr $ASTART + 2),$(expr $ASTART + 5)"
BSTART=$(awk '/reasonable cubes/ {print NR}' multmap.h)
BRANGE="$(expr $BSTART + 2),$(expr $BSTART + 5)"

##CUBE MODE
# vi multmap.h
#    search for  imaxch  where you will find 4 blocks.

#    comment out the B block
#    uncomment the A block
## The above is how the file arrives originally, B is commented out and A is uncommented

PREFIX="${TCPREFIX}" make install |& tee make.1.cube.out.txt


##SINGLELINE MODE
# vi multmap.h
#    search for  imaxch  where you will find 4 blocks.

#    uncomment block B, the line with "parameter" (make sure blocks A, B, and C are commented out)
#    save

SEDCMD=${ARANGE}'s/^/# /;'${BRANGE}'s/^#* *//;'
sed -i.cubemode "$SEDCMD" multmap.h

PREFIX="${TCPREFIX}" make installsingle |& tee make.1.single.out.txt

popd

##Make links so we don't have to have tetracoder<version> in scripts
pushd "${TCPREFIX}/bin"
ln -s tetracorder${tetver} tetracorder
ln -s tetracorder${tetver}single tetracordersingle


##Fix hardlinks in tetracorder cmd.runtet, since we might not have installed at /usr/local/bin
sed -i.orig '/pt[cs]=/s~/usr/local/bin/~~' "${TC_BUILD_DIR}/tetracorder.cmds/tetracorder${cmdver}.cmds/cmd.runtet"


##Copy essential library data to TC_DATA directory
##################################################
T1="${TC_DATA}"
srcT1="${TC_BUILD_DIR}"
echo "new t1 dir: $T1"
SL1="${TC_DATA}/sl1"
srcSL1="${TC_BUILD_DIR}/sl1"
echo "Moving files to new sl1 dir:  $SL1"

mkdir -p "$T1/tetracorder.cmds/tetracorder${cmdver}.cmds"
echo Copying necessary tetracorder${cmdver}.cmds folders to "$T1/tetracorder.cmds/tetracorder${cmdver}.cmds"
for dir in DATASETS DELETED.channels restart_files startfiles_vfollow; do
    echo $dir
    cp -aR "${srcT1}/tetracorder.cmds/tetracorder${cmdver}.cmds/${dir}" "$T1/tetracorder.cmds/tetracorder${cmdver}.cmds/"
done
echo Copying necessary tetracorder${cmdver}.cmds files to "$T1/tetracorder.cmds/tetracorder${cmdver}.cmds"
for fil in cmd.lib.setup.nots-ratios-small cmd.lib.setup.t${cmdver}1 cmd.runtet cmd-setup-tetrun cmd-setup-tetrun.bak cmds.start.t${cmdver} TETNCPU.txt; do
    echo $fil
    cp -aR "${srcT1}/tetracorder.cmds/tetracorder${cmdver}.cmds/${fil}" "$T1/tetracorder.cmds/tetracorder${cmdver}.cmds/"
done

echo Copying various info from from ${srcT1} to ${T1}/info
mkdir -p ${T1}/info
cp -aR ${srcT1}/tetracorder.cmds/tetracorder${cmdver}.cmds/AAAAA.KNOWN-ISSUES.txt ${T1}/info/
cp -aR ${srcT1}/tetracorder${tetver}/license.txt ${T1}/info/

echo Copying sl1 library data from ${srcSL1} to ${SL1}
cp -aR ${srcSL1} ${SL1}

##Inform user about putting tetracorder bin directory in path
echo In order to use run_tetracorder.sh, PATH variable must include
echo tetracorder install directory: "${TCPREFIX}/bin". Use the
echo following command to do so temporarily, or put the line in a
echo "shell init file (like $HOME/.bashrc):"
echo "export PATH=\"${TCPREFIX/bin}:\${PATH}\""



