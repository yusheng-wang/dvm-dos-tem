#!/bin/bash

# T. Carman, Spring 2016

# Simple example script for generating a bunch of static plots
# using the calibration-viewer.py program. Intended to be modified
# as needed.
#

# 
# Command line argument processing
#
function usage () {
  echo "usage: $ ./bulk-plot TAG"
  echo "       $ ./bulk-plot [--numpfts N] [--sparse] [--parallel] [-h | --help] --outdir PATH --tag TAG"
  echo "  --sparse    Prints only one suite, for faster runs and testing."
  echo "  --parallel  Runs the plotting script as a background process so"
  echo "              many plots are made in parallel."
  echo "  --numpfts   Change the number of pfts plotted. '3' will plot pfts 0,1,2".
  echo "  --outdir    The path to a directory in which to store the generated plots."
  echo "  --tag       A pre-fix for the folder continaing the generated plots."
  echo "              The folder will be created within the folder specified at the"
  echo "              path given for '--outdir'. The current git tag is good to use,"
  echo "              but the value you provide for "--tag" can be anything else you like."

  echo "Error: " $1
}

function parallel_ploter () {

  ./calibration/calibration-viewer.py "$@"

}


NUM_PFTS=10
SUITES=("Fire" "Soil" "Vegetation" "VegSoil" "Environment" "NCycle")
TAG=
TARGET_CMT=5
OUTDIR=
PFLAG=   # Set to '&' to run plotting processes in background.

while [ "$1" != "" ]; do
  case $1 in
    -n | --numpfts )    shift
                        NUM_PFTS="$1"
                        ;;

    # useful for debugging so you don't have to 
    # wait for everything to plot
    --sparse )          SUITES=("VegSoil")
                        ;;

    --parallel )        PFLAG="true"
                        ;;

    --tag )             shift
                        TAG="$1"
                        ;;

    --targetcmt )       shift
                        TARGET_CMT="$1"
                        ;;

    --outdir )          shift
                        OUTDIR="$1"
                        ;;

    -h | --help )       usage "no error"
                        exit
                        ;;

    * )                 usage "Problem with command line arguments!"
                        exit 1
  esac
  shift
done

if [[ $TAG == "" ]]
then
  usage "You must supply a tag!"
  exit 1
fi
if [[ $OUTDIR == "" ]]
  then
  usage "You must supply a directory for output!"
  exit 1
fi

if [[ ! -x "calibration/calibration-viewer.py" ]]
then
  echo "Cannot find the plotter from here!"
  echo "Try executing this script ($(basename $0)) from the main dvmdostem directory."
  exit 1
fi

echo "Plotting for pfs 0 to $NUM_PFTS"
echo "Will plot these suites:"
for SUITE in ${SUITES[@]}
do
  echo "    $SUITE"
done
echo "Using TAG: $TAG"

#
# Finally, start working
#
SAVE_LOC="$OUTDIR/$TAG"
echo "Making directory: $SAVE_LOC"
mkdir -p "$SAVE_LOC"

# Collect metadata
cp "config/config.js" "$SAVE_LOC/"
cp "config/calibration_directives.txt" "$SAVE_LOC"
# build metadata? cmd line args?

# Loop over suites and pfts creating and saving a bunch of plots.
for SUITE in ${SUITES[@]};
do

  if [[ "$SUITE" == "Fire" || "$SUITE" == "Environment" ]]
  then

    args="--suite $SUITE --tar-cmtnum $TARGET_CMT --no-show --save-name $SAVE_LOC/$TAG-$SUITE"

    if $PFLAG
    then
      parallel_ploter $args &
    else
      parallel_ploter $args
    fi

  else
    for (( I=0; I<$NUM_PFTS; ++I ))
    do

      args="--suite $SUITE --tar-cmtnum $TARGET_CMT --no-show --save-name $SAVE_LOC/$TAG-$SUITE-pft$I --pft $I"

    if $PFLAG
    then
      parallel_ploter $args &
    else
      parallel_ploter $args
    fi

    done
  fi

done

if $PFLAG
then
  echo "waiting for all sub processes to finish..."
  wait
fi

echo "Done plotting."
