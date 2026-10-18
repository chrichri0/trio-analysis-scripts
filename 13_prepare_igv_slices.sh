module purge
module load SAMtools/1.22.1-GCC-13.3.0

PROJECT_FOLDER=/gorilla/proj/uppmax2024-2-1/uppmax2024-2-1/rare_variants
REF_FA="$PROJECT_FOLDER/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa"

# PTPN11 variant: chr12:112450416 (GRCh38)
# Approximately +/- 100 bp around the candidate variant

REGION="12:112450316-112450516"

# ------------------------------------------------------------
# CHILD
# ------------------------------------------------------------

samtools view -b -T "$REF_FA" \
  child_aligned_cram3.0.cram \
  "$REGION" \
  > child_PTPN11_slice.bam

samtools index child_PTPN11_slice.bam

# ------------------------------------------------------------
# FATHER
# ------------------------------------------------------------

samtools view -b -T "$REF_FA" \
  father_aligned_cram3.0.cram \
  "$REGION" \
  > father_PTPN11_slice.bam

samtools index father_PTPN11_slice.bam

# ------------------------------------------------------------
# MOTHER
# ------------------------------------------------------------

samtools view -b -T "$REF_FA" \
  mother_aligned_cram3.0.cram \
  "$REGION" \
  > mother_PTPN11_slice.bam

samtools index mother_PTPN11_slice.bam
