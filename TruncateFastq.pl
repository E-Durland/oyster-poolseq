#!/usr/bin/env perl
# written by E Meyer, eli.meyer@science.oregonstate.edu
# distributed without restrictions or guarantees

# -- program description and required arguments
$scriptname=$0; $scriptname =~ s/.+\///g;
if ($#ARGV != 3 || $ARGV[0] eq "-h") 
        {print "\nTruncates a set of short reads in FASTQ format to keep the region specified\n";
        print "Output:\t FASTQ formatted sequences\n";
        print "Usage:\t script sequences start_position end_position output\n";
        print "Arguments:\n";
        print "\t sequences\t file of short reads to be filtered, fastq format\n";
        print "\t start_position\t beginning of the region to keep, nucleotide position\n";
        print "\t end_position\t end of the region to keep, nucleotide position\n";
        print "\t output\t\t a name for the output file (fastq format)\n";
        print "\n"; exit;
        }

my $seqfile = $ARGV[0];		# raw reads, fastq format
my $startloc = $ARGV[1]-1;	# beginning of region to keep, base 1
my $endloc = $ARGV[2]-1;	# end of region to keep, base 1
my $outfile = $ARGV[3];		# name for output file, fastq format

# loop through fastq file and truncate sequences and quality scores
open (IN, $seqfile);
open (OUT, ">$outfile");
my $switch = 0;
while(<IN>)
	{
	chomp;
	$count++;
	if ($count==1) {$ss = substr($_, 0, 4);}
	if ($_ =~ /^$ss/) 
		{
		print OUT $_, "\n";
		next;
		}
	if ($_ =~ /^\+$/) 
		{
		print OUT "$_", "\n";
		next;
		}
	else
		{
		$ssi = $_;
		$slen = length($ssi);
		$subi = substr ($ssi, $startloc, $endloc-$startloc+1);
		print OUT $subi, "\n";
		}
	}
close(IN);
