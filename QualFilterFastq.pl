#!/usr/bin/perl
# written by E Meyer, eli.meyer@science.oregonstate.edu
# distributed without any guarantees or restrictions
use Bio::SeqIO;
use Bio::Seq::Quality;
$scriptname=$0; $scriptname =~ s/.+\///g;

# -- program description and required arguments
unless ($#ARGV == 3)
        {print "\nRemoves reads containing too many low quality basecalls from a set of short sequences \n";
        print "Output:\t high-quality reads in FASTQ format\n";
        print "Usage:\t $scriptname input.fastq low_score min_LQ output.fastq\n";
        print "Arguments:\n";
        print "\t input.fastq\t raw input reads in FASTQ format\n";
        print "\t low score\t quality scores below this are considered low quality (LQ)\n";
        print "\t min_LQ\t\t reads with more than this many LQ bases are excluded\n";
        print "\t output.fastq\t name for ourput file of HQ reads in FASTQ format\n";
        print "\n"; exit;
        }

my $fastqfile = $ARGV[0];
my $lowq = $ARGV[1];
my $minlq = $ARGV[2];
my $outfqfile = $ARGV[3];

#my $inseqs = new Bio::SeqIO(-file=>$fastqfile, -format=>"fastq-illumina");
my $inseqs = new Bio::SeqIO(-file=>$fastqfile, -format=>"fastq");

my %sh; my $scount = 0;
while ($seq = $inseqs->next_seq) 
	{
	$scount++;
	$qo = new Bio::Seq::Quality(-accession_number=>$seq->display_id, -qual=>$seq->qual,
				-verbose=>-1);
	$qot = $qo->qual_text;
	@qoa = split(" ", $qot);
	$qid = $qo->accession_number;
	$lqcount = 0;
	foreach $q (@qoa)
		{	
		if ($q - $const < $lowq) {$lqcount++;}
		}
	if ($lqcount > $minlq) {$toolow++; next;}
	$gh{$qid}++;
	}

print "Output from ", $scriptname, "\n";
print "Checked ", $scount, " reads.\n";
print $toolow, " failed.\n";
print $scount - $toolow, " passed.\n";
print $toolow/$scount, " rejection rate.\n";

print "Writing sequences to output...\n";
#my $inseqs = new Bio::SeqIO(-file=>$fastqfile, -format=>"fastq-illumina");
#my $outseqs = new Bio::SeqIO(-file=>">$outfqfile", -format=>"fastq-illumina");
my $inseqs = new Bio::SeqIO(-file=>$fastqfile, -format=>"fastq");
my $outseqs = new Bio::SeqIO(-file=>">$outfqfile", -format=>"fastq");
$ocount = 0;
while ($seq = $inseqs->next_seq) 
	{
	$qo = new Bio::Seq::Quality(-accession_number=>$seq->display_id, -qual=>$seq->qual,
				-verbose=>-1);
	$qid = $qo->accession_number;
	if (exists($gh{$qid})) {$outseqs->write_seq($seq); $ocount++;};
	}

print "Done.\n";
print $ocount, " sequences written to output.\n";
system("date");
