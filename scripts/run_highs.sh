#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2017            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

SOLVER=$1
BINNAME=$2
NAME=$3
TIMELIMIT=$4
MEMLIMIT=$5   # The memory limit (in MB) # currently unused
SOLFILE=$6
THREADS=$7
MIPGAP=$8


###########################################################
# version using gurobi_cl
###########################################################
echo > $SOLFILE

echo $SOLFILE

# set threads to given value
# set mipgap to given value
OPTFILE=$(mktemp)
cat << EOF > $OPTFILE
threads = $THREADS
mip_rel_gap = $MIPGAP
EOF

# set timing to wall-clock time and pass time limit
# use deterministic mode (warning if not possible)
# read, optimize, display statistics, write solution, and exit
$BINNAME --time_limit $TIMELIMIT --solution_file $SOLFILE --options_file $OPTFILE $NAME

if test -e $SOLFILE
then
    # translate HiGHS solution format into format for solution checker.
    #  The SOLFILE format is a very simple format where in each line
    #  we have a <variable, value> pair, separated by spaces.
    #  A variable name of =obj= is used to store the objective value
    #  of the solution, as computed by the solver. A variable name of
    #  =infeas= can be used to indicate that an instance is infeasible.
    if test ! -s $SOLFILE
    then
	# empty file, i.e., no solution given
	echo "=infeas=" > $SOLFILE
    else
	# grep objective out off the HiGHS log file
	grep "Objective " $SOLFILE | sed 's/.*Objective \([0-9\.eE+-]*\).*/=obj= \1/g' > $SOLFILE.tmp
    sed -n '/# Columns/,/^[[:space:]]*$/p' $SOLFILE | tail -n +2 >> $SOLFILE.tmp
	mv $SOLFILE.tmp $SOLFILE
   fi
fi

# remove HiGHS log
rm HiGHS.log $OPTFILE