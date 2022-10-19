# Mineral detection system

Code for implementing Tetracorder for Carbon Mapper applications

# Pre tetracorder

* Starting from a hdr file with wavelengths and fwhm in nm
* (or TODO: option to start from `waves.txt` and `fwhm.txt` files)
* Convolve spectral libraries using `convolve_libraries.sh`.

```
sh convolve_libraries.sh [hdr] [sl1 dir] [t1 dir] [sensor id] [sensor year] [letter id] [setup dir (5.27a)]
```

eg.
```
sh /data/gdcsdata/CarbonMapper/software/convolve_libraries.sh GAO20220716t191531p0000_iacorn_refl_ort.hdr /
data/gdcsdata/CarbonMapper/software/tetracorder-build-527/sl1 /data/gdcsdata/CarbonMapper/software/tetracorder-build-527 gao 2022 p
```

# Run tetracorder

```
sh run_tetracorder.sh [output directory] [refl file] [dataset] [t1 dir] [scale (0.0001)] [setup dir (5.27a)] [tmp dir (/tmp)]
```

Example:

For yosemite data
```
sh run_tetracorder.sh /data/gdcsdata/CarbonMapper/Scratch/kellyh/tetout/yose3p2 /data/gdcsdata/CarbonMapper/Scratch/kellyh/cubes/yose3 /data/gdcsdata/CarbonMapper/software/tetracorder-build/tetracorder.cmds/tetracorder5.26e.cmds cao_2015a 0.0001
```

For cuprite
```
sh /data/gdcsdata/CarbonMapper/Scratch/kellyh/run_tetracorder.sh /data/gdcsdata/CarbonMapper/Scratch/kellyh/tetout/cuprite2b /data/gdcsdata/CarbonMapper/AlgDevel/SupplyChain/Minerals/TestData/Cuprite/ang202007
12t200039/ang20200712t200039rfl.tar/ang20200712t200039_rfl_v2y1/ang20200712t200039_corr_v2y1_img avirisng_2020a /data/gdcsdata/CarbonMapper/software/tetracorder-build-527 1 tetracorder5.27a.cmds
```

For phoenix data
```
sh /data/gdcsdata/CarbonMapper/software/run_tetracorder.sh /data/gdcsdata/CarbonMapper/Scratch/kellyh/tetout/GAO20220716t191531p0000 /data/gdcsdata/CarbonMapper/AlgDevel/SupplyChain/MaterialCover/PHX_June2022
/PHX/GAO20220716t191531p0000/GAO20220716t191531p0000_iacorn_refl_ort gao_2022p /data/gdcsdata/CarbonMapper/software/tetracorder-build-527
```

Inputs are:

* TET_OUT_DIR: new directory name for tetracorder output. Cannot exist already
* REFL_FILE: path to BIL reflectance image
* DATASET: name associated with convolved libraries to use=
* TET_CMD_BASE: location of top level (t1) directory
* SCALE: scale factor for reflectance data, must be between 0.000001 and 100000000.0. default 0.0001
* SETUP_DIR: which version of tetracorder cmds to use. default tetracorder5.27a.cmds
* TMP_DIR: tmp directory to use for copying images to deal with character length restrictions

Note: Pressure and temperature constraints are set to what EMIT uses (-20 to 80 C, 0.5 to 1.5 bar) but these could be variables as well. Making a narrower range would only disable materials that are not possible to exist in those conditions. 

These can be changd on line xx in run_tetracorder.sh

```
cmd-setup-tetrun   sub_directory   data_set  cube image_cube sscalefactor [-t|-T|t|T mintemperature maxtemperature tempuniT] [-p|-P|p|P minpressure maxpressure pressure-unit]  [image gif|png|none] [shortcubeid idtext]
```

