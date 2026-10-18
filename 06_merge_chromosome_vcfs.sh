#!/bin/bash -l
#SBATCH -A uppmax2024-2-1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH -t 04:00:00
#SBATCH -J merge_chr_vcfs
#SBATCH --mail-type=ALL

# ------------------------------------------------------------
# LOAD SOFTWARE
# ------------------------------------------------------------

module purge
module load GATK

# ------------------------------------------------------------
# PATHS
# ------------------------------------------------------------

WORKSPACE="/gorilla/proj/uppmax2024-2-1/uppmax2024-2-1/rare_variants/cristina"
OUTPUT_VCF="$WORKSPACE/trio_joint.vcf.gz"

# ------------------------------------------------------------
# COLLECT THE 23 CHROMOSOME VCFS IN ORDER
# ------------------------------------------------------------

CHRS=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X)

INPUTS=()

for CHR in "${CHRS[@]}"; do

VCF="$WORKSPACE/trio_joint_chr${CHR}.vcf.gz"

if [[ ! -s "$VCF" ]]; then
echo "ERROR: Missing or empty chromosome VCF: $VCF"
exit 1
fi

INPUTS+=(-I "$VCF")

done

# ------------------------------------------------------------
# MERGE THE CHROMOSOME VCFS
# ------------------------------------------------------------

echo "$(date) Merging chromosome VCFs..."

gatk --java-options "-Xmx8g" MergeVcfs \
"${INPUTS[@]}" \
-O "$OUTPUT_VCF"

# ------------------------------------------------------------
# INDEX THE MERGED VCF
# ------------------------------------------------------------

echo "$(date) Checking the merged VCF index..."

if [[ ! -s "${OUTPUT_VCF}.tbi" && ! -s "${OUTPUT_VCF}.idx" ]]; then
gatk IndexFeatureFile -I "$OUTPUT_VCF"
fi

echo "$(date) Merging and indexing completed successfully."
