#!/bin/bash
set +e

for TOPO in *.topo; do

  # If e.g. pydot postprocessing would be incorporated,
  # it would make sense to handle extensions case-by-case.
  # But for now, use a bulk extension ".out" for all cases.
  OUTFILE=${TOPO%.*topo}.out

  # Opportunistically assign the first found switch as a single treeify root
  TREEIFY=t.tmp
  grep -E '^Switch' ${TOPO} | head -1 | awk '{print $3}' | sed 's/"//g' > ${TREEIFY}

  # Execute tests
  CMD="python3 ../src/ibtopotool.py -o ${OUTFILE} ${TOPO}";                                $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
#  CMD="python3 ../src/ibtopotool.py -s -o ${OUTFILE} ${TOPO}";                             $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
#  CMD="python3 ../src/ibtopotool.py -s --shortlabels -o ${OUTFILE} ${TOPO}";               $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
  CMD="python3 ../src/ibtopotool.py -t ${TREEIFY} -o ${OUTFILE} ${TOPO}";                  $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
  CMD="python3 ../src/ibtopotool.py -t ${TREEIFY} --shortlabels -o ${OUTFILE} ${TOPO}";    $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
#  CMD="python3 ../src/ibtopotool.py -s -t ${TREEIFY} -o ${OUTFILE} ${TOPO}";               $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
#  CMD="python3 ../src/ibtopotool.py -s -t ${TREEIFY} --shortlabels -o ${OUTFILE} ${TOPO}"; $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
  CMD="python3 ../src/ibtopotool.py --slurm -o ${OUTFILE} ${TOPO}";                        $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
  CMD="python3 ../src/ibtopotool.py --slurm -t ${TREEIFY} -o ${OUTFILE} ${TOPO}";          $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
#  CMD="python3 ../src/ibtopotool.py --slurm -s -o ${OUTFILE} ${TOPO}";                     $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
#  CMD="python3 ../src/ibtopotool.py --slurm -s -t ${TREEIFY} -o ${OUTFILE} ${TOPO}";       $CMD && echo "Success: ${CMD}" || echo "Failure: ${CMD}"
  rm ${TREEIFY}
done

#Cleanup
if stat *.out 1>/dev/null 2>/dev/null; then
  rm *.out
fi
