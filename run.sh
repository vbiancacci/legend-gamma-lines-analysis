#!/usr/bin/env bash

rm resolution_*
rm exposure_*
rm tmp/*

gamma_src_code="$(grep -oP '(?<="gamma-src-code": ")[^"]*' $1)"
cut="$(grep -oP '(?<="cut": ")[^"]*' $1)"
cut=$(echo "${cut//\ }")
detector_type="$(grep -oP '(?<="detectors": ")[^"]*' $1)"
if [ "$detector_type" == "single" ]; then
  file="./list_detectors_p3p4.json"
  detector_list=$(python-3.9.6 -c \
"import json;
with open('$file', 'r') as f:
  print(json.load(f)['detector_p3p4'])")
  for d in $detector_list
   do
    d_name=$(echo "${d//\'}")
    d_name=$(echo "${d_name//\[}")
    d_name=$(echo "${d_name//\]}")
    d_name=$(echo "${d_name//\,}")
    JobName="$cut"_"$d_name""_bat"
    qsub -N $JobName run-bat.qsub $1 $gamma_src_code $detector_type $d_name $cut
    sleep 10
    done
   else
    JobName="$cut"_"$detector_type""_bat"
    qsub -N $JobName run-bat.qsub $1 $gamma_src_code $detector_type $cut
fi

