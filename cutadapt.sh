#!/bin/bash
#
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=32Gb
#SBATCH --time=1:00:00
#SBATCH --mail-type=Fail,END
#SBATCH --job-name=cutadapt
#SBATCH --mail-user=fx363@nyu.edu

module purge
module load cutadapt/3.1

#Remove adaptors from raw sequenses

mkdir cleaned_fastqs

cd /scratch/fx363/Pancan2022-open-ref/raw_fastqs

for s in $(ls *_L001_R1_001*.fastq.gz)
do
	SAMPLE=$(echo $s)
	cutadapt -g CTTGGTCATTTAGAGGAAGTAA \
	-o /scratch/fx363/Pancan2022-open-ref/cleaned_fastqs/"$SAMPLE" \
	-m 100 \
	$s
done
