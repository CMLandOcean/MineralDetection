TET_OUT_DIR=${1} # output directory

# Post tetracorder aggregations

#########################################
# Mineral only endmembers (no mixtures)
#########################################

mkdir ${TET_OUT_DIR}/minerals_only
mkdir ${TET_OUT_DIR}/minerals_only/group1um
mkdir ${TET_OUT_DIR}/minerals_only/group2um

# Group 1 um

# Epidote endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/epidote.fit.gz \
-B ${TET_OUT_DIR}/group.1um/fe2+generic_br33a_bioqtzmonz_epidote.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group1um/epidote.tif --calc="A+B"

# Goethite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/fe3+_goethite.medgr.ws222.fit.gz \
-B ${TET_OUT_DIR}/group.1um/fe3+_goethite.fingr.fit.gz \
-C ${TET_OUT_DIR}/group.1um/fe3+_goethite.medcoarsegr.mpc.trjar.fit.gz \
-D ${TET_OUT_DIR}/group.1um/fe3+_goethite.coarsegr.fit.gz \
-E ${TET_OUT_DIR}/group.1um/fe3+_goethite.lepidocrosite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group1um/goethite.tif --calc="A+B+C+D+E"

# Hematite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/fe3+_hematite.med.gr.gds27.fit.gz \
-B ${TET_OUT_DIR}/group.1um/fe3+_hematite.fine.gr.fe2602.fit.gz \
-C ${TET_OUT_DIR}/group.1um/fe3+_hematite.fine.gr.ws161.fit.gz \
-D ${TET_OUT_DIR}/group.1um/fe3+_maghemite.fit.gz \
-E ${TET_OUT_DIR}/group.1um/fe3+_hematite.nano.BR34b2.fit.gz \
-F ${TET_OUT_DIR}/group.1um/fe3+_hematite.nano.BR34b2b.fit.gz \
-G ${TET_OUT_DIR}/group.1um/fe3+_hematite.fine.gr.gds76.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group1um/hematite.tif --calc="A+B+C+D+E+F+G"

# Nontronite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/fe3+_smectite_nontronite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group1um/nontronite.tif --calc="A"

# Pyrite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/sulfide_pyrite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group1um/pyrite.tif --calc="A"

# Group 2 um

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
--outfile=${TET_OUT_DIR}/minerals_only/group2um/alunite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L"

# Buddingtonite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/feldspar_buddington.namont2.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/buddingtonite.tif --calc="A"

# Calcite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/carbonate_calcite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/calcite.tif --calc="A"

# Chlorite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/chlorite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/chlorite_clinochlore.fit.gz \
-C ${TET_OUT_DIR}/group.2um/chlorite_clinochlore.nmnh83369.fit.gz \
-D ${TET_OUT_DIR}/group.2um/chlorite_clinochlore.fe.gds157.fit.gz \
-E ${TET_OUT_DIR}/group.2um/chlorite_clinochlore.fe.sc-cca-1.fit.gz \
-F ${TET_OUT_DIR}/group.2um/chlorite_cookeite-car-1.a.fit.gz \
-G ${TET_OUT_DIR}/group.2um/chlorite_cookeite-car-1.c.fit.gz \
-H ${TET_OUT_DIR}/group.2um/chlorite_thuringite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/chlorite.tif --calc="A+B+C+D+E+F+G+H"

# Dickite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/kaolgrp_dickite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/dickite.tif --calc="A"

# Dolomite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/carbonate_dolomite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/dolomite.tif --calc="A"

# Epidote endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/epidote.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/epidote.tif --calc="A"

# Halloysite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/kaolgrp_halloysite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/halloysite.tif --calc="A"

# Illite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/micagrp_illite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/micagrp_illite.gds4.fit.gz \
-C ${TET_OUT_DIR}/group.2um/smectite_ammonillsmec.fit.gz \
-D ${TET_OUT_DIR}/group.2um/micagrp_illite.roscoelite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/illite.tif --calc="A+B+C+D"

