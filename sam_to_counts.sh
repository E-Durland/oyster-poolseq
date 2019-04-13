#!/bin/bash
REF=$1
for i in *.filt.sam;
        do
        newfile="$(basename $i .filt.sam)"
        SAMBasecaller_3.pl -i $i -r $REF -c 5 -o $newfile.bc.tab

~/scripts/CombineBaseCounts.pl *.bc.tab > combined.tab
~/scripts/evan/Combinator.py combined.tab All_comb.txt
