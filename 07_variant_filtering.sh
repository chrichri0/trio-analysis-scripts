#!/bin/bash -l
#SBATCH -A uppmax2024-2-1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH -t 06:00:00
#SBATCH -J filter_trio
#SBATCH --mail-type=ALL

# ------------------------------------------------------------
# LOAD SOFTWARE
# ------------------------------------------------------------

module purge
module load GATK

# ------------------------------------------------------------
# PATHS
# ------------------------------------------------------------

PROJECT_FOLDER="/gorilla/proj/uppmax2024-2-1/uppmax2024-2-1/rare_variants"
WORKSPACE="$PROJECT_FOLDER/cristina"

REF_FA="$PROJECT_FOLDER/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"

INPUT_VCF="$WORKSPACE/trio_joint.vcf.gz"
FILTERED_VCF="$WORKSPACE/trio_joint.filtered.vcf.gz"

# ------------------------------------------------------------
# STEP 4: VARIANT FILTERING
# ------------------------------------------------------------

echo "$(date) Starting variant filtering..."

gatk --java-options "-Xmx8g" VariantFiltration \
-R "$REF_FA" \
-V "$INPUT_VCF" \
-O "$FILTERED_VCF" \
--filter-name "QD_filter" --filter-expression "QD < 2.0" \
--filter-name "FS_filter" --filter-expression "FS > 60.0" \
--filter-name "MQ_filter" --filter-expression "MQ < 40.0"

# ------------------------------------------------------------
# INDEX THE FILTERED VCF
# ------------------------------------------------------------

echo "$(date) Checking the filtered VCF index..."

if [[ ! -s "${FILTERED_VCF}.tbi" ]]; then
gatk IndexFeatureFile -I "$FILTERED_VCF"
fi

echo "$(date) Variant filtering and indexing completed successfully."
echo "Output: $FILTERED_VCF"
