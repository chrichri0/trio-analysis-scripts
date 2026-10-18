#!/bin/bash -l
#SBATCH -A uppmax2024-2-1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH -t 2-00:00:00
#SBATCH --array=1-23%3
#SBATCH -J joint_genotyping
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

CHILD_GVCF="$WORKSPACE/child_variants.g.vcf.gz"
FATHER_GVCF="$WORKSPACE/father_variants.g.vcf.gz"
MOTHER_GVCF="$WORKSPACE/mother_variants.g.vcf.gz"

# ------------------------------------------------------------
# SELECT CHROMOSOME FOR THIS ARRAY TASK
# ------------------------------------------------------------

CHRS=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X)

CHR="${CHRS[$((SLURM_ARRAY_TASK_ID - 1))]}"

DB_WORKSPACE="$WORKSPACE/trio_db_$CHR"
OUT_VCF="$WORKSPACE/trio_joint_chr${CHR}.vcf.gz"

# ------------------------------------------------------------
# IMPORT GVCFS INTO GENOMICSDB
# ------------------------------------------------------------

echo "$(date) Chromosome $CHR: Importing to GenomicsDB workspace ${DB_WORKSPACE}..."

gatk --java-options "-Xmx32g" GenomicsDBImport \
--genomicsdb-workspace-path "$DB_WORKSPACE" \
-V "$CHILD_GVCF" \
-V "$FATHER_GVCF" \
-V "$MOTHER_GVCF" \
--intervals "$CHR" \
--reader-threads 16 \
--tmp-dir "$TMPDIR"

# ------------------------------------------------------------
# JOINT GENOTYPING
# ------------------------------------------------------------

echo "$(date) Chromosome $CHR: Genotyping..."

gatk --java-options "-Xmx32g" GenotypeGVCFs \
-R "$REF_FA" \
-V "gendb://${DB_WORKSPACE}" \
-O "$OUT_VCF"

echo "$(date) Chromosome $CHR done."
