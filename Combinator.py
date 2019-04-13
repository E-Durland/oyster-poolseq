#!/usr/bin/env python2.7
import io
import sys
import math

IN = sys.argv[1]
OUT = sys.argv[2]
min_cov = 50
max_cov = 1000
fhandle = open(IN,"rU")
whandle = open(OUT,'a')
header = fhandle.readline()
head_split = header.strip().split("\t")
new_head = ("\t".join(head_split[0:3])+ "\t"+ str("alleles")+ "\t" + "\t".join(head_split[3:len(head_split)]))
whandle.write(new_head+"\n")

#first, in order to determine major/minor alleles for all the reads, read each sample
#into a dictionary and make a dictionary of these dictionaries:
for line in fhandle:
    new_line = []
    s_order = []
    smpl_counter = 0
    NA_counter = 0
    read_dicts = dict()
    line_clean = line.strip().split("\t")
    sum_A = 0
    sum_C = 0
    sum_G = 0
    sum_T = 0
    for sample in line_clean[3:len(line_clean)]:
        smpl_counter = smpl_counter +1
        s_name = "smpl" + str(smpl_counter)
        s_order.append(s_name)
        read_dicts[s_name] = dict()
        s_reads =  sample.split("/")
        read_dicts[s_name]["A"] = int(s_reads[0])
        read_dicts[s_name]["C"] = int(s_reads[1])
        read_dicts[s_name]["G"] = int(s_reads[2])
        read_dicts[s_name]["T"] = int(s_reads[3])
    for smpl in read_dicts.keys():
        sum_A = sum_A + read_dicts[smpl]["A"]
        sum_C = sum_C + read_dicts[smpl]["C"]
        sum_G = sum_G + read_dicts[smpl]["G"]
        sum_T = sum_T + read_dicts[smpl]["T"]
    sums = {
        "A" : sum_A,
        "C" : sum_C,
        "G" : sum_G,
        "T" : sum_T
        }
    for i in sums.keys():
        if sums[i] <2:
            del sums[i]
    
    #if sum_A > 0:
    #    sums["A"] = sum_A
    #if sum_C > 0:
    #    sums["C"] = sum_C
    #if sum_G > 0:
    #    sums["G"] = sum_G
    #if sum_T > 0:
    #    sums["T"] = sum_T
    if len(sums.keys()) == 1:
        maj_nt = str(sums.keys()[0])
        min_nt = "-"
    if len(sums.keys()) == 2:
        min_rd = min(sums.values())
        maj_rd = max(sums.values())
        if min_rd == maj_rd:
            maj_nt = sums.keys()[0]
            min_nt = sums.keys()[1]
        else:
            for i in sums.keys():
                if sums[i] == maj_rd:
                    maj_nt = str(i)
                if sums[i] == min_rd:
                    min_nt = str(i)
#if you want to eliminate any case where a locus is called with 3 alleles,
#use the next two lines:

    if len(sums.keys()) >2 or len(sums.keys()) ==0:
        continue
    
#if you want to be lenient and allow for some small genotyping error across
#all samples (say 3 mis-called bases across potentially thousands of reads)
#then use this next code chunk:

#    if len(sums.keys()) == 3 and min(sums.values()) <3:
#        for i in sums.keys():
#            if sums[i]== min(sums.values()):
#                del sums[i]
#        min_rd = min(sums.values())
#        maj_rd = max(sums.values())
#        if min_rd == maj_rd:
#            maj_nt = sums.keys()[0]
#            min_nt = sums.keys()[1]
#        else:
#            for i in sums.keys():
#                if sums[i] == maj_rd:
#                    maj_nt = str(i)
#                if sums[i] == min_rd:
#                    min_nt = str(i)

#but if 4 alleles are being called, just toss the locus:
#    if len(sums.keys()) == 4:
#        continue

#finally, call your major and minor alleles:    
    alleles = str(maj_nt) + "/" + str(min_nt)
#Now, read each sample dictionary back into a new line of text:
    for smpl in s_order:
        s_reads = sum(read_dicts[smpl].values())
        if s_reads < min_cov or s_reads > max_cov:
            smpl_out = "NA"
            NA_counter = NA_counter + 1
        else:
            s_maj_rd = read_dicts[smpl][maj_nt]
            if min_nt == "-":
                s_min_rd = 0
            else:
                s_min_rd = read_dicts[smpl][min_nt]                
            smpl_out = str(s_maj_rd) + "/" + str(s_min_rd)
        new_line.append(smpl_out)
#Finally, join the new line with the tag/locus information and print:
    if smpl_counter > NA_counter + 1:
        whandle.write("\t".join(line_clean[0:3]) + "\t" + alleles + "\t" + "\t".join(new_line)+"\n") 
    else:
        continue
    
