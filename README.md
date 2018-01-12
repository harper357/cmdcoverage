# CMDcoverage
Version 0.2.1
Author: Greg Fedewa
Copyright: 2017.12.11
The whole idea here is to take a BAM file and be able to output a quick command line graph of coverage
usage="cmdcoverage -- Take a bam file and output a quick command line graph of coverage

Usage: cmdcoverage.sh [-h] [-a] <file.bam|file.sam> [windowsize] 
               OR
       samtools mpileup [options] [region] <file.bam|file.sam> | cmdcoverage.sh [-a] [windowsize] 

Requirements:   spark: for the single line graph (default)
                       see: https://github.com/holman/spark
                gnuplot: for the multiline graph (-a)"