# Jarosite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/sulfate_ammonjarosite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/sulfate_jarosite-Na.fit.gz \
-C ${TET_OUT_DIR}/group.2um/sulfate_jarosite-K.fit.gz \
-D ${TET_OUT_DIR}/group.2um/sulfate_jarosite-lowT.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/jarosite.tif --calc="A+B+C+D"

# Kaolinite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/kaolgrp_kaolinite_wxl.fit.gz \
-B ${TET_OUT_DIR}/group.2um/kaolgrp_kaolinite_pxl.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/kaolinite.tif --calc="A+B"

# Montmorillonite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/smectite_montmorillonite_na_highswelling.fit.gz \
-B ${TET_OUT_DIR}/group.2um/smectite_montmorillonite_fe_swelling.fit.gz \
-C ${TET_OUT_DIR}/group.2um/smectite_montmorillonite_ca_swelling.fit.gz \
-D ${TET_OUT_DIR}/group.2um/organic_benzene+montswy.fit.gz \
-E ${TET_OUT_DIR}/group.2um/organic_trichlor+montswy.fit.gz \
-F ${TET_OUT_DIR}/group.2um/organic_toluene+montswy.fit.gz \
-G ${TET_OUT_DIR}/group.2um/organic_unleaded.gas+montswy.fit.gz \
-H ${TET_OUT_DIR}/group.2um/organic_tce+montswy.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/montmorillonite.tif --calc="A+B+C+D+E+F+G+H"

# Muscovite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/micagrp_muscovite-medhigh-Al.fit.gz \
-B ${TET_OUT_DIR}/group.2um/micagrp_muscovite-low-Al.fit.gz \
-C ${TET_OUT_DIR}/group.2um/micagrp_muscoviteFerich.fit.gz \
-D ${TET_OUT_DIR}/group.2um/prehnite+muscovite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/muscovite.tif --calc="A+B+C+D"

# Nontronite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/smectite_nontronite_swelling.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/nontronite.tif --calc="A"

# Pyrophyllite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/pyrophyllite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_only/group2um/pyrophyllite.tif --calc="A"

#########################################
# Minerals and dominant mixtures/coatings
#########################################

mkdir ${TET_OUT_DIR}/minerals_mix
mkdir ${TET_OUT_DIR}/minerals_mix/group1um
mkdir ${TET_OUT_DIR}/minerals_mix/group2um

# Group 1

# Goethite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/fe3+_goethite.medgr.ws222.fit.gz \
-B ${TET_OUT_DIR}/group.1um/fe3+_goethite.fingr.fit.gz \
-C ${TET_OUT_DIR}/group.1um/fe3+_goethite.medcoarsegr.mpc.trjar.fit.gz \
-D ${TET_OUT_DIR}/group.1um/fe3+_goethite.coarsegr.fit.gz \
-E ${TET_OUT_DIR}/group.1um/fe3+_goethite.lepidocrosite.fit.gz \
-F ${TET_OUT_DIR}/group.1um/fe3+_goethite+qtz.medgr.gds240.fit.gz \
-G ${TET_OUT_DIR}/group.1um/fe3+_goethite.thincoat.fit.gz \
-H ${TET_OUT_DIR}/group.1um/fe2+fe3+_chlor+goeth.propylzone.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group1um/goethite.tif --calc="A+B+C+D+E+F+G+H"

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
-J ${TET_OUT_DIR}/group.1um/fe3+_hematite.lg.gr.br25a.fit.gz \
-K ${TET_OUT_DIR}/group.1um/fe3+_hematite.med.gr.br25b.fit.gz \
-L ${TET_OUT_DIR}/group.1um/fe3+_hematite.lg.gr.br25c.fit.gz \
-M ${TET_OUT_DIR}/group.1um/fe3+_hematite.lg.gr.br34c.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group1um/hematite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M"

