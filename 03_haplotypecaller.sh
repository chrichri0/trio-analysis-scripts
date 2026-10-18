#!/bin/bash -l
#SBATCH -A uppmax2024-2-1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH -t 2-00:00:00
#SBATCH -J variant_calling_child
#SBATCH --mail-type=ALL

# This script performs variant calling for the child using GATK HaplotypeCaller
# in gVCF mode. The same workflow was performed independently for the father
# and mother using their corresponding CRAM files and output filenames.

# ------------------------------------------------------------
# LOAD SOFTWARE
# ------------------------------------------------------------

module purge
module load GATK

# ------------------------------------------------------------
# PATHS AND FILES
# ------------------------------------------------------------

PROJECT_FOLDER="/gorilla/proj/uppmax2024-2-1/uppmax2024-2-1/rare_variants"
WORKSPACE="$PROJECT_FOLDER/cristina"

REF_FA="$PROJECT_FOLDER/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"

INPUT_CRAM="$WORKSPACE/child_aligned_cram3.0.cram"
OUTPUT_GVCF="$WORKSPACE/child_variants.g.vcf"

# ------------------------------------------------------------
# VARIANT CALLING
# ------------------------------------------------------------

gatk HaplotypeCaller \
-R "$REF_FA" \
-I "$INPUT_CRAM" \
-O "$OUTPUT_GVCF" \
-ERC GVCF \
--native-pair-hmm-threads 8
