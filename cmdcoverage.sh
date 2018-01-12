#!/bin/bash
#CMDcoverage
#Version 0.2.1
#Author: Greg Fedewa
#Copyright: 2017.12.11
#The whole idea here is to take a bam file and be able to output a quick command line graph of coverage
usage="cmdcoverage -- Take a bam file and output a quick command line graph of coverage

Usage: cmdcoverage.sh [-h] [-a] <file.bam|file.sam> [windowsize] 
               OR
       samtools mpileup [options] [region] <file.bam|file.sam> | cmdcoverage.sh [-a] [windowsize] 

Requirements:   spark: for the single line graph (default)
                       see: https://github.com/holman/spark
                gnuplot: for the multiline graph (-a)"

while getopts ":ah" opt; do
    case ${opt} in 
        a)
            asci_graph=true 
            ;;
        h) 
            echo "$usage"
            exit 1
            ;;
        \?)
            echo "Error: wrong flag."
            echo "$usage"
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

BAM_FILE=$1
window=$2
# Figure out if this was given a file name or should cat stdin
if [ $# -ge 1 -a -f "$1" ]; then
# if there is great than or equal to 1 argument ($# -ge 1) and it is a file (-a -f "$1")
    pileup_out=$(samtools mpileup -a -d 100000 $BAM_FILE)
elif [ -t 0 ]; then
    if [ $# -le 1 ]; then
        echo "Error: missing arguments"
        echo "$usage"
        exit 1
    fi
elif ! [ -t 0 ]; then
# else read stdin
    window=$1
    pileup_out=$(cat)
fi

#Figure out coverage window size if not given
if [[ -z "${window// }" ]]; then
    term_width=$(tput cols)
    pileup_len=$(echo "$pileup_out" | grep -c '^') 
    if (( $pileup_len % $term_width  == 0 )); then
        window=$(echo $(( $pileup_len / $term_width )))
    else
        window=$(( $pileup_len / $term_width ))
        remainder=$(( $pileup_len % $term_width ))
        while [ $window -le $remainder ]; do
            term_width=$((term_width-1))
            window=$(( $pileup_len / $term_width ))
            remainder=$(( $pileup_len % $term_width ))
        done
    fi
fi
echo "Window size = $window bases"

#Do the actual work of this script. awk generates the mean of the windows and then spark or gnuplot plots them
coverage=$(echo "$pileup_out" | awk ' BEGIN{window='"$window"'} {sum += $4};  NR%window==0 {sum/=window; print sum; sum=0}')
if ! [[ $asci_graph == true ]]; then
    echo $coverage | spark 
else
    echo "$coverage" | gnuplot -p -e "set terminal dumb ansirgb size $term_width, 24; set xrange [0:$term_width]; plot '-' title 'Coverage' with fillsteps"
fi