# Epidote endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/epidote.fit.gz \
-B ${TET_OUT_DIR}/group.1um/fe2+generic_br33a_bioqtzmonz_epidote.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group1um/epidote.tif --calc="A+B"

# Nontronite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/fe3+_smectite_nontronite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group1um/nontronite.tif --calc="A"

# Pyrite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/sulfide_copper_chalcopyrite.fit.gz \
-B ${TET_OUT_DIR}/group.1um/sulfide_pyrite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group1um/pyrite.tif --calc="A+B"

# Group 2

# group 2 even areal mixtures
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/alunite.5+musc.5.fit.gz \
-B ${TET_OUT_DIR}/group.2um/alunite.33+kaol.33+musc.33.fit.gz \
-C ${TET_OUT_DIR}/group.2um/alunite.5+kaol.5.fit.gz \
-D ${TET_OUT_DIR}/group.2um/pyroph.5+alunit.5.fit.gz \
-E ${TET_OUT_DIR}/group.2um/alunite+pyrophyl.fit.gz \
-F ${TET_OUT_DIR}/group.2um/sulfate+kaolingrp_natroalun+dickite.fit.gz \
-G ${TET_OUT_DIR}/group.2um/carbonate_calcite+dolomite.5.fit.gz \
-H ${TET_OUT_DIR}/group.2um/calcite+0.5Ca-mont.fit.gz \
-I ${TET_OUT_DIR}/group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-J ${TET_OUT_DIR}/group.2um/carbonate_calcite+dolomite.5.fit.gz \
-K ${TET_OUT_DIR}/group.2um/carbonate_dolo+.5ca-mont.fit.gz \
-L ${TET_OUT_DIR}/group.2um/carbonate_dolomite.5+Na-mont.5.fit.gz \
-M ${TET_OUT_DIR}/group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-N ${TET_OUT_DIR}/group.2um/kaolin.5+muscov.medAl.fit.gz \
-O ${TET_OUT_DIR}/group.2um/kaolin.5+muscov.medhighAl.fit.gz \
-P ${TET_OUT_DIR}/group.2um/pyroph.5+mont0.5.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/group2_amix.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P"

# group 2 even intimate mixtures
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/feldspar_buddington.namont2.fit.gz \
-B ${TET_OUT_DIR}/group.2um/feldspar_buddington.namont.fit.gz \
-C ${TET_OUT_DIR}/group.2um/talc+carbonate.parkcity.fit.gz \
-D ${TET_OUT_DIR}/group.2um/muscovite+chlorite.fit.gz \
-E ${TET_OUT_DIR}/group.2um/kaolin+musc.intimat.fit.gz \
-F ${TET_OUT_DIR}/group.2um/sulfate+kaolingrp_natroalun+dickite.fit.gz \
-G ${TET_OUT_DIR}/group.2um/sulfate-mix_gypsum+jar+illite.intmix.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/group2_imix.tif --calc="A+B+C+D+E+F+G"

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
-M ${TET_OUT_DIR}/group.2um/sulfate_alun35K65Na.low.fit.gz \
-N ${TET_OUT_DIR}/group.2um/sulfate_alun73K27Na.low.fit.gz \
-O ${TET_OUT_DIR}/group.2um/sulfate_alun66K34Na.low.fit.gz \
-P ${TET_OUT_DIR}/group.2um/Kalun+kaol.intmx.fit.gz \
-Q ${TET_OUT_DIR}/group.2um/Na-alun+kaol.intmx.fit.gz \
-R ${TET_OUT_DIR}/group.2um/sulfate_ammonalunite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/alunite_mix.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R"

# Buddingtonite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/feldspar_buddingtonite_ammonium.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/buddingtonite.tif --calc="A"

