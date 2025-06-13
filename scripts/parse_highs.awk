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

# solving status

/^  Status/ {
    st = $2;
    aborted = 0;
    timeout = 0;
    if (st == "Optimal") {
        aborted = 0;
    } else if (st == "Infeasible") {
        aborted = 0;
    } else if (st == "Unbounded") {
        aborted = 0;
    } else if (st == "Primal infeasible or unbounded") {
        aborted = 0;
    } else if (st == "Time limit reached") {
        timeout = 1;
    }
}

/^Model status        :/ {
    st = $2;
    aborted = 0;
    timeout = 0;
    if (st == "Optimal") {
        aborted = 0;
    } else if (st == "Infeasible") {
        aborted = 0;
    } else if (st == "Unbounded") {
        aborted = 0;
    } else if (st == "Primal infeasible or unbounded") {
        aborted = 0;
    } else if (st == "Time limit reached") {
        timeout = 1;
    }
}