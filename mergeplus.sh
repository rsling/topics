#!/bin/bash

set -e
set -u

BASE0="run"
BASE1=${1}
BASE2=${2}
OUTNAME="${3}"

PARAM01=("filters01" "filters02")
PARAM02=("s0" "s2" "s2+1")

# Create larger corpora cumulatively.

outdir="${BASE0}/${OUTNAME}"

mkdir -p ${outdir}

for p1 in ${PARAM01[@]}
do
  for p2 in ${PARAM02[@]}
  do
    dict1="${BASE1}/${p1}_${p2}.dict"
    dict2="${BASE2}/${p1}_${p2}.dict"
    bow1="${BASE2}/${p1}_${p2}_bow.mm"
    bow2="${BASE2}/${p1}_${p2}_bow.mm"
    opref="${outdir}/${p1}_${p2}"
    echo "${opref}"
    python src/cowtop-merge.py "${dict1}" "${dict2}" "${bow1}" "${bow2}" "${opref}"
  done
done
