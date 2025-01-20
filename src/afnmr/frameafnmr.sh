#!/bin/sh

# All shifts-related stuff should be in the directory containing this script
export AFNMRHOME=~/afnmr
BINDIR=$AFNMRHOME/bin

usage() {

   test $# -gt 0 && echo $1 && echo ""
   echo "`dirname $0` <directory_name> [afnmr flags]"
   echo "   This script takes an input directory containing one or more "
   echo "   PDB files. If additional arguments exist, afnmr will be run "
   echo "   with those arguments."
   echo ""
   echo "[AFNMR flags]"
   $BINDIR/afnmr --help | awk '(NR > 6)'
   exit 1
}

error() {
   echo $1; exit 1
}

test "$1" = "-h" && usage
test "$1" = "--help" && usage
test "$1" = "-H" && usage

# Make sure we got an argument
test $# -gt 0 || usage "No arguments found"

DIRNAME=$1
cd $DIRNAME
shift;

# If we have no more arguments, bail here
test $# -eq 0 && exit 0

# Run afnmr with remaining arguments in parallel
test -z "$NCPUS" && NCPUS=1

ARGS="$@ -workdir"
python -c "import glob; print(' '.join([i.strip('.pdb') for i in glob.glob('*.pdb')]))" | \
   xargs -n 1 -P $NCPUS ${BINDIR}/afnmr $ARGS
   
rm -f leap.in
