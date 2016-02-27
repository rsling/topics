#!/bin/bash

# This generates a fixed set of BOW corpora to be used
# in COReKo experiment I (February 2016).

# Pass: INFILE SUBEXP ROOT
# INFILE  is the relative path to a COW-XML file.
#
# SUBEXP  is the sub-experiment name (alpha only, please!); something
#         like "cattle13", "cowextra01" or "derekogold".
#
# ROOT    is the overall experiment root folder, usually "data/coreko"

# Sample call which creates all we need for Cattle14, i.e.,
# the COW annotated gold standard documents:
#
# mkbow.sh data/cattle13.xml cowgold data/coreko

# All directory structure will be created automatically!

set -e
set -u

# EXPERIMENT SETUP
# Should not be altered while exp is going on.

FILTERS=( "data/filters01.tab" "data/filters02.tab" )
SELECTORS=( "2" "2,1" "0" )
MERGERS="data/mergers.tab"
MIN_DOCLENGTH=-1

# WORK:

BASE="${3}/${2}"
mkdir -p ${BASE}

for filter in ${FILTERS[@]}
do
  f_suff="$(basename ${filter} '.tab')"
  for selector in ${SELECTORS[@]}
  do
    s_suff="${f_suff}_s$(echo ${selector} | sed s/,/+/g )"
    echo "${BASE}/${s_suff}"
    python src/cowtop-vectorize.py ${1} ${BASE}/${s_suff} ${selector} --filters ${filter} --mergers ${MERGERS} --minlength ${MIN_DOCLENGTH} --erase --debug
  done
done


