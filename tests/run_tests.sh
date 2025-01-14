#!/bin/bash

set -e

cleanup() {
  if stat *.out 1>/dev/null 2>/dev/null; then rm *.out; fi
  if stat t.tmp 1>/dev/null 2>/dev/null; then rm t.tmp; fi
}
printfail_cleanup() {
  echo "Failure: ${CMD}"
  cleanup
}
trap printfail_cleanup ERR

for TOPO in *.topo; do

  # If e.g. pydot postprocessing would be incorporated,
  # it would make sense to handle extensions case-by-case.
  # But for now, use a bulk extension ".out" for all output cases.
  OUTFILE=${TOPO%.*topo}.out

  # Opportunistically assign the first found switch as a single treeify root
  grep -E '^Switch' ${TOPO} | head -1 | awk '{print $3}' | sed 's/"//g' > t.tmp

  CMD_ARRAY=(
    "python3 ../src/ibtopotool.py -o ${OUTFILE} ${TOPO}"
    "python3 ../src/ibtopotool.py -s -o ${OUTFILE} ${TOPO}"
    "python3 ../src/ibtopotool.py -s --shortlabels -o ${OUTFILE} ${TOPO}"
    "python3 ../src/ibtopotool.py -t t.tmp -o ${OUTFILE} ${TOPO}"
    "python3 ../src/ibtopotool.py -t t.tmp --shortlabels -o ${OUTFILE} ${TOPO}"
    "python3 ../src/ibtopotool.py -s -t t.tmp -o ${OUTFILE} ${TOPO}"
    "python3 ../src/ibtopotool.py -s -t t.tmp --shortlabels -o ${OUTFILE} ${TOPO}"
    "python3 ../src/ibtopotool.py --slurm -o ${OUTFILE} ${TOPO}"
    "python3 ../src/ibtopotool.py --slurm -t t.tmp -o ${OUTFILE} ${TOPO}"
    "python3 ../src/ibtopotool.py --slurm -s -o ${OUTFILE} ${TOPO}"
    "python3 ../src/ibtopotool.py --slurm -s -t t.tmp -o ${OUTFILE} ${TOPO}"
  )

  # Execute tests
  for ((i = 0; i < ${#CMD_ARRAY[@]}; i++))
  do
    export CMD="${CMD_ARRAY[$i]}"
    ${CMD}
    echo "Success: ${CMD}"
  done

  cleanup
done


## These could be added at some point, but that will require some python side parsing adjustments
#for EXAMPLE in net net.1 net.2sw2path net.2sw2path4hca net.2sw2path4hca2port; do
#  curl "https://raw.githubusercontent.com/linux-rdma/ibsim/refs/heads/master/net-examples/${EXAMPLE}" -o ${EXAMPLE}.topo
#done
