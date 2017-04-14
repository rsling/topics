#!/bin/bash

DIRS="`ls -d -1 data/coreko/derekogold/` `ls -d -1 data/coreko/derekoplus??X/`"
PARAM01=("filters01" "filters02")
PARAM02=("s0" "s2" "s2+1")
TOPICS=`seq -w 20 10 90`
RESULTS="cow.tsv"
NUM_TARGET=886
ANNO="data/dereko.domain.single.tsv"
OUT="run"

\rm -f ${RESULTS}

for dir in ${DIRS[@]}
do
  pref=$(basename ${dir})
  for p1 in ${PARAM01[@]}
  do
    for p2 in ${PARAM02[@]}
    do
      for topics in ${TOPICS[@]}
      do
	subexp="${pref}_${p1}_${p2}_${topics}"
	bow="${dir}/${p1}_${p2}_bow.mm"
	dict="${dir}/${p1}_${p2}.dict"
	res=`./exp.sh ${subexp} ${bow} ${dict} ${ANNO} ${OUT} ${topics} ${NUM_TARGET}`
	echo ${res}
	echo -e ${res} >> ${RESULTS}
      done
    done
  done
done