# Calcite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/carbonate_calcite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/talc+calcite.parkcity.fit.gz \
-C ${TET_OUT_DIR}/group.2um/calcite+0.2Na-mont.fit.gz \
-D ${TET_OUT_DIR}/group.2um/carbonate_calcite+0.2kaolwxl.fit.gz \
-E ${TET_OUT_DIR}/group.2um/carbonate_calcite0.7+kaol0.3.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/calcite.tif --calc="A+B+C+D+E"

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
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/chlorite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L"

# Dickite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/kaolgrp_dickite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/dick+musc+gyp+jar.amix.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/dickite.tif --calc="A+B"

# Dolomite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/carbonate_dolomite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/dolomite.tif --calc="A"

# Epidote endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/epidote.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/epidote.tif --calc="A"

# Halloysite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/kaolgrp_halloysite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/halloysite.tif --calc="A"

# Illite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/micagrp_illite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/micagrp_illite.gds4.fit.gz \
-C ${TET_OUT_DIR}/group.2um/smectite_ammonillsmec.fit.gz \
-D ${TET_OUT_DIR}/group.2um/micagrp_illite.roscoelite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/illite.tif --calc="A+B+C+D"

# Jarosite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/sulfate-mix_gyp+jar+musc.amix.fit.gz \
-B ${TET_OUT_DIR}/group.2um/sulfate_ammonjarosite.fit.gz \
-C ${TET_OUT_DIR}/group.2um/sulfate_jarosite-Na.fit.gz \
-D ${TET_OUT_DIR}/group.2um/sulfate_jarosite-K.fit.gz \
-E ${TET_OUT_DIR}/group.2um/sulfate_jarosite-lowT.fit.gz \
-F ${TET_OUT_DIR}/group.2um/musc+jarosite.intimat.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/jarosite.tif --calc="A+B+C+D+E+F"

# Kaolinite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/kaolgrp_kaolinite_wxl.fit.gz \
-B ${TET_OUT_DIR}/group.2um/kaolgrp_kaolinite_pxl.fit.gz \
-C ${TET_OUT_DIR}/group.2um/kaolin.5+smect.5.fit.gz \
-D ${TET_OUT_DIR}/group.2um/kaolin.3+smect.7.fit.gz \
-E ${TET_OUT_DIR}/group.2um/kaol.75+alun.25.fit.gz \
-F ${TET_OUT_DIR}/group.2um/kaol.75+pyroph.25.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/kaolinite.tif --calc="A+B+C+D+E+F"

# Montmorillonite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/smectite_montmorillonite_na_highswelling.fit.gz \
-B ${TET_OUT_DIR}/group.2um/smectite_montmorillonite_fe_swelling.fit.gz \
-C ${TET_OUT_DIR}/group.2um/smectite_montmorillonite_ca_swelling.fit.gz \
-D ${TET_OUT_DIR}/group.2um/smectite_beidellite_gds123.fit.gz \
-E ${TET_OUT_DIR}/group.2um/smectite_beidellite_gds124.fit.gz \
-F ${TET_OUT_DIR}/group.2um/calcite.25+dolom.25+Na-mont.5.fit.gz \
-G ${TET_OUT_DIR}/group.2um/carbonate_calcite.25+dolom.25+Ca-mont.5.fit.gz \
-H ${TET_OUT_DIR}/group.2um/carbonate_smectite_calcite.33+Ca-mont.67.fit.gz \
-I ${TET_OUT_DIR}/group.2um/organic_drygrass+.17Na-mont.fit.gz \
-J ${TET_OUT_DIR}/group.2um/organic_benzene+montswy.fit.gz \
-K ${TET_OUT_DIR}/group.2um/organic_trichlor+montswy.fit.gz \
-L ${TET_OUT_DIR}/group.2um/organic_toluene+montswy.fit.gz \
-M ${TET_OUT_DIR}/group.2um/organic_unleaded.gas+montswy.fit.gz \
-N ${TET_OUT_DIR}/group.2um/organic_tce+montswy.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/montmorillonite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N"

