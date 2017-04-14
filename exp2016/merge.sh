#!/bin/bash

BASE="data/coreko"
GOLD="corekogold"
PLUS="corekoplus"
PLUSSES=`seq -w 1 10`

PARAM01=("filters01" "filters02")
PARAM02=("s0" "s2" "s2+1")

# Create larger corpora cumulatively.

last="${GOLD}"
for p in ${PLUSSES}
do
  this=${PLUS}${p}
  next="${this}X"
  outdir="${BASE}/${next}"
  mkdir -p ${outdir}

  for p1 in ${PARAM01[@]}
  do
    for p2 in ${PARAM02[@]}
    do
      pref1="${BASE}/${last}/${p1}_${p2}"
      pref2="${BASE}/${this}/${p1}_${p2}"
      opref="${outdir}/${p1}_${p2}"
      dict1="${pref1}.dict"
      dict2="${pref2}.dict"
      bow1="${pref1}_bow.mm"
      bow2="${pref2}_bow.mm"
      echo " => ${opref}"
      python src/cowtop-merge.py "${dict1}" "${dict2}" "${bow1}" "${bow2}" "${opref}"
    done
  done

  last=${next}
done
