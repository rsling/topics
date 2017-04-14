#!/bin/bash

for i in `seq -f "%02g" 10`
do
  of="decow14agg${i}.xml"
  \rm -f ${of}
  cat cattle13.xml >> ${of}
  for j in `seq -f "%02g" ${i}`
  do
    cat decow14a${j}.xml >> ${of}
  done
done
