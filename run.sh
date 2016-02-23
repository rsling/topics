#!/bin/bash

set -e
set -u

IN=data/
OUT=run/
NUM_TOPICS=30

echo
echo " === COW / DeReKo topic modelling experiments demo ==="

mkdir -p ${OUT}

echo
echo "Preparing BOW corpus and lexicon."
time python src/cowtop-vectorize.py ${IN}/cattle13.xml ${OUT}/cattle13 2 --erase --filters ${IN}/filters.tab --mergers ${IN}/mergers.tab --debug

echo
echo "Running LDA."
time python src/cowtop-lda.py ${OUT}/cattle13_bow.mm ${OUT}/cattle13.dict ${OUT}/cattle13_lda ${NUM_TOPICS} --erase

echo
echo "Running LSI"
time python src/cowtop-lsi.py ${OUT}/cattle13_bow.mm ${OUT}/cattle13.dict ${OUT}/cattle13_lsi ${NUM_TOPICS} --erase

echo
echo "Creating ARFF from LDA."
time python src/cowtop-makearff.py ${OUT}/cattle13_lda_matrix_lda.tsv ${IN}/cattle13.domain.single.tsv ${NUM_TOPICS} ${IN}/domain_names.tsv ${OUT}/cattle13_lda_${NUM_TOPICS} --erase

echo
echo "Creating ARFF from LSI."
time python src/cowtop-makearff.py ${OUT}/cattle13_lsi_matrix_lsi.tsv ${IN}/cattle13.domain.single.tsv ${NUM_TOPICS} ${IN}/domain_names.tsv ${OUT}/cattle13_lsi_${NUM_TOPICS} --erase

echo
echo "Done."
echo 

