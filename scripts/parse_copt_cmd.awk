#!/usr/bin/awk -f
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2017            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

## this script requires GAWK

# set all solver specific data:
#  solver ["?"]
#  solverversion ["?"]
#  solverremark [""]
#  bbnodes [0]
#  db [-infty]
#  pb [+infty]
#  aborted [1]
#  timeout [0]

# solver name
BEGIN {
   solver = "COPT";
   solverremark = "";
   solver_objsense = +1;
   solver_type = "MIP";
   timeout = 0;
}
# solver version
/^Using Cardinal Optimizer/ { solverversion = $4; }

# objective sense and solver type
match($0, /^([^ ]+) a ([^ ]+) problem\.$/) {
    sense = substr($0, RSTART[1], RLENGTH[1])
    if (sense == "minimization")
        solver_objsense = +1;
    else if (sense == "maximization")
        solver_objsense = -1;
    solver_type = substr($0, RSTART[2], RLENGTH[2])
}

match($0, "Best solution[[:space:]]*: ") {
    pb = substr($0, RLENGTH + 1);
}
match($0, "Best bound[[:space:]]*: ") {
    db = substr($0, RLENGTH + 1);
}
match($0, "Solve node[[:space:]]*: ") {
   bbnodes = substr($0, RLENGTH + 1);
}
match($0, "MIP status[[:space:]]*: ") {
   st = substr($0, RLENGTH + 1);
   aborted = 0;
   if (st == "solved") {
    aborted = 0;
   } else if (st == "stopped (memory exceeded)") {
    timeout = 1;
   }
}
match($0, "Solution status[[:space:]]*: ") {
   st = substr($0, RLENGTH + 1);
   if (st == "unknown") {
    pb = solver_objsense * infty;
   }
}
