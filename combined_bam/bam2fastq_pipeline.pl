#!/usr/bin/perl -w
# Make sure that the above path is correct

################################################################################
# Copyright (c) 2012, AAFC
#
# Author: Dr. Frank M. You
#
# Function: This script is to batch convert bam data files from Illumina to
#           fastq files and then rename reads by adding genotype name before
#           read ids.
################################################################################

use strict;
use Getopt::Std;
use vars qw ($opt_i $opt_d);
getopts ('i:d:');

my $bam_file_dir        = $opt_d;

if (!$bam_file_dir){
    print "Usage: \n";
    print "perl $0 \n";
    print "     -d bam file dir name \n";

    exit;
}


# Step 2: convert bam to fastq and rename reads with genotype name
#my $sam2fastq_jar = '/opt/Bio/picard-tools-1.74/picard-tools-1.74/SamToFastq.jar';
my $sam2fastq_cmd = "picard-tools SamToFastq VALIDATION_STRINGENCY=LENIENT RE_REVERSE=true INCLUDE_NON_PF_READS=false READ1_TRIM=0 READ2_TRIM=0 INCLUDE_NON_PRIMARY_ALIGNMENTS=false VERBOSITY=INFO QUIET=false COMPRESSION_LEVEL=5 MAX_RECORDS_IN_RAM=500000 CREATE_INDEX=false CREATE_MD5_FILE=false"; 
opendir (DIR, "$bam_file_dir") or die ("Can not open the directory $bam_file_dir : $!");

my $count = 0;
while(my $bam_file = readdir(DIR)) {
    next if $bam_file =~ /^\.$/;
    next if $bam_file =~ /^\.\.$/; 
    next if -d $bam_file;
    next if $bam_file !~ /\.bam$/;

	$count++;
	my ($file_id) = $bam_file =~ /(\S+)\.bam$/;
	my $input_file = "$bam_file_dir/$bam_file";
	my $fastq_file = "$bam_file_dir/$file_id" . "_1.fastq";
	my $second_fastq_file = "$bam_file_dir/$file_id" . "_2.fastq";
	
	my $cmd = "$sam2fastq_cmd INPUT=$input_file FASTQ=$fastq_file SECOND_END_FASTQ=$second_fastq_file";
	
	if (-e $fastq_file && -e $second_fastq_file) {
		# do not redo it
		print "$count:\t$cmd\n";
	} else {
		print "$count:\t$cmd\n";
		system $cmd;
	}

}

closedir DIR;


######################### end of the main program ##############################

#########################       Subroutines       ##############################

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

sub read_genotypes {
	my $genotype_file = shift;
	my %genotypes_hash = ();
	if (-e $genotype_file) {
		open (IN, "<$genotype_file") or die ("Can not open the file $genotype_file: $!\n");
	
		while (my $line = <IN>) {
			chomp($line);
			$line = &trim($line);
			next if ($line =~ /^\s*$/);
			
			my @cols = split(/\t/, $line);
		
			$genotypes_hash{$cols[1]} = $cols[0];  # sequence file name without extension vs genotype name
		}
		
		close IN;
	} else {
		print "$genotype_file is not found!! \n";
		exit(1);
	}
	return \%genotypes_hash;
}

sub rename_fastq {
	my ($read_fastq_file, $genotype_name) = @_;
	print "Rename reads by adding $genotype_name in $read_fastq_file ...\n";
	
	open (IN, "<$read_fastq_file") or die ("Can not open the file $read_fastq_file: $!\n");
	
	my ($file_id, $ext) = $read_fastq_file =~ /(\S+)(_\d\.fastq)$/;
	my $renamed_file = "$file_id" . "_" . $genotype_name . $ext;
	
	open (OUT, ">$renamed_file") or die ("Can not open the file $renamed_file: $!\n");
	
	while (my $line = <IN>) {
		chomp($line);
		$line = &trim($line);
		next if ($line =~ /^\s*$/);
			
		if ($line =~ /^@(\S+)$/) {
			my @cols = split(/\:/, $line);
			if (scalar(@cols) == 5) {
				print OUT "@" . $genotype_name . "_" . "$1\n";				
			} else {
				print OUT "$line\n";
			}
		} else {
			print OUT "$line\n";
		}
	}
		
	close IN;
	close OUT;

}
