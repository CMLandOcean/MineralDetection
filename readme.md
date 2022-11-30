# Mineral detection system

Code for implementing Tetracorder for Carbon Mapper applications

# Installing tetracorder

A script `tetracorder_install_asu.sh` is included in the repository to help get tetracorder and its prerequisitess correctly installed on a Linux-based system. We have only tested this script on a CentosOS 7 cluster, so some adjustements may be needed, especially to get a working version of davinci. It is recommended that the commands in this script be run interactively, so errors will be more noticable. The user can specify the install location using the `TCPREFIX` variable in the script. After completion of the install, some environmental variables need to be updated for proper functioning of the two scripts below:

Required:
```
$ export PATH="${TCPREFIX}/bin:$PATH"
$ export LD_LIBRARY_PATH="${TCPREFIX}/lib:$LD_LIBRARY_PATH"
```
Optional:
```
$ export MANPATH="${TCPREFIX}/share/man:$MANPATH"
```
The above export commands can be placed in a shell init script, like $HOME/.bashrc, so that these variables do not need to be set each time.

# Pre tetracorder

For each instrument configuration, use the script `convolve_libraries.sh` to prepare the reference libraries and the other necessary files to support a Tetracorder analysis. These files only need to be prepared once for each configuration of the instrument supplying the data. 

```
$ sh convolve_libraries.sh [HDR_FILE] [SL1_DIR] [T1_DIR] [SENSOR_ID] [SENSOR_YR] [SENSOR_LET] [SETUP_DIR] [DEL_RANGES]
```

eg. 
```
sh convolve_libraries.sh example/input/ang20200712t201415_corr_v2y1_img.hdr sl1 t1 anextgen 2020 a
```


# Run tetracorder

Once the reference libraries are convolved, use the script `run_tetracorder.sh` to run Tetracorder on an image, using the appropriate dataset keyword to use the convolved libraries and associated files matching the instrument as configured to collect that image. 

```
$ sh run_tetracorder.sh [TET_OUT_DIR] [REFL_FILE] [DATASET] [T1_DIR] [SCALE] [TMP_DIR] [SETUP_DIR]
```

eg.
```
$ sh run_tetracorder.sh example/output/out1 example/input/ang20200712t201415_corr_v2y1_img avirisng_2020a t1 1 /home/scratch tetracorder5.27a.cmds 
```

# Example data

An example image file (for flightline ang20200712t201415) is 4.24 GB and can be downloaded from the AVIRIS-NG FTP site here: https://avng.jpl.nasa.gov/avng/y20_data/ang20200712t201415.tar.gz. Related files and metadata and are available on the data portal: https://avirisng.jpl.nasa.gov/dataportal/. Example outputs are available on Zenodo at: https://doi.org/10.5281/zenodo.7383236.