# Muscovite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/carbonate_calcite+0.3muscovite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/sulfate-mix_gyp+jar+musc.amix.fit.gz \
-C ${TET_OUT_DIR}/group.2um/micagrp_muscovite-medhigh-Al.fit.gz \
-D ${TET_OUT_DIR}/group.2um/micagrp_muscovite-low-Al.fit.gz \
-E ${TET_OUT_DIR}/group.2um/micagrp_muscoviteFerich.fit.gz \
-F ${TET_OUT_DIR}/group.2um/prehnite+muscovite.fit.gz \
-G ${TET_OUT_DIR}/group.2um/micagrp_muscovite-med-Al.fit.gz \
-H ${TET_OUT_DIR}/group.2um/musc+pyroph.fit.gz \
-I ${TET_OUT_DIR}/group.2um/alunite+musc+pyroph.fit.gz \
-J ${TET_OUT_DIR}/group.2um/musc+gyp+jar+dick.amix.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/muscovite.tif --calc="A+B+C+D+E+F+G+H+I+J"

# Nontronite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/smectite_nontronite_swelling.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/nontronite.tif --calc="A"

# Pyrophyllite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/pyrophyllite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/pyroph+tr.musc.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_mix/group2um/pyrophyllite.tif --calc="A+B"



#########################################
# All endmembers for each mineral
#########################################


mkdir ${TET_OUT_DIR}/minerals_all
mkdir ${TET_OUT_DIR}/minerals_all/group1um
mkdir ${TET_OUT_DIR}/minerals_all/group2um

# Group 1um detections

# Epidote endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/epidote.fit.gz \
-B ${TET_OUT_DIR}/group.1um/fe2+generic_br33a_bioqtzmonz_epidote.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group1um/epidote.tif --calc="A+B"

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
--outfile=${TET_OUT_DIR}/minerals_all/group1um/goethite.tif --calc="A+B+C+D+E+F+G+H+I+J"

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
--outfile=${TET_OUT_DIR}/minerals_all/group1um/hematite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N"

# Nontronite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/fe3+_smectite_nontronite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group1um/nontronite.tif --calc="A"

# Pyrite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.1um/sulfide_copper_chalcopyrite.fit.gz \
-B ${TET_OUT_DIR}/group.1um/sulfide_pyrite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group1um/pyrite.tif --calc="A+B"

# Group 2 detections

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
--outfile=${TET_OUT_DIR}/minerals_all/group2um/alunite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T+U+V+W+X+Y+Z"

# Buddingtonite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/feldspar_buddington.namont2.fit.gz \
-B ${TET_OUT_DIR}/group.2um/feldspar_buddingtonite_ammonium.fit.gz \
-C ${TET_OUT_DIR}/group.2um/feldspar_buddington.namont.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group2um/buddingtonite.tif --calc="A+B+C"

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
--outfile=${TET_OUT_DIR}/minerals_all/group2um/calcite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M"

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
--outfile=${TET_OUT_DIR}/minerals_all/group2um/chlorite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M"

# Dickite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/sulfate+kaolingrp_natroalun+dickite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/kaolgrp_dickite.fit.gz \
-C ${TET_OUT_DIR}/group.2um/dick+musc+gyp+jar.amix.fit.gz \
-D ${TET_OUT_DIR}/group.2um/sulfate-mix_gyp+jar+musc+dick.amix.fit.gz \
-E ${TET_OUT_DIR}/group.2um/musc+gyp+jar+dick.amix.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group2um/dickite.tif --calc="A+B+C+D+E"

# Dolomite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/talc+carbonate.parkcity.fit.gz \
-B ${TET_OUT_DIR}/group.2um/carbonate_calcite+dolomite.5.fit.gz \
-C ${TET_OUT_DIR}/group.2um/carbonate_dolomite.fit.gz \
-D ${TET_OUT_DIR}/group.2um/carbonate_dolo+.5ca-mont.fit.gz \
-E ${TET_OUT_DIR}/group.2um/carbonate_dolomite.5+Na-mont.5.fit.gz \
-F ${TET_OUT_DIR}/group.2um/calcite.25+dolom.25+Na-mont.5.fit.gz \
-G ${TET_OUT_DIR}/group.2um/carbonate_calcite.25+dolom.25+Ca-mont.5.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group2um/dolomite.tif --calc="A+B+C+D+E+F+G"

