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

my $genotype_id_file    = $opt_i;
my $fq_file_dir         = $opt_d;

if (!$genotype_id_file || !$fq_file_dir){
    print "Usage: \n";
    print "perl $0 \n";
    print "     -i genotype vs bam name file (two columns: genotype name and bam file name without extension) \n";
    print "     -d fastq file dir name \n";

    exit;
}

# Step 1: read genotype names
my $genotypes_hash = &read_genotypes($genotype_id_file);


# Step 2: convert bam to fastq and rename reads with genotype name
opendir (DIR, "$fq_file_dir") or die ("Can not open the directory $fq_file_dir : $!");

my $count = 0;
while(my $fq_file = readdir(DIR)) {
    next if $fq_file =~ /^\.$/;
    next if $fq_file =~ /^\.\.$/; 
    next if -d $fq_file;
    next if $fq_file !~ /\.fastq$/;

	$count++;
	my ($file_id) = $fq_file =~ /(\S+)_\d\.fastq$/;
	my $input_file = "$fq_file_dir/$fq_file";
	
	# rename reads
	my $genotype_name = '';
	if (exists($genotypes_hash->{$file_id})) {
		$genotype_name = $genotypes_hash->{$file_id};

		&rename_fastq($input_file, $genotype_name);
		
		# delete original fastq files
		unlink $input_file;
	} else {
		print "The genotype name for $file_id is not found!! \n";
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
