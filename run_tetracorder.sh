TET_OUT_DIR=${1} # output directory
REFL_FILE=${2} # reflectance file
DATASET=${3} # instrument and libraries to use
TET_CMD_BASE=${4} # location of t1 eg /data/gdcsdata/CarbonMapper/software/tetracorder-build-527
SCALE=${5:-0.0001} # Scale factor of image
SETUP_DIR=${6:-tetracorder5.27a.cmds} # folder where cmd-setup-tetrun is
TMP_DIR=${7:-/tmp} # temp directory for copying image 

#### PREPARE FOR TETRACORDER ####

# define paths
TET_OUT_DIR_ABS=`readlink -f ${TET_OUT_DIR}`
TET_SETUP=${TET_CMD_BASE}/tetracorder.cmds/$SETUP_DIR/cmd-setup-tetrun
REFL_ABS_FILE=`readlink -f ${REFL_FILE}`
OUTPUT_ABS_DIR=`readlink -f ${TET_OUT_DIR}`
local_refl=`basename ${REFL_FILE}`
local_output=`basename ${TET_OUT_DIR}`
current_dir=${PWD}

# copy cube and hdr to tmp directory
cd ${TMP_DIR}
cp ${REFL_ABS_FILE} .
cp ${REFL_ABS_FILE}.hdr .
cd $current_dir

echo 'copied cube and hdr to tmp dir'
date

# replace loctaion of t1 in line 20 of cmd-setup-tetrun
sed -i.bak "20 s,source=/t1,source=$TET_CMD_BASE,g" $TET_SETUP

LIB_CODE=`cat ${TET_CMD_BASE}/tetracorder.cmds/${SETUP_DIR}/DATASETS/${DATASET} | sed 's/restart= r1-//g'`
# copy convolved rlib library to tmp directory
RLIB_PATH=${TMP_DIR}/r06${LIB_CODE}
cp ${TET_CMD_BASE}/sl1/usgs/rlib06/r06${LIB_CODE} $RLIB_PATH
# replace location of convolved rlib in restart file
sed -i.bak "6 s,iwfl=/dev/null,iwfl=${RLIB_PATH},g" $TET_CMD_BASE/tetracorder.cmds/$SETUP_DIR/restart_files/r1-${LIB_CODE}
# copy convolved s06 library to tmp directory
SLIB_PATH=${TMP_DIR}/s06${LIB_CODE}
cp ${TET_CMD_BASE}/sl1/usgs/library06.conv/s06${LIB_CODE} $SLIB_PATH
# replace location of convolved splib06 in restart file
sed -i.bak "9 s,iyfl=splib06b,iyfl=${SLIB_PATH},g" $TET_CMD_BASE/tetracorder.cmds/$SETUP_DIR/restart_files/r1-${LIB_CODE}

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

echo 'starting post tetracorder'

echo 'editing hdr files'

