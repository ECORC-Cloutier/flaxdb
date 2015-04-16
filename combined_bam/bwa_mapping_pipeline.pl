#!/usr/bin/perl -w
# Make sure that the above path is correct

################################################################################
# Copyright (c) 2011, Depatrtment of Plant Sciences, University of California,
# and Genomics and Gene Discorvery Unit, USDA-ARS-WRRC.
#
# Author: Dr. Frank M. You
#
# Function: This script is to split the fasta file to small pieases and perform
#           blast using multiple processors/threads
# Modified: 08-19-2011 bowtie is used for mapping reads
################################################################################

use strict;
use Getopt::Std;
use vars qw ($opt_r $opt_f $opt_t $opt_p $opt_m $opt_s);
getopts ('r:f:t:p:m:s:');

my $ref_seq_file    = $opt_r;
my $read_fastq_dir = $opt_f;
my $read_type       = $opt_t;
my $threads         = $opt_p;
my $max_seqs        = $opt_m;
my $single_reads    = $opt_s;

if (!$ref_seq_file || !$read_fastq_dir || !$read_type || !$single_reads){
    print "Usage: \n";
    print "perl $0 \n";
    print "     -r reference sequence file (in FASTA format) \n";
    print "     -f read dir (with fastq/bam files)\n";
    print "     -t read type (454/solid/solexa)\n";
    print "     -p number of processors (threads)\n";
    print "     -s single reads or paired reads (s/p)\n";
 #   print "     -m maximum sequences after the reference sequences are split into multiple files\n";

    exit;
}

my $samtools = 'samtools';
my $samtools_pl = 'samtools.pl';
my $bwa = 'bwa';
my $bowtie = 'bowtie';
my $bowtie_index = 'bowtie-build';

my $max_insert_size = 525;  # need to input for paired end


my $mapped_file = "mapped_seq_files.txt";
my $mapped_file_hash = read_mapped_files($mapped_file);

# Step 2: 

my $ref_seq_root = $ref_seq_file;
if ($ref_seq_file =~ /(.+)\.\S+$/) {
	$ref_seq_root = $1;
}

my $ref_seq_name = $ref_seq_root;

# Step 1: create index file for reference sequences

my $cmd = '';
if ($read_type eq 'solid') {
	$cmd = "$bwa index -c -a is $ref_seq_file";
} else {
	$cmd = "$bwa index -a is $ref_seq_file";
}

if (not -e $ref_seq_file . ".sa") {
	print "\nCreate index for reference sequence file ...\n";
	print "system \"$cmd\"\n";
	system $cmd;
}


opendir (DIR, "$read_fastq_dir") or die ("Can not open the directory $read_fastq_dir : $!");

