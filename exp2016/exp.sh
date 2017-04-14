#!/bin/bash

set -e

# Science\|Medical\|Philosophy\|Individual\|Technology

if [ "${1}" = "" ]
then
  echo "Usage: exp.sh PROJ_PRE CORPUS DICT ANNO OUTDIR NUM_TOPICS NUM_GOLD [FILTER]"
  echo "PROJ_PRE       Project name prefix."
  echo "CORPUS         Input BOW corpus file."
  echo "DICT           Input dictionary file."
  echo "ANNO           File with domain annotations for gold docs."
  echo "OUTDIR         Out directory PARENT folder (e.g. run)."
  echo "NUM_TOPICS     Number of topics."
  echo "NUM_GOLD       Number of the annotated documents in corpus."
  echo "               (It has to be the first NUM_GOLD in corpus!)"
  echo "FILTER         Regex to filter low-freq domains."
  echo "               If not given, default will be used!"
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

if [ "${8}" = '' ]
then
  FILTER="Science\|Medical\|Philosophy\|Individual\|Technology"
else
  FILTER="${8}"
fi

PROJ="${PROJ_PRE}_$(basename ${CORPUS} _bow.mm)_lsi_${NUM_TOPICS}"
PROJ_OUT="${OUTDIR}/${PROJ_PRE}"

ARFF="${PROJ_OUT}/${PROJ}.arff"
MARFF="${PROJ_OUT}/${PROJ}_filtered.arff"

RESULTSU="${PROJ_OUT}/${PROJ}_full.txt"
RESULTSF="${PROJ_OUT}/${PROJ}_filt.txt"

MATRIX="${PROJ_OUT}/${PROJ}_matrix_lsi.tsv"

# REPORT
# echo "----------------------------------------------------------------------"
# echo "VAR"
# echo "Corpus       ${CORPUS}"
# echo "Dictionary   ${DICT}"
# echo "Annotations  ${ANNO}"
# echo "Project      ${PROJ}"
# echo "Out folder   ${PROJ_OUT}"
# echo "Topics       ${NUM_TOPICS}"
# echo "Gold docs    ${NUM_GOLD}"
# echo "ARFF         ${ARFF}"
# echo "Res. full    ${RESULTSU}"
# echo "Res. red.    ${RESULTSF}"
# echo "Matrix       ${MATRIX}"
# echo "Filters      ${FILTER}"
# echo "----------------------------------------------------------------------"
# echo "CONST"
# echo "Dom. names   ${DOM_NAMES}"
# echo "----------------------------------------------------------------------"

mkdir -p ${PROJ_OUT}

# Run LSI.
python src/cowtop-lsi.py ${CORPUS} ${DICT} ${PROJ_OUT}/${PROJ} ${NUM_TOPICS} --erase --low 5 --high 0.4 --iters=5 --samples=500

# Generate ARFF.
python src/cowtop-makearff.py <(head -n ${NUM_GOLD} ${MATRIX}) ${ANNO} ${NUM_TOPICS} ${DOM_NAMES} ${PROJ_OUT}/${PROJ} --erase


# Create modified ARFF.
gsed "/\@DATA/,$ {/${FILTER}/d}" ${ARFF} | gsed "s/${FILTER}//g" > ${MARFF}

# Weka.
java -Xmx6g weka.classifiers.functions.SMO -C 1.0 -L 0.0010 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.Puk -O 1.0 -S 1.0 -C 250007" -t ${ARFF} > ${RESULTSU}
java -Xmx6g weka.classifiers.functions.SMO -C 1.0 -L 0.0010 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.Puk -O 1.0 -S 1.0 -C 250007" -t ${MARFF} > ${RESULTSF}

acc_tr_u=`grep '=== Error on training data ===' -A 7 ${RESULTSU} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
kappa_tr_u=`grep '=== Error on training data ===' -A 7 ${RESULTSU} | grep 'Kappa statistic' | gsed 's/^Kappa statistic \+//'`
acc_cv_u=`grep '=== Stratified cross-validation ===' -A 7 ${RESULTSU} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
kappa_cv_u=`grep '=== Stratified cross-validation ===' -A 7 ${RESULTSU} | grep 'Kappa statistic' | gsed 's/^Kappa statistic \+//'`

acc_tr_f=`grep '=== Error on training data ===' -A 7 ${RESULTSF} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
kappa_tr_f=`grep '=== Error on training data ===' -A 7 ${RESULTSF} | grep 'Kappa statistic' | gsed 's/^Kappa statistic \+//'`
acc_cv_f=`grep '=== Stratified cross-validation ===' -A 7 ${RESULTSF} | grep 'Correctly Class' | gsed 's/^.* \([0-9\.]\+\) \+%.*$/\1/'`
kappa_cv_f=`grep '=== Stratified cross-validation ===' -A 7 ${RESULTSF} | grep 'Kappa statistic' | gsed 's/^Kappa statistic \+//'`

echo -e "${PROJ}\t${acc_tr_u}\t${kappa_tr_u}\t${acc_cv_u}\t${kappa_cv_u}\t${acc_tr_f}\t${kappa_tr_f}\t${acc_cv_f}\t${kappa_cv_f}"