# remove extra spaces
sed -s -i.bak 's/^  *//' ${TET_OUT_DIR}/group.1um/*.hdr
sed -s -i.bak 's/^  *//' ${TET_OUT_DIR}/group.2um/*.hdr
sed -s -i.bak 's/^  *//' ${TET_OUT_DIR}/case.veg.type/*.hdr
sed -s -i.bak 's/^  *//' ${TET_OUT_DIR}/group.1.5um-broad/*.hdr
sed -s -i.bak 's/^  *//' ${TET_OUT_DIR}/group.2um-broad/*.hdr

# add map info from original image
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a group.1um/*.hdr >/dev/null
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a group.2um/*.hdr >/dev/null
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a case.veg.type/*.hdr >/dev/null
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a group.1.5um-broad/*.hdr >/dev/null
grep 'map info =' ${REFL_ABS_FILE}.hdr | tee -a group.2um-broad/*.hdr >/dev/null

echo 'starting endmember aggregations'
mkdir ${TET_OUT_DIR}/minerals

# Alunite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/sulfate_kalun150c.fit.gz \
-B ${TET_OUT_DIR}/group.2um/sulfate_kalun250c.fit.gz \
-C ${TET_OUT_DIR}/group.2um/sulfate_kalun450c.fit.gz \
-D ${TET_OUT_DIR}/group.2um/sulfate_naalun150c.fit.gz \
-E ${TET_OUT_DIR}/group.2um/sulfate_naalun300c.fit.gz \
-F ${TET_OUT_DIR}/group.2um/sulfate_naalun450c.fit.gz \
-G ${TET_OUT_DIR}/group.2um/sulfate_na82alun100c.fit.gz \
-H ${TET_OUT_DIR}/group.2um/sulfate_na63alun300c.fit.gz \
-I ${TET_OUT_DIR}/group.2um/sulfate_na40alun400c.fit.gz \
-J ${TET_OUT_DIR}/group.2um/sulfate_alunNa03.fit.gz \
-K ${TET_OUT_DIR}/group.2um/sulfate_alunNa56450c.fit.gz \
-L ${TET_OUT_DIR}/group.2um/sulfate_alunNa78.450c.fit.gz \
-M ${TET_OUT_DIR}/group.2um/sulfate+kaolingrp_natroalun+dickite.fit.gz \
-N ${TET_OUT_DIR}/group.2um/sulfate_alun35K65Na.low.fit.gz \
-O ${TET_OUT_DIR}/group.2um/sulfate_alun73K27Na.low.fit.gz \
-P ${TET_OUT_DIR}/group.2um/sulfate_alun66K34Na.low.fit.gz \
-Q ${TET_OUT_DIR}/group.2um/alunite+pyrophyl.fit.gz \
-R ${TET_OUT_DIR}/group.2um/alunite.5+kaol.5.fit.gz \
-S ${TET_OUT_DIR}/group.2um/Kalun+kaol.intmx.fit.gz \
-T ${TET_OUT_DIR}/group.2um/Na-alun+kaol.intmx.fit.gz \
-U ${TET_OUT_DIR}/group.2um/alunite.5+musc.5.fit.gz \
-V ${TET_OUT_DIR}/group.2um/alunite.33+kaol.33+musc.33.fit.gz \
-W ${TET_OUT_DIR}/group.2um/sulfate_ammonalunite.fit.gz \
-X ${TET_OUT_DIR}/group.2um/kaol.75+alun.25.fit.gz \
-Y ${TET_OUT_DIR}/group.2um/alunite+musc+pyroph.fit.gz \
-Z ${TET_OUT_DIR}/group.2um/pyroph.5+alunit.5.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/alunite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T+U+V+W+X+Y+Z"

# Buddingtonite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/feldspar_buddington.namont2.fit.gz \
-B ${TET_OUT_DIR}/group.2um/feldspar_buddingtonite_ammonium.fit.gz \
-C ${TET_OUT_DIR}/group.2um/feldspar_buddington.namont.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/buddingtonite.tif --calc="A+B+C"

# Calcite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/carbonate_calcite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/talc+calcite.parkcity.fit.gz \
-C ${TET_OUT_DIR}/group.2um/talc+carbonate.parkcity.fit.gz \
-D ${TET_OUT_DIR}/group.2um/carbonate_calcite+0.2Ca-mont.fit.gz \
-E ${TET_OUT_DIR}/group.2um/carbonate_calcite+dolomite.5.fit.gz \
-F ${TET_OUT_DIR}/group.2um/calcite+0.2Na-mont.fit.gz \
-G ${TET_OUT_DIR}/group.2um/calcite+0.5Ca-mont.fit.gz \
-H ${TET_OUT_DIR}/group.2um/carbonate_calcite+0.3muscovite.fit.gz \
-I ${TET_OUT_DIR}/group.2um/carbonate_calcite+0.2kaolwxl.fit.gz \
-J ${TET_OUT_DIR}/group.2um/carbonate_calcite0.7+kaol0.3.fit.gz \
-K ${TET_OUT_DIR}/group.2um/calcite.25+dolom.25+Na-mont.5.fit.gz \
-L ${TET_OUT_DIR}/group.2um/carbonate_calcite.25+dolom.25+Ca-mont.5.fit.gz \
-M ${TET_OUT_DIR}/group.2um/carbonate_smectite_calcite.33+Ca-mont.67.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/calcite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M"

# Chlorite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/chlorite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/chlorite_clinochlore.fit.gz \
-C ${TET_OUT_DIR}/group.2um/chlorite_clinochlore.nmnh83369.fit.gz \
-D ${TET_OUT_DIR}/group.2um/chlorite_clinochlore.fe.gds157.fit.gz \
-E ${TET_OUT_DIR}/group.2um/chlorite_clinochlore.fe.sc-cca-1.fit.gz \
-F ${TET_OUT_DIR}/group.2um/chlorite_cookeite-car-1.a.fit.gz \
-G ${TET_OUT_DIR}/group.2um/chlorite_cookeite-car-1.c.fit.gz \
-H ${TET_OUT_DIR}/group.2um/chlorite_thuringite.fit.gz \
-I ${TET_OUT_DIR}/group.2um/chlorite-skarn.fit.gz \
-J ${TET_OUT_DIR}/group.2um/prehnite+.50chlorite.fit.gz \
-K ${TET_OUT_DIR}/group.2um/prehnite+.67chlorite.fit.gz \
-L ${TET_OUT_DIR}/group.2um/prehnite+.75chlorite.fit.gz \
-M ${TET_OUT_DIR}/group.2um/muscovite+chlorite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/chlorite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M"

# Dickite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/sulfate+kaolingrp_natroalun+dickite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/kaolgrp_dickite.fit.gz \
-C ${TET_OUT_DIR}/group.2um/dick+musc+gyp+jar.amix.fit.gz \
-D ${TET_OUT_DIR}/group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-E ${TET_OUT_DIR}/group.2um/musc+gyp+jar+dick.amix.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/dickite.tif --calc="A+B+C+D+E"

# Dolomite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/talc+carbonate.parkcity.fit.gz \
-B ${TET_OUT_DIR}/group.2um/carbonate_calcite+dolomite.5.fit.gz \
-C ${TET_OUT_DIR}/group.2um/carbonate_dolomite.fit.gz \
-D ${TET_OUT_DIR}/group.2um/carbonate_dolo+.5ca-mont.fit.gz \
-E ${TET_OUT_DIR}/group.2um/carbonate_dolomite.5+Na-mont.5.fit.gz \
-F ${TET_OUT_DIR}/group.2um/calcite.25+dolom.25+Na-mont.5.fit.gz \
-G ${TET_OUT_DIR}/group.2um/carbonate_calcite.25+dolom.25+Ca-mont.5.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/dolomite.tif --calc="A+B+C+D+E+F+G"

# Epidote endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/epidote.fit.gz \
-B ${TET_OUT_DIR}/group.1um/fe2+generic_br33a_bioqtzmonz_epidote.fit.gz \
-C ${TET_OUT_DIR}/group.2um/epidote.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/epidote.tif --calc="A+B+C"

# Goethite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/fe3+_goethite.medgr.ws222.fit.gz \
-B ${TET_OUT_DIR}/group.1um/fe3+_goethite.fingr.fit.gz \
-C ${TET_OUT_DIR}/group.1um/fe3+_goethite.medcoarsegr.mpc.trjar.fit.gz \
-D ${TET_OUT_DIR}/group.1um/fe3+_goethite.coarsegr.fit.gz \
-E ${TET_OUT_DIR}/group.1um/fe3+_goethite.lepidocrosite.fit.gz \
-F ${TET_OUT_DIR}/group.1um/fe3+_goethite+qtz.medgr.gds240.fit.gz \
-G ${TET_OUT_DIR}/group.1um/fe3+_goethite.thincoat.fit.gz \
-H ${TET_OUT_DIR}/group.1um/fe3+_goeth+jarosite.fit.gz \
-I ${TET_OUT_DIR}/group.1um/fe2+_goeth+musc.fit.gz \
-J ${TET_OUT_DIR}/group.1um/fe2+fe3+_chlor+goeth.propylzone.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/goethite.tif --calc="A+B+C+D+E+F+G+H+I+J"

# Halloysite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/kaolgrp_halloysite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/halloysite.tif --calc="A"

# Hematite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/fe3+_hematite.med.gr.gds27.fit.gz \
-B ${TET_OUT_DIR}/group.1um/fe3+_hematite.fine.gr.fe2602.fit.gz \
-C ${TET_OUT_DIR}/group.1um/fe3+_hematite.fine.gr.ws161.fit.gz \
-D ${TET_OUT_DIR}/group.1um/fe3+_maghemite.fit.gz \
-E ${TET_OUT_DIR}/group.1um/fe3+_hematite.nano.BR34b2.fit.gz \
-F ${TET_OUT_DIR}/group.1um/fe3+_hematite.nano.BR34b2b.fit.gz \
-G ${TET_OUT_DIR}/group.1um/fe3+_hematite.fine.gr.gds76.fit.gz \
-H ${TET_OUT_DIR}/group.1um/fe3+_hematite.thincoat.fit.gz \
-I ${TET_OUT_DIR}/group.1um/fe2+fe3+mix_with_hematite_br5b.fit.gz \
-J ${TET_OUT_DIR}/group.1um/fe2+fe3+_hematite_weathering.fit.gz \
-K ${TET_OUT_DIR}/group.1um/fe3+_hematite.lg.gr.br25a.fit.gz \
-L ${TET_OUT_DIR}/group.1um/fe3+_hematite.med.gr.br25b.fit.gz \
-M ${TET_OUT_DIR}/group.1um/fe3+_hematite.lg.gr.br25c.fit.gz \
-N ${TET_OUT_DIR}/group.1um/fe3+_hematite.lg.gr.br34c.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/hematite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N"

# Illite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/micagrp_illite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/micagrp_illite.gds4.fit.gz \
-C ${TET_OUT_DIR}/group.2um/smectite_ammonillsmec.fit.gz \
-D ${TET_OUT_DIR}/group.2um/micagrp_illite.roscoelite.fit.gz \
-E ${TET_OUT_DIR}/group.2um/sulfate-mix_gypsum+jar+illite.intmix.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/illite.tif --calc="A+B+C+D+E"

# Jarosite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/sulfate_ammonalunite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/dick+musc+gyp+jar.amix.fit.gz \
-C ${TET_OUT_DIR}/group.2um/sulfate-mix_gypsum+jar+illite.intmix.fit.gz \
-D ${TET_OUT_DIR}/group.2um/sulfate-mix_gyp+jar+musc.amix.fit.gz \
-E ${TET_OUT_DIR}/group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-F ${TET_OUT_DIR}/group.2um/sulfate_ammonjarosite.fit.gz \
-G ${TET_OUT_DIR}/group.2um/sulfate_jarosite-Na.fit.gz \
-H ${TET_OUT_DIR}/group.2um/sulfate_jarosite-K.fit.gz \
-I ${TET_OUT_DIR}/group.2um/sulfate_jarosite-lowT.fit.gz \
-J ${TET_OUT_DIR}/group.2um/musc+jarosite.intimat.fit.gz \
-K ${TET_OUT_DIR}/group.2um/musc+gyp+jar+dick.amix.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/jarosite.tif --calc="A+B+C+D+E+F+G+H+I+J+K"

# Kaolinite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/alunite.5+kaol.5.fit.gz \
-B ${TET_OUT_DIR}/group.2um/Kalun+kaol.intmx.fit.gz \
-C ${TET_OUT_DIR}/group.2um/Na-alun+kaol.intmx.fit.gz \
-D ${TET_OUT_DIR}/group.2um/alunite.33+kaol.33+musc.33.fit.gz \
-E ${TET_OUT_DIR}/group.2um/carbonate_calcite+0.2kaolwxl.fit.gz \
-F ${TET_OUT_DIR}/group.2um/carbonate_calcite0.7+kaol0.3.fit.gz \
-G ${TET_OUT_DIR}/group.2um/kaolgrp_kaolinite_wxl.fit.gz \
-H ${TET_OUT_DIR}/group.2um/kaolgrp_kaolinite_pxl.fit.gz \
-I ${TET_OUT_DIR}/group.2um/kaolin.5+smect.5.fit.gz \
-J ${TET_OUT_DIR}/group.2um/kaolin.3+smect.7.fit.gz \
-K ${TET_OUT_DIR}/group.2um/kaol.75+alun.25.fit.gz \
-L ${TET_OUT_DIR}/group.2um/kaolin.5+muscov.medAl.fit.gz \
-M ${TET_OUT_DIR}/group.2um/kaolin.5+muscov.medhighAl.fit.gz \
-N ${TET_OUT_DIR}/group.2um/kaolin+musc.intimat.fit.gz \
-O ${TET_OUT_DIR}/group.2um/kaol.75+pyroph.25.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/kaolinite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O"

# Montmorillonite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/carbonate_calcite+0.2Ca-mont.fit.gz \
-B ${TET_OUT_DIR}/group.2um/calcite+0.2Na-mont.fit.gz \
-C ${TET_OUT_DIR}/group.2um/calcite+0.5Ca-mont.fit.gz \
-D ${TET_OUT_DIR}/group.2um/carbonate_dolo+.5ca-mont.fit.gz \
-E ${TET_OUT_DIR}/group.2um/carbonate_dolomite.5+Na-mont.5.fit.gz \
-F ${TET_OUT_DIR}/group.2um/smectite_montmorillonite_na_highswelling.fit.gz \
-G ${TET_OUT_DIR}/group.2um/smectite_montmorillonite_fe_swelling.fit.gz \
-H ${TET_OUT_DIR}/group.2um/smectite_montmorillonite_ca_swelling.fit.gz \
-I ${TET_OUT_DIR}/group.2um/smectite_beidellite_gds123.fit.gz \
-J ${TET_OUT_DIR}/group.2um/smectite_beidellite_gds124.fit.gz \
-K ${TET_OUT_DIR}/group.2um/calcite.25+dolom.25+Na-mont.5.fit.gz \
-L ${TET_OUT_DIR}/group.2um/carbonate_calcite.25+dolom.25+Ca-mont.5.fit.gz \
-M ${TET_OUT_DIR}/group.2um/carbonate_smectite_calcite.33+Ca-mont.67.fit.gz \
-N ${TET_OUT_DIR}/group.2um/organic_drygrass+.17Na-mont.fit.gz \
-O ${TET_OUT_DIR}/group.2um/organic_benzene+montswy.fit.gz \
-P ${TET_OUT_DIR}/group.2um/organic_trichlor+montswy.fit.gz \
-Q ${TET_OUT_DIR}/group.2um/organic_toluene+montswy.fit.gz \
-R ${TET_OUT_DIR}/group.2um/organic_unleaded.gas+montswy.fit.gz \
-S ${TET_OUT_DIR}/group.2um/organic_tce+montswy.fit.gz \
-T ${TET_OUT_DIR}/group.2um/pyroph.5+mont0.5.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/montmorillonite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T"

# Muscovite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/alunite.5+musc.5.fit.gz \
-B ${TET_OUT_DIR}/group.2um/alunite.33+kaol.33+musc.33.fit.gz \
-C ${TET_OUT_DIR}/group.2um/carbonate_calcite+0.3muscovite.fit.gz \
-D ${TET_OUT_DIR}/group.2um/dick+musc+gyp+jar.amix.fit.gz \
-E ${TET_OUT_DIR}/group.2um/sulfate-mix_gyp+jar+musc.amix.fit.gz \
-F ${TET_OUT_DIR}/group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-G ${TET_OUT_DIR}/group.2um/kaolin.5+muscov.medAl.fit.gz \
-H ${TET_OUT_DIR}/group.2um/kaolin.5+muscov.medhighAl.fit.gz \
-I ${TET_OUT_DIR}/group.2um/kaolin+musc.intimat.fit.gz \
-J ${TET_OUT_DIR}/group.2um/micagrp_muscovite-medhigh-Al.fit.gz \
-K ${TET_OUT_DIR}/group.2um/micagrp_muscovite-low-Al.fit.gz \
-L ${TET_OUT_DIR}/group.2um/micagrp_muscoviteFerich.fit.gz \
-M ${TET_OUT_DIR}/group.2um/prehnite+muscovite.fit.gz \
-N ${TET_OUT_DIR}/group.2um/micagrp_muscovite-med-Al.fit.gz \
-O ${TET_OUT_DIR}/group.2um/musc+pyroph.fit.gz \
-P ${TET_OUT_DIR}/group.2um/alunite+musc+pyroph.fit.gz \
-Q ${TET_OUT_DIR}/group.2um/musc+jarosite.intimat.fit.gz \
-R ${TET_OUT_DIR}/group.2um/musc+gyp+jar+dick.amix.fit.gz \
-S ${TET_OUT_DIR}/group.2um/muscovite+chlorite.fit.gz \
-T ${TET_OUT_DIR}/group.2um/pyroph+tr.musc.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/muscovite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T"

# Nontronite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/fe3+_smectite_nontronite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/smectite_nontronite_swelling.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/nontronite.tif --calc="A+B"

# Pyrite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/sulfide_copper_chalcopyrite.fit.gz \
-B ${TET_OUT_DIR}/group.1um/sulfide_pyrite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/pyrite.tif --calc="A+B"

# Pyrophyllite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/alunite+pyrophyl.fit.gz \
-B ${TET_OUT_DIR}/group.2um/kaol.75+pyroph.25.fit.gz \
-C ${TET_OUT_DIR}/group.2um/musc+pyroph.fit.gz \
-D ${TET_OUT_DIR}/group.2um/alunite+musc+pyroph.fit.gz \
-E ${TET_OUT_DIR}/group.2um/pyrophyllite.fit.gz \
-F ${TET_OUT_DIR}/group.2um/pyroph.5+mont0.5.fit.gz \
-G ${TET_OUT_DIR}/group.2um/pyroph.5+alunit.5.fit.gz \
-H ${TET_OUT_DIR}/group.2um/pyroph+tr.musc.fit.gz \
--outfile=${TET_OUT_DIR}/minerals/pyrophyllite.tif --calc="A+B+C+D+E+F+G+H"

# combine mineral fits into one image
gdalbuildvrt -separate mineralfits.vrt ${TET_OUT_DIR}/minerals/*.tif
gdal_translate -of GTiff mineralfits.vrt ${TET_OUT_DIR}/mineralfits.tif

cd ${current_dir}
echo 'mineral fit outputs done'

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
