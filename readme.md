# Mineral detection system

Code for implementing Tetracorder for Carbon Mapper applications

# Pre tetracorder

For each instrument configuration, use the script `convolve_libraries.sh` to prepare the reference libraries and the other necessary files to support a Tetracorder analysis. These files only need to be prepared once for each configuration of the instrument supplying the data. 

```
$ sh convolve_libraries.sh [HDR_FILE] [SL1_DIR] [TET_CMD_BASE] [SENSOR_ID] [SENSOR_YR] [SENSOR_LET] [SETUP_DIR] [DEL_RANGES]
```

eg. 
```
sh convolve_libraries.sh example/input/ang20200712t201415_corr_v2y1_img.hdr sl1 . anextgen 2020 a
```


# Run tetracorder

Once the reference libraries are convolved, use the script `run_tetracorder.sh` to run Tetracorder on an image, using the appropriate dataset keyword to use the convolved libraries and associated files matching the instrument as configured to collect that image. 

```
$ sh run_tetracorder.sh [TET_OUT_DIR] [REFL_FILE] [DATASET] [TET_CMD_BASE] [SCALE] [TMP_DIR] [SETUP_DIR]
```

eg.
```
$ sh run_tetracorder.sh example/output/out1 example/input/ang20200712t201415_corr_v2y1_img avirisng_2020a . 1 /home/scratch tetracorder5.27a.cmds 
```
