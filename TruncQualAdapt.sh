#!/bin/bash
FILES=$1
REF=$2
exec<$FILES
while read LINE
        do
        newfile="$(basename $LINE .fastq)"
        TruncateFastq.pl $newfile.fastq 1 36 $newfile.trunc.fastq
        QualFilterFastq.pl $newfile.trunc.fastq 20 18 $newfile.qual.fastq
        rm $newfile.trunc.fastq
        bbduk.sh in=$newfile.qual.fastq ref=$REF k=12 stats=$newfile.stats.txt out=$newfile.clean.fastq
        #rm $newfile.qual.fastq
        mv $newfile.stats.txt ./stats
        done
