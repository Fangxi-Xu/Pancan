#!/bin/bash
#
#SBATCH --job-name=open-ref
#SBATCH --nodes=1 --ntasks-per-node=8
#SBATCH --time=100:00:00   # HH/MM/SS
#SBATCH --output=open-ref.out
#SBATCH --mem=64G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=fx363@nyu.edu

module purge

WORK=$PWD
LOG=$WORK/QIIME_log_$TM.txt


#This IS QIIME2 VERSION 2021.11.0
#import cleaned fastqs
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime tools import \
#  --type 'SampleData[SequencesWithQuality]' \
#  --input-path /scratch/fx363/Pancan2022-open-ref/cleaned_fastqs \
#  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
#  --output-path demux-single-end.qza

#visualize and see initial total reads and reads quality
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime demux summarize \
#  --i-data demux-single-end.qza \
#  --o-visualization demux-single-end.qzv

#filter based on q score
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime quality-filter q-score \
#  --i-demux demux-single-end.qza \
#  --p-min-quality 19 \
#  --o-filtered-sequences sequence_filtered.qza \
#  --o-filter-stats sequence_filtered_stats.qza

#visualize
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime demux summarize \
#  --i-data sequence_filtered.qza \
#  --o-visualization sequence_filtered.qzv

#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime metadata tabulate \
#  --m-input-file sequence_filtered_stats.qza \
#  --o-visualization sequence_filtered_stats.qzv

#vsearch dereplicating sequences
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime vsearch dereplicate-sequences\
#  --i-sequences sequence_filtered.qza \
#  --o-dereplicated-table table.qza \
#  --o-dereplicated-sequences seqs.qza

#Summarise and visualise
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime feature-table summarize \
# --i-table table.qza \
# --o-visualization table.qzv \
# --m-sample-metadata-file metadata_w_ctrls.txt

#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime feature-table tabulate-seqs \
# --i-data seqs.qza \
# --o-visualization seqs.qzv

#open-reference clustering at 97%
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime vsearch cluster-features-open-reference \
#  --i-sequences seqs.qza \
#  --i-table table.qza \
#  --i-reference-sequences UNITE_ref_seqs.qza \
#  --p-perc-identity 0.97 \
#  --o-clustered-table table_clustered_97.qza \
#  --o-clustered-sequences seqs_clustered_97.qza \
#  --o-new-reference-sequences ref-seqs-97.qza

#chimera checking
#convert uchime reference sequences to qiime2 artifact
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime tools import \
#  --input-path uchime_reference_dataset_ITS2_28.06.2017.fasta \
#  --output-path uchime_reference_seqs_ITS2.qza \
#  --type 'FeatureData[Sequence]'

#vsearch chimera filtering
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime vsearch uchime-ref \
#  --i-sequences seqs_clustered_97.qza \
#  --i-table table_clustered_97.qza \
#  --i-reference-sequences uchime_reference_seqs_ITS2.qza \
#  --o-chimeras chimeric_seqs.qza \
#  --o-nonchimeras non_chimeric_seqs.qza \
#  --o-stats chimeric_stats.qza

#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime metadata tabulate \
#  --m-input-file chimeric_stats.qza \
#  --o-visualization chimeric_stats.qzv

#chimera checking for feature table
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime feature-table filter-features \
#  --i-table table_clustered_97.qza \
#  --m-metadata-file non_chimeric_seqs.qza \
#  --o-filtered-table table-nonchimeric.qza

#taxonomy classification of query sequences
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime feature-classifier classify-consensus-blast \
# --i-query non_chimeric_seqs.qza \
# --i-reference-reads UNITE_ref_seqs.qza \
# --i-reference-taxonomy UNITE_ref_taxonomy.qza \
# --o-classification taxonomy.qza

#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime metadata tabulate \
# --m-input-file taxonomy.qza \
# --o-visualization taxonomy.qzv

#taxa barplot
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime taxa barplot \
#  --i-table table-nonchimeric.qza \
#  --i-taxonomy taxonomy.qza \
#  --m-metadata-file metadata_w_ctrls.txt \
#  --o-visualization taxa-bar-plots.qzv

#covert to biom format
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash qiime tools export \
#--input-path table-nonchimeric.qza \
#--output-path biom_table

#cd biom_table
#/scratch/work/public/singularity/run-qiime2-2021.11.0.bash biom convert -i feature-table.biom -o feature-table.tsv --to-tsv


