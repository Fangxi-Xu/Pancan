#!/bin/bash
#
#SBATCH --job-name=pancan
#SBATCH --nodes=1 --ntasks-per-node=8
#SBATCH --time=100:00:00   # HH/MM/SS
#SBATCH --output=pancan.out
#SBATCH --mem=64G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=fx363@nyu.edu

module purge

WORK=$PWD
LOG=$WORK/QIIME_log_$TM.txt

#This IS QIIME2 VERSION 2021.11.0
#Import the UNITE reference sequences into QIIME2
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime tools import \
#  --type FeatureData[Sequence] \
#  --input-path /scratch/fx363/Pancan2022/sh_qiime_release_10.05.2021/dynamic/sh_refs_qiime_ver8_dynamic_10.05.2021.fasta \
#  --output-path UNITE_ref_seqs.qza

#Import the UNITE taxonomy file into QIIME2
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime tools import \
# --type FeatureData[Taxonomy] \
# --input-path /scratch/fx363/Pancan2022/sh_qiime_release_10.05.2021/dynamic/sh_taxonomy_qiime_ver8_dynamic_10.05.2021.txt \
# --output-path UNITE_ref_taxonomy.qza \
# --input-format HeaderlessTSVTaxonomyFormat

