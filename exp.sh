#!/bin/bash

set -e
set -u

if [ "${1}" = "" ]
then
  echo "Usage: exp.sh INFILE NUM_TOPICS"
  echo "PROJ_PRE       Project name prefix."
  echo "CORPUS         Input BOW corpus file."
  echo "DICT           Input dictionary file."
  echo "ANNO           File with domain annotations for gold docs."
  echo "OUTDIR         Out directory PARENT folder (e.g. run)."
  echo "NUM_TOPICS     Number of topics."
  echo "NUM_GOLD       Number of the annotated documents in corpus."
  echo "               (It has to be the first NUM_GOLD in corpus!)"
  exit
fi 

# Constants
DOM_NAMES="data/domain_names.tsv"


PROJ_PRE="${1}"
CORPUS="${2}"
DICT="${3}"
ANNO="${4}"
OUTDIR="${5}"
NUM_TOPICS="${6}"
NUM_GOLD="${7}"

PROJ="${PROJ_PRE}_$(basename ${CORPUS} _bow.mm)_lsi_${NUM_TOPICS}"
PROJ_OUT="${OUTDIR}/${PROJ_PRE}"

RESULTSU="${PROJ_OUT}/${PROJ}_full.txt"
RESULTSF="${PROJ_OUT}/${PROJ}_filt.txt"

MATRIX="${PROJ_OUT}/${PROJ}_matrix_lsi.tsv"

# REPORT
echo "----------------------------------------------------------------------"
echo "VAR"
echo "Corpus       ${CORPUS}"
echo "Dictionary   ${DICT}"
echo "Annotations  ${ANNO}"
echo "Project      ${PROJ}"
echo "Out folder   ${PROJ_OUT}"
echo "Topics       ${NUM_TOPICS}"
echo "Gold docs    ${NUM_GOLD}"
echo "Res. full    ${RESULTSU}"
echo "Res. red.    ${RESULTSF}"
echo "Matrix       ${MATRIX}"
echo "----------------------------------------------------------------------"
echo "CONST"
echo "Dom. names   ${DOM_NAMES}"
echo "----------------------------------------------------------------------"

mkdir -p ${PROJ_OUT}

# Run LSI.
python src/cowtop-lsi.py ${CORPUS} ${DICT} ${PROJ_OUT}/${PROJ} ${NUM_TOPICS} --erase

# Generate ARFF.
python src/cowtop-makearff.py <(head -n ${NUM_GOLD} ${MATRIX}) ${ANNO} ${NUM_TOPICS} ${DOM_NAMES} ${PROJ_OUT}/${PROJ} --erase

exit

# Create modified ARFF.
#ARFF="${OUT}/${LARGE}_${NUM_TOPICS}_lsi_${NUM_TOPICS}.arff"
#MARFF="${OUT}/${LARGE}_${NUM_TOPICS}_lsi_${NUM_TOPICS}_filtered.arff"
#gsed '/\@DATA/,$ {/Science\|Medical\|Philosophy\|Individual\|Technology/d}' ${ARFF} | gsed 's/Science\|Medical\|Philosophy\|Individual\|Technology//g' > ${MARFF}

# Weka.
java -Xmx6g weka.classifiers.functions.SMO -C 1.0 -L 0.0010 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.Puk -O 1.0 -S 1.0 -C 250007" -t ${ARFF} > ${RESULTSU}
#java -Xmx6g weka.classifiers.functions.SMO -C 1.0 -L 0.0010 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.Puk -O 1.0 -S 1.0 -C 250007" -t ${MARFF} > ${RESULTSF}

acc_tr_u=`grep '=== Error on training data ===' -A 5 ${RESULTSU} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
acc_cv_u=`grep '=== Stratified cross-validation ===' -A 5 ${RESULTSU} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
#acc_tr_f=`grep '=== Error on training data ===' -A 5 ${RESULTSF} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
#acc_cv_f=`grep '=== Stratified cross-validation ===' -A 5 ${RESULTSF} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
#echo -e "${PROJ}\t${acc_tr_u}\t${acc_cv_u}\t${acc_tr_f}\t${acc_cv_f}"
echo -e "${PROJ}\t${acc_tr_u}\t${acc_cv_u}"
