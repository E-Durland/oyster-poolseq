#!/bin/bash
FILES=$1
REF=$2
exec<$FILES
while read LINE
        do
        newfile="$(basename $LINE .clean.fastq)"
        gmapper --qv-offset 33 -Q --strata -o 3 -N 1 $LINE $REF > $newfile.sam
        echo $LINE mapped and written to: $newfile.sam
        #rm -f $LINE
        done