# Epidote endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/epidote.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group2um/epidote.tif --calc="A"

# Halloysite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/kaolgrp_halloysite.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group2um/halloysite.tif --calc="A"

# Illite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/micagrp_illite.fit.gz \
-B ${TET_OUT_DIR}/group.2um/micagrp_illite.gds4.fit.gz \
-C ${TET_OUT_DIR}/group.2um/smectite_ammonillsmec.fit.gz \
-D ${TET_OUT_DIR}/group.2um/micagrp_illite.roscoelite.fit.gz \
-E ${TET_OUT_DIR}/group.2um/sulfate-mix_gypsum+jar+illite.intmix.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group2um/illite.tif --calc="A+B+C+D+E"

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
--outfile=${TET_OUT_DIR}/minerals_all/group2um/jarosite.tif --calc="A+B+C+D+E+F+G+H+I+J+K"

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
--outfile=${TET_OUT_DIR}/minerals_all/group2um/kaolinite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O"

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
--outfile=${TET_OUT_DIR}/minerals_all/group2um/montmorillonite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T"

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
--outfile=${TET_OUT_DIR}/minerals_all/group2um/muscovite.tif --calc="A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T"

# Nontronite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/smectite_nontronite_swelling.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group2um/nontronite.tif --calc="A"

# Pyrophyllite endmembers
gdal_calc.py -A ${TET_OUT_DIR}/group.2um/alunite+pyrophyl.fit.gz \
-B ${TET_OUT_DIR}/group.2um/kaol.75+pyroph.25.fit.gz \
-C ${TET_OUT_DIR}/group.2um/musc+pyroph.fit.gz \
-D ${TET_OUT_DIR}/group.2um/alunite+musc+pyroph.fit.gz \
-E ${TET_OUT_DIR}/group.2um/pyrophyllite.fit.gz \
-F ${TET_OUT_DIR}/group.2um/pyroph.5+mont0.5.fit.gz \
-G ${TET_OUT_DIR}/group.2um/pyroph.5+alunit.5.fit.gz \
-H ${TET_OUT_DIR}/group.2um/pyroph+tr.musc.fit.gz \
--outfile=${TET_OUT_DIR}/minerals_all/group2um/pyrophyllite.tif --calc="A+B+C+D+E+F+G+H"

############################
# Combine layers
############################

rm mineralfits1.vrt
rm mineralfits2.vrt
rm mixturefits1.vrt
rm mixturefits2.vrt
# combine mineral fits into one image
gdalbuildvrt -separate mineralfits1.vrt ${TET_OUT_DIR}/minerals_only/group1um/*.tif
gdal_translate -of GTiff mineralfits1.vrt ${TET_OUT_DIR}/mineralfits1.tif

# combine mineral fits into one image
gdalbuildvrt -separate mineralfits2.vrt ${TET_OUT_DIR}/minerals_only/group2um/*.tif
gdal_translate -of GTiff mineralfits2.vrt ${TET_OUT_DIR}/mineralfits2.tif

# combine mineral fits into one image
gdalbuildvrt -separate mixturefits1.vrt ${TET_OUT_DIR}/minerals_mix/group1um/*.tif
gdal_translate -of GTiff mixturefits1.vrt ${TET_OUT_DIR}/mixturefits1.tif

# combine mineral fits into one image
gdalbuildvrt -separate mixturefits2.vrt ${TET_OUT_DIR}/minerals_mix/group2um/*.tif
gdal_translate -of GTiff mixturefits2.vrt ${TET_OUT_DIR}/mixturefits2.tif