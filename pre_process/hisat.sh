#!/bin/bash -l
##SBATCH -A snic2017-7-343
#SBATCH -A snic2021-22-481
#SBATCH -p core -n 20
#SBATCH -t 4-00:00:00
##SBATCH  --qos=short
##SBATCH -t 2:00
#SBATCH -J mappingpotato
#SBATCH -o /proj/snic2021-23-431/nobackup/slurm/process_%j.out
#SBATCH -e /proj/snic2021-23-431/nobackup/slurm/process_%j.err
#SBATCH --mail-user=ashfaq.ali@immun.lth.se
#SBATCH --mail-type=END,FAIL

## The alignmet took less that two hours for each sample, the time can be reduced

module load bioinfo-tools
module load HISAT2 samtools
module load subread


#mkdir /proj/snic2021-23-431/private/hisat

hisat2-build -p 20 /proj/snic2021-23-431/private/Human/Homo_sapiens.GRCh38.dna.primary_assembly.fa /proj/snic2021-23-431/private/hisat/

#ls -1 --color=never ../Trimmed_FQ/*gz |cut -f 3 -d '/' |cut -f 1-2 -d '_'|uniq|while read line; do

cd /proj/snic2021-23-431/private/data/raw_Data2/fastq/
ls -1 --color=never *fastq | cut -d '_' -f1 | uniq | while read line; do
hisat2 -p 20 -x /proj/snic2021-23-431/private/hisat -1 $line'_1.fastq' -2 $line'_2.fastq' --sensitive -S '/proj/snic2021-23-431/nobackup/hisat_results/'$line'_grch38.v37.sam' --summary-file '/proj/snic2021-23-431/nobackup/hisat_results/'$line'_grch38.v37.summary'
samtools sort -@ 16 -o '/proj/snic2021-23-431/nobackup/hisat_results/'$line'_grch38.v37.sorted.bam' '/proj/snic2021-23-431/nobackup/hisat_results/'$line'_grch38.v37.sam'
samtools index -@ 16 '/proj/snic2021-23-431/nobackup/hisat_results/'$line'_grch38.v37.sorted.bam'
samtools flagstat -@ 16 '/proj/snic2021-23-431/nobackup/hisat_results/'$line'_grch38.v37.sorted.bam' > '/proj/snic2021-23-431/nobackup/hisat_results/'$line'_grch38.v37.sorted.flagstat'
done

featureCounts -p -T 20 -s 0 -t exon -g gene_id --tmpDir $SNIC_TMP \
-a /proj/snic2021-23-431/private/Human/Homo_sapiens.GRCh38.99.gtf \
-o /proj/snic2021-23-431/private/results/allSamples.hisat.featureCounts \
/proj/snic2021-23-431/nobackup/hisat_results/*.sorted.bam \
> /proj/snic2021-23-431/private/results/allSamples.featureCounts.log


