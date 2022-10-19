# Mineral detection system

Code for implementing Tetracorder for Carbon Mapper applications

# Pre tetracorder

* Starting from a hdr file with wavelengths and fwhm in nm
* (or TODO: option to start from `waves.txt` and `fwhm.txt` files)
* Convolve spectral libraries using `convolve_libraries.sh`.

From `sl1/usgs/library06.conv` folder

```
sh convolve_libraries.sh [waves.txt] [resol.txt] [n channels] [sensor id] [sensor year] [letter id]
```

eg.
```
sh convolve_libraries.sh waves.txt resol.txt 428 GAO 2022 b
```

# Run tetracorder

```
sh run_tetracorder.sh [output directory] [refl file] [setup dir] [dataset] [scale]
```

Example:

```
sh run_tetracorder.sh /data/gdcsdata/CarbonMapper/Scratch/kellyh/tetout/yose3p2 /data/gdcsdata/CarbonMapper/Scratch/kellyh/cubes/yose3 /data/gdcsdata/CarbonMapper/software/tetracorder-build/tetracorder.cmds/tetracorder5.26e.cmds cao_2015a 0.0001
```

```
sh /data/gdcsdata/CarbonMapper/Scratch/kellyh/run_tetracorder.sh /data/gdcsdata/CarbonMapper/Scratch/kellyh/tetout/cuprite2b /data/gdcsdata/CarbonMapper/AlgDevel/SupplyChain/Minerals/TestData/Cuprite/ang202007
12t200039/ang20200712t200039rfl.tar/ang20200712t200039_rfl_v2y1/ang20200712t200039_corr_v2y1_img avirisng_2020a /data/gdcsdata/CarbonMapper/software/tetracorder-build-527 1 tetracorder5.27a.cmds
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

Line 

```
cmd-setup-tetrun   sub_directory   data_set  cube image_cube sscalefactor [-t|-T|t|T mintemperature maxtemperature tempuniT] [-p|-P|p|P minpressure maxpressure pressure-unit]  [image gif|png|none] [shortcubeid idtext]
```

# Tetracorder version

* If a new version of tetracorder is compiled, files in `tetracorder.cmds/tetracorder5.27a.cmds/` will need to be updated
* Replace location of /t1/ (eg. to `/data/gdcsdata/CarbonMapper/software/tetracorder-build-527`) in cmd-setup-tetrun: Line 20: source=/t1/tetracorder.cmds/tetracorder5.27a.cmds
* Replace location of 	ptc="/usr/local/bin/tetracorder5.27" in `cmd.runtet`: Line 21 (pts is also probably wrong but that is only for single spectrum). eg for 5.26 it is: 	`ptc="/data/gdcsdata/CarbonMapper/software/tetracorder-build/tetracorder5.26/tetracorder5.26"`
	ptc="/data/gdcsdata/CarbonMapper/software/tetracorder-build-527/tetracorder5.27/tetracorder5.27"

* Copy files:
  * Copy deleted channels file eg. `DELETED.channels/delete_cao2015a`
  * Copy DATASETS file for instrument `DATASETS/cao2015a` (this is one line giving the filename of the restart file)
  * Copy restart file eg. `restart_files/r1-ca15a` (has pointers for correct paths for restart file, names of libraries, number of bands (`nchans =`), and full paths to convolved libraries instead of `/sl1` which right now is iwfl=/data/gdcsdata/CarbonMapper/Scratch/kellyh/r06ca15a and iyfl=/data/gdcsdata/CarbonMapper/Scratch/kellyh/s06ca15a)

apparently need color channels now: /data/gdcsdata/CarbonMapper/software/tetracorder-build-527/tetracorder.cmds/tetracorder5.27a2.cmds/COLOR.channels/color-cao_2015a file not found

