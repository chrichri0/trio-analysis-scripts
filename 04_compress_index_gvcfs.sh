#!/bin/bash -l
#SBATCH -A uppmax2024-2-1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH -t 08:00:00
#SBATCH -J compress_gvcfs
#SBATCH --mail-type=ALL

# ------------------------------------------------------------
# LOAD SOFTWARE
# ------------------------------------------------------------

module purge
module load HTSlib/1.22.1-GCC-13.3.0

# ------------------------------------------------------------
# WORKSPACE
# ------------------------------------------------------------

WORKSPACE="/gorilla/proj/uppmax2024-2-1/uppmax2024-2-1/rare_variants/cristina"

# ------------------------------------------------------------
# COMPRESS AND INDEX THE THREE GVCFS
# ------------------------------------------------------------

for SAMPLE in child father mother; do

INPUT_GVCF="$WORKSPACE/${SAMPLE}_variants.g.vcf"
OUTPUT_GVCF="$WORKSPACE/${SAMPLE}_variants.g.vcf.gz"

# Compress the original gVCF using bgzip.

bgzip -@ 4 -c "$INPUT_GVCF" > "${OUTPUT_GVCF}.partial"

# Give the compressed file its final name.

mv "${OUTPUT_GVCF}.partial" "$OUTPUT_GVCF"

# Create its Tabix index.

tabix -p vcf "$OUTPUT_GVCF"

echo "$SAMPLE: compression and indexing completed."

done