while(my $read_fastq_file = readdir(DIR)) {
    next if $read_fastq_file =~ /^\.$/;
    next if $read_fastq_file =~ /^\.\.$/;
    next if -d $read_fastq_file;
    next if $read_fastq_file !~ /\.gz$/ && $read_fastq_file !~ /\.fastq$/ && $read_fastq_file !~ /\.txt$/ && $read_fastq_file !~ /\.bam$/;

	next if (exists($mapped_file_hash->{$read_fastq_file}));   # skip files which have been mapped

    print "$read_fastq_file\n";

    my $file = "$read_fastq_dir/$read_fastq_file";
	
    my $forward_file;
    my $reverse_file;
	my $bam_seq_file;
	
    my $fastq_file_root;	
    if ($file =~ /(.*)_1\.txt$/) {
        $forward_file = $file;
        $reverse_file = $1 . "_2.txt";
		$fastq_file_root = $1;
    }
    elsif ($file =~ /(.*)_1\.fastq$/) {
        $forward_file = $file;
        $reverse_file = $1 . "_2.fastq";
		$fastq_file_root = $1;
    }
    elsif ($file =~ /(.*)_1\.gz$/) {
        $forward_file = $file;
        $reverse_file = $1 . "_2.gz";
		$fastq_file_root = $1;
    }
    
	    
    elsif ($file =~ /(.*)_2\.txt$/) {
		next;
    }
    elsif ($file =~ /(.*)_2\.fastq$/) {
		next;
    }
    elsif ($file =~ /(.*)_2\.gz$/) {
		next;
    }
    elsif ($file =~ /(.*)\.bam$/) {
        $bam_seq_file = $file;
		$fastq_file_root = $1;
    }

	next if (-e "$bam_seq_file" . "_aln_sa.sam_converted_sorted_variant.pileup.SNPs.txt");

	my $fastq_file_root_write = $fastq_file_root;
    my @tmps = split(/\//, $fastq_file_root);
    $fastq_file_root = $tmps[@tmps-1];
    
	# Step 2: alignment
	print "\nAlign reads to reference to create SA coordinate file ...\n";
	my $out_sai_file = $fastq_file_root_write ."_aln_sa.sai";
	my $out_sai_file1 = $fastq_file_root_write ."_aln_sa_1.sai";
	my $out_sai_file2 = $fastq_file_root_write ."_aln_sa_2.sai";
	my $out_sam_file = $fastq_file_root_write ."_aln_sa.sam";
	if ($read_type eq 'solid') {
		$cmd = "$bwa aln -c -t$threads $-q 20 ref_seq_file $file > $out_sai_file";
		print "system \"$cmd\"\n";
		system $cmd;
	} elsif ($read_type eq 'solexa') {
		if ($single_reads eq 's') {
			if ($file =~ /\.fastq$/ || $file =~ /\.txt$/) {
				$cmd = "$bwa aln -t$threads -q 20 $ref_seq_file $file > $out_sai_file";
			} elsif ($file =~ /\.bam$/) {
				$cmd = "$bwa aln -t$threads -q 20 $ref_seq_file $file > $out_sai_file";
			}
			print "system \"$cmd\"\n";
			system $cmd;
		} elsif ($single_reads eq 'p') {
			if ($file =~ /\.bam$/) {
				$cmd = "$bwa aln -t$threads -q 20 $ref_seq_file -b1 $file > $out_sai_file1";
				print "system \"$cmd\"\n";
				system $cmd;
				$cmd = "$bwa aln -t$threads -q 20 $ref_seq_file -b2 $file > $out_sai_file2";
				print "system \"$cmd\"\n";
				system $cmd;
				$cmd = "$bwa sampe -P -a $max_insert_size $ref_seq_file $out_sai_file1 $out_sai_file2 $file $file > $out_sam_file";
				print "system \"$cmd\"\n";
				system $cmd;
			}
            else {
				$cmd = "$bwa aln -t$threads -q 20 $ref_seq_file $forward_file > $out_sai_file1";
				print "system \"$cmd\"\n";
				system $cmd;
				$cmd = "$bwa aln -t$threads -q 20 $ref_seq_file $reverse_file > $out_sai_file2";
				print "system \"$cmd\"\n";
				system $cmd;
				$cmd = "$bwa sampe -P -a $max_insert_size $ref_seq_file $out_sai_file1 $out_sai_file2 $forward_file $reverse_file > $out_sam_file";
				print "system \"$cmd\"\n";
				system $cmd;
            }
		
		}
		
	} elsif ($read_type eq '454') {
		$cmd = "$bwa bwasw -t$threads $ref_seq_file $file > $out_sam_file";
		print "system \"$cmd\"\n";
		system $cmd;
	}

	# Step 3: create sam file: this step only for SOLiD and Solexa data
	if ($read_type ne '454' && $single_reads ne 'p') {
		print "\nCreate SM file from SA coordinate file ...\n";
		$cmd = "$bwa samse $ref_seq_file $out_sai_file $file> $out_sam_file";
		print "system \"$cmd\"\n";
		system $cmd;
	}

	
    # Step 4: convert sam file to bam format which can be used in the Tablet program
    print "\nConvert sam file to bam ...\n";
    my $bam_file = $out_sam_file . "_converted.bam";
    $cmd = "$samtools view -bST $ref_seq_file $out_sam_file > $bam_file"; 
    print "system \"$cmd\"\n";
    system $cmd;

   # Step 5: sort reference sequences
    print "\nSort reference sequence ...\n";
    my $sorted_bam_file = $out_sam_file . "_converted_sorted";   
    $cmd = "$samtools sort $bam_file $sorted_bam_file";
    print "system \"$cmd\"\n";
    system $cmd;
    
	# Step 6: generate index file *.bai
	print "\ngenerate *.bai index file for Tablet ...\n";
    $cmd = "$samtools index $sorted_bam_file" . ".bam";
	print "system \"$cmd\"\n";
    system $cmd;

    unlink $out_sam_file;
    unlink $bam_file;
	unlink $out_sai_file if $out_sai_file;
	unlink $out_sai_file1 if $out_sai_file1;
	unlink $out_sai_file2 if $out_sai_file2;
	
}


# Example
#samtools view -b -S myalignment.sam -t myref.fa > myalignment.bam
#samtools sort myalignment.bam myalignment.sorted
#samtools index myalignment.sorted.bam

######################### end of the main program ##############################

#########################       Subroutines       ##############################

sub split_seqs {
    my ($seq_file, $max_seqs) = @_;
    open (SEQ, "<$seq_file") or die ("Can not open the file $seq_file: $!\n");
	
    my $seq = '';
    my $pre_name = '';
    my $name = '';
    my $count = 0;
    my $file_count = 1;
    open (OUT, ">$seq_file" . "_$file_count" . ".fas") or die ("Can not open the file : $!\n");
    while (my $line = <SEQ>) {
	chomp($line);
	$line = &trim($line);
	next if ($line =~ /^\s*$/);
	
	if ($line =~ /^>(\S+)/) {
	    $name = $1;
	    $count++;
	    if ($count > $max_seqs) {
		close OUT;
		$file_count++;
		$count = 1;
		open (OUT, ">$seq_file" . "_$file_count" . ".fas") or die ("Can not open the file : $!\n");
	    }
 	    if ($seq ne '' && $name ne $pre_name && $pre_name ne '') {
		print OUT ">$pre_name\n";
                print OUT &format_seq($seq, 70);
		$seq = '';
	    }
   	    $pre_name = $name;
	} else {
	    $seq .= &trim($line);
	}
    }
    if ($seq ne '') {
	print OUT ">$pre_name\n";
        print OUT &format_seq($seq, 70);
	$seq = '';
    }
    close SEQ;
    close OUT;
    return $file_count;
}


sub format_seq {
    my ($seq, $line_width) = @_;
    my $len = length($seq);
    my $rows = int($len/$line_width);
    $rows++ if ($len % $line_width != 0);
    
    my $seqs = "";
    for (my $i = 0; $i < $rows; $i++) {
        my $offset = $i * $line_width;
        my $width = $line_width;
        $width = ($len - $offset) if ($i == $rows-1); 
        $seqs .= uc(substr($seq, $offset, $line_width)) . "\n";
    }
    
    return $seqs;
}

# Trim function to remove leading and trailing whitespaces
sub trim {
    my $string = shift;
    if ($string =~ /^\s+/) {
	$string =~ s/^\s+//;
    }
    if ($string =~ /\s+$/) {
	$string =~ s/\s+$//;
    }
    return $string;
}

sub read_mapped_files {
	my $mapped_file = shift;
	my %mapped_file_hash = ();
	if (-e $mapped_file) {
		open (IN, "<$mapped_file") or die ("Can not open the file $mapped_file: $!\n");
	
		while (my $line = <IN>) {
			chomp($line);
			$line = &trim($line);
			next if ($line =~ /^\s*$/);
		
			$mapped_file_hash{$line} = '';
		}
		
		close IN;
	} else {
		print "$mapped_file is not found!! It will be fine if no mapping was performed for the specified data before.\n"
	}
	return \%mapped_file_hash;
}
