#!/bin/bash

set -e

# 

if [ "${1}" = "" ]
then
  echo "Usage: exp.sh INFILE NUM_TOPICS CREATE_CORPUS"
  echo "INFILE         Input file basename without .xml suffix."
  echo "CREATE_CORPUS  Y for fresh BOW corpus creation, N for skipping"
  exit
fi 

IN=data/
OUT=run/
NUM_TOPICS=${2}
NUM_TARGETS=870
LARGE="${1}"
PROJ="${LARGE}_${NUM_TOPICS}"
RESULTSU="${OUT}/${PROJ}_lsi_full.txt"
RESULTSF="${OUT}/${PROJ}_lsi_filt.txt"


mkdir -p ${OUT}

# Generate corpus if necessary.
if [ "${3}" = "Y" ]
then
  python src/cowtop-vectorize.py ${IN}/${LARGE}.xml ${OUT}/${LARGE} 2 --erase --filters ${IN}/filters.tab --mergers ${IN}/mergers.tab --debug
fi

# Run LSI.
python src/cowtop-lsi.py ${OUT}/${LARGE}_bow.mm ${OUT}/${LARGE}.dict ${OUT}/${PROJ}_lsi ${NUM_TOPICS} --erase

# Generate ARFF.
python src/cowtop-makearff.py <(head -n ${NUM_TARGETS} ${OUT}/${PROJ}_lsi_matrix_lsi.tsv) ${IN}/cattle13.domain.single.tsv ${NUM_TOPICS} ${IN}/domain_names.tsv ${OUT}/${PROJ}_lsi_${NUM_TOPICS} --erase

# Create modified ARFF.
ARFF="${OUT}/${LARGE}_${NUM_TOPICS}_lsi_${NUM_TOPICS}.arff"
MARFF="${OUT}/${LARGE}_${NUM_TOPICS}_lsi_${NUM_TOPICS}_filtered.arff"
gsed '/\@DATA/,$ {/Science\|Medical\|Philosophy\|Individual\|Technology/d}' ${ARFF} | gsed 's/Science\|Medical\|Philosophy\|Individual\|Technology//g' > ${MARFF}

# Weka.
java -Xmx6g weka.classifiers.functions.SMO -C 1.0 -L 0.0010 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.Puk -O 1.0 -S 1.0 -C 250007" -t ${ARFF} > ${RESULTSU}
java -Xmx6g weka.classifiers.functions.SMO -C 1.0 -L 0.0010 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.Puk -O 1.0 -S 1.0 -C 250007" -t ${MARFF} > ${RESULTSF}

acc_tr_u=`grep '=== Error on training data ===' -A 5 ${RESULTSU} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
acc_cv_u=`grep '=== Stratified cross-validation ===' -A 5 ${RESULTSU} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
acc_tr_f=`grep '=== Error on training data ===' -A 5 ${RESULTSF} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
acc_cv_f=`grep '=== Stratified cross-validation ===' -A 5 ${RESULTSF} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
echo -e "${PROJ}\t${acc_tr_u}\t${acc_cv_u}\t${acc_tr_f}\t${acc_cv_f}"
