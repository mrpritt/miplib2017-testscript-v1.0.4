#!/usr/bin/awk -f
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#*                                                                           *
#*            This file is part of the test engine for MIPLIB2017            *
#*                                                                           *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


# set all solver specific data:
#  solver ["?"]
#  solverversion ["?"]
#  solverremark [""]
#  bbnodes [0]
#  db [-infty]
#  pb [+infty]
#  aborted [1]
#  timeout [0]

BEGIN {
  solver = "HiGHS";
}
# solver version
/^Running HiGHS / { solverversion = $3; }
# branch and bound nodes
/^  Nodes / { bbnodes = $2; }
# infeasible model
/^Model status        : Infeasible/ {
  db = pb;
}
# dual and primal bound
/^  Primal bound / {
  pb = $3 + 0.0;
}
/^  Dual bound / {
  db = $3 + 0.0;
}
match($0, "Objective value[[:space:]]*:") { ## LP
  pb = $4 + 0.0;
  db = pb;
}

# solving status

match($0, /Status[ \t]*/) {
    st = substr($0, index($0, $2));
    if (st == "Optimal") {
        aborted = 0;
    } else if (st == "Infeasible") {
        pb = +infty;
        db = +infty;
        aborted = 0;
        timeout = 0;
    } else if (st == "Unbounded") {
        pb = -infty;
        db = -infty;
        aborted = 0;
        timeout = 0;
    } else if (st == "Primal infeasible or unbounded") {
        aborted = 0;
        timeout = 0;
    } else if (st == "Time limit reached") {
        aborted = 0;
        timeout = 1;
    }
}

match($0, "Model status[[:space:]]*:") {
    st = substr($0, index($0, $4));
    if (st == "Optimal") {
        aborted = 0;
    } else if (st == "Infeasible") {
        pb = +infty;
        db = +infty;
        aborted = 0;
        timeout = 0;
    } else if (st == "Unbounded") {
        pb = -infty;
        db = -infty;
        aborted = 0;
        timeout = 0;
    } else if (st == "Primal infeasible or unbounded") {
        aborted = 0;
        timeout = 0;
    } else if (st == "Time limit reached") {
        aborted = 0;
        timeout = 1;
    }
}