#!/usr/bin/env bash
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2017            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

SOLVER=$1
BINNAME=$2
NAME=$3
TIMELIMIT=$4
MEMLIMIT=$5   # The memory limit (in MB)
SOLFILE=$6
THREADS=$7
MIPGAP=$8

# import some useful functions that are reused by other scripts
. $(dirname "${BASH_SOURCE[0]}")/run_functions.sh

TMPFILE=check.$SOLVER.tmp

echo > $TMPFILE
echo > $SOLFILE

echo "#COPT script file"               >> $TMPFILE

# disable log file
echo set logfile null                  >> $TMPFILE

# set threads to given value
if test $THREADS != 0
then
    echo set threads $THREADS          >> $TMPFILE
fi

# set mipgap to given value
echo set relgap $MIPGAP >> $TMPFILE

# set timing to wall-clock time and pass time limit
echo set timelimit $TIMELIMIT          >> $TMPFILE

# read, optimize, display statistics, write solution, and exit
echo read $NAME                        >> $TMPFILE
echo display objsense                  >> $TMPFILE  # to identify obj sense
echo                                   >> $TMPFILE
echo optimize                          >> $TMPFILE
echo write $SOLFILE.sol                >> $TMPFILE
echo set logfile $SOLFILE              >> $TMPFILE  # create file to mark successful run
echo display bestobj                   >> $TMPFILE
echo set logfile null                  >> $TMPFILE
echo quit                              >> $TMPFILE

cat $TMPFILE
$BINNAME -i $TMPFILE

if test -f $SOLFILE
then
    # translate COPT solution format into format for solution checker.
    #  The SOLFILE format is a very simple format where in each line
    #  we have a <variable, value> pair, separated by spaces.
    #  A variable name of =obj= is used to store the objective value
    #  of the solution, as computed by the solver. A variable name of
    #  =infeas= can be used to indicate that an instance is infeasible.
    if test -f $SOLFILE.sol
    then
        sed 's/# Objective value/=obj=/' $SOLFILE.sol > $SOLFILE
    else
	    echo "=infeas=" > $SOLFILE
    fi
fi
rm -f $SOLFILE.sol

# remove tmp file
rm $TMPFILE
