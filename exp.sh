#!/bin/bash

set -e
set -u

# Pass INFILE without path and ".xml" suffix, NUM_TOPICS, CREATE_CORPUS ("y" or "n"}

IN=data/
OUT=run/
NUM_TOPICS=${2}
NUM_TARGETS=870
LARGE="${1}"

PROJ="${LARGE}_${NUM_TOPICS}"

mkdir -p ${OUT}

if [ "${3}" = "y" ]
then
  echo
  echo "Preparing BOW corpus and lexicon."
  time python src/cowtop-vectorize.py ${IN}/${LARGE}.xml ${OUT}/${LARGE} 2 --erase --filters ${IN}/filters.tab --mergers ${IN}/mergers.tab --debug
fi

echo
echo "Running LSI."
time python src/cowtop-lsi.py ${OUT}/${LARGE}_bow.mm ${OUT}/${LARGE}.dict ${OUT}/${PROJ}_lsi ${NUM_TOPICS} --erase

echo
echo "Creating ARFF from LSI."
time python src/cowtop-makearff.py <(head -n ${NUM_TARGETS} ${OUT}/${PROJ}_lsi_matrix_lsi.tsv) ${IN}/cattle13.domain.single.tsv ${NUM_TOPICS} ${IN}/domain_names.tsv ${OUT}/${PROJ}_lsi_${NUM_TOPICS} --erase

echo
echo "Running Weka (SMO/Puk)."
time java -Xmx6g weka.classifiers.functions.SMO -C 1.0 -L 0.0010 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.Puk -O 1.0 -S 1.0 -C 250007" -t ${OUT}/${LARGE}_${NUM_TOPICS}_lsi_${NUM_TOPICS}.arff > "${OUT}/${PROJ}_lsi.txt"

echo
echo "Done."
echo
