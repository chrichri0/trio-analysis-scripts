#!/bin/bash -l
#SBATCH -A uppmax2024-2-1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH -t 20:00:00
#SBATCH -J cram3_child
#SBATCH --mail-type=ALL

# This script converts the child CRAM file from CRAM 3.1 to CRAM 3.0
# because the downstream GATK workflow was not compatible with the CRAM 3.1 files.
# The same conversion was performed independently for the father and mother.

# ------------------------------------------------------------
# LOAD SOFTWARE
# ------------------------------------------------------------

module purge
module load SAMtools/1.22.1-GCC-13.3.0

# ------------------------------------------------------------
# PATHS
# ------------------------------------------------------------

PROJECT_FOLDER="/gorilla/proj/uppmax2024-2-1/uppmax2024-2-1/rare_variants"
WORKSPACE="$PROJECT_FOLDER/cristina"

REF_FA="$PROJECT_FOLDER/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"

INPUT_CRAM="$WORKSPACE/child_aligned.cram"
OUTPUT_CRAM="$WORKSPACE/child_aligned_cram3.0.cram"

# ------------------------------------------------------------
# CONVERT CRAM 3.1 -> CRAM 3.0
# ------------------------------------------------------------

samtools view \
-@ 16 \
-T "$REF_FA" \
-O cram,version=3.0 \
-o "$OUTPUT_CRAM" \
"$INPUT_CRAM"

# ------------------------------------------------------------
# INDEX NEW CRAM
# ------------------------------------------------------------

samtools index "$OUTPUT_CRAM"
