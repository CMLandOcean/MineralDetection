# Mineral detection system

Code for implementing Tetracorder for Carbon Mapper applications

# Pre tetracorder

* Make `waves.txt` and `fwhm.txt` files for instrument settings
* Convolve spectral libraries using `convolve_libraries.sh`.

# Run tetracorder

```
sh run_tetracorder.sh [output directory] [refl file] [setup dir] [dataset] [scale]
```

Inputs are:

* new directory name for tetracorder outputs. cannot exist already

* reflectance file path. File must be BIL

* directory where cmd-setup-tetrun file is (actually using cmd-setup-tetrun-cm) . This file has pointer to source where compiled tetracorder is (Line 20). 

* dataset: name associated with convolved libraries to use (specific for each wavelength/resolution configuration). New configurations require running convolve_libraries.sh. Options are gao_2022a (phoenix) or cao_2015a (yosemite)

* scale factor for reflectance data (must be between 0.000001 and 100000000.0

Pressure and temperature constraints are set to what EMIT uses (-20 to 80 C, 0.5 to 1.5 bar) but these could be variables as well. Making a narrower range would only disable materials that are not possible to exist in those conditions. 

# Tetracorder version

* If a new version of tetracorder is compiled, files in `tetracorder.cmds/tetracorder5.27a.cmds/` will need to be updated
* Replace location of t1 in cmd-setup-tetrun: Line 20: source=/t1/tetracorder.cmds/tetracorder5.27a.cmds
* Replace location of 	ptc="/usr/local/bin/tetracorder5.27" in `cmd.runtet`: Line 21
* Copy files:
  * Copy deleted channels file eg. `DELETED.channels/delete_cao2015a`
  * Copy DATASETS file for instrument `DATASETS/cao2015a` (this is one line giving the filename of the restart file)
  * Copy restart file eg. `restart_files/r1-ca15a` (has lots of info including correct paths for convolved libraries instead of `/sl1`)