#!/bin/bash

for dir in /*x*
do
	cd $dir
	cat *_1.fastq > ${dir}_1.fastq &
	cat *_2.fastq > ${dir}_2.fastq &
	cd ..
done
wait
