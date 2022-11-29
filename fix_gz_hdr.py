#!/usr/bin/env python
import argparse
import os, sys
import shutil
import gzip
import spectral
import re

def get_labsize(fil):
    try:
        with gzip.open(fil) as zref:
            res = zref.read(30).decode("ascii")
            if "LBLSIZE" in res:
                ls = re.findall(".*LBLSIZE=([0-9][0-9]*)[^0-9]*",res)
                if len(ls) > 0:
                    return int(ls[0])
    except gzip.BadGzipFile as exc:
        with open(fil) as fref:
            res = fref.read(30)
            if "LBLSIZE" in res:
                ls = re.findall(".*LBLSIZE=([0-9][0-9]*)[^0-9]*",res)
                if len(ls) > 0:
                    return int(ls[0])
    return None
     
def main():
    parser = argparse.ArgumentParser(description="Update the ENVI hdr on output"\
                           " from tetracorder on smaller files")
    parser.add_argument("--verbose","-v",action="store_true",help="Verbose output")
    parser.add_argument("--bakext", "-e", default=".bak", help="Extension"\
                           " added to backup of original hdr")
    parser.add_argument("infile",help="Output tetracorder map, gzipped or not")
    parser.add_argument("inhdr",default=None,nargs="?",
                     help="Optionally specify hdr name, by default"\
                           " guess based on infile")
    args = parser.parse_args()
    #args = parser.parse_args(["Kalun+kaol.intmx.depth.gz"])
    if not os.path.exists(args.infile):
        raise RuntimeError(f"Could not find file {args.infile}")

    ##If no hdr is specified, then try to guess name
    if not args.inhdr:
        inhdropts = [
            args.infile+".hdr",
            os.path.splitext(args.infile)[0]+".hdr"
        ]
        for opt in inhdropts:
            if os.path.exists(opt):
                print(f"Found input hdr file at {opt}")
                args.inhdr = opt
                break
        if not args.inhdr:
            raise RuntimeError("Could not find matching hdr for file {args.infile}"\
                    " - Specify name in command arguments, see --help")

    ##Open the hdr as a dict
    hdr = spectral.envi.read_envi_header(args.inhdr)

    ##Grab lblsize from the infile, gunzip if needed
    labsize = get_labsize(args.infile)
    if not labsize:
        raise RuntimeError(f"Could not find vicar LABSIZE marker in {args.infile}")

    ##Check first if current hdr has incorrect offset
    orig_off = int(hdr["header offset"])
    if int(orig_off) != labsize:
        ##Backup existing hdr if dest does not exist
        ##  - assume already backed up if it does exist
        bakhdr = args.inhdr+args.bakext
        if not os.path.exists(bakhdr):
            print(f"Moving original hdr to {bakhdr}")
            shutil.copyfile(args.inhdr,bakhdr)
        else:
            print(f"File {bakhdr} exists, assuming it is the original"\
                    " hdr already copied")
        ##Update offset in dict
        hdr["header offset"] = labsize
        ##Write updated hdr
        print(f"Writing hdr {args.inhdr} with header offset {labsize}")
        spectral.envi.write_envi_header(args.inhdr,hdr)
        print("Done")
    else:
        print(f"HDR {args.inhdr} has the correct header offset of {labsize}")
        print(f"No changes made")

if __name__ == "__main__":
    main()
