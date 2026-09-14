#!/bin/bash -l
#SBATCH -A uppmax2024-2-1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH -t 20:00:00
#SBATCH -J alignment_father
#SBATCH --mail-type=ALL

# ------------------------------------------------------------
# EXTRA SAFETY SETTING
# Stop the script if an important command fails or an undefined
# variable is accidentally used.
# ------------------------------------------------------------

set -euo pipefail

# ------------------------------------------------------------
# LOAD SOFTWARE
# ------------------------------------------------------------

module load bwa-mem2/2.3-GCC-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0

# ------------------------------------------------------------
# PATHS AND FILES
# ------------------------------------------------------------

PROJECT_FOLDER="/gorilla/proj/uppmax2024-2-1/uppmax2024-2-1/rare_variants"
REF="$PROJECT_FOLDER/reference"
WORKSPACE="$PROJECT_FOLDER/cristina"

OUTPUT_CRAM="$WORKSPACE/father_aligned.cram"

# Temporary files are stored in node-local $TMPDIR,
# NOT in permanent project storage.
INTERMEDIATE_SAM="$TMPDIR/aligned_reads_father.sam"
INTERMEDIATE_BAM="$TMPDIR/aligned_reads_father.bam"

# ------------------------------------------------------------
# OPTIONAL SAFETY CHECKS
# ------------------------------------------------------------

if [[ ! -d "$WORKSPACE" ]]; then
echo "ERROR: Workspace does not exist: $WORKSPACE"
exit 1
fi

if [[ ! -r "$REF/Homo_sapiens.GRCh38.dna.primary_assembly.fa" ]]; then
echo "ERROR: Reference genome cannot be found or read."
exit 1
fi

if [[ ! -r "$PROJECT_FOLDER/case1/father/forward.fq.gz" ]]; then
echo "ERROR: Father forward FASTQ cannot be found or read."
exit 1
fi

if [[ ! -r "$PROJECT_FOLDER/case1/father/reverse.fq.gz" ]]; then
echo "ERROR: Father reverse FASTQ cannot be found or read."
exit 1
fi

# ------------------------------------------------------------
# OPTIONAL BUT USEFUL LOGGING
# ------------------------------------------------------------

echo "========================================"
echo "Starting alignment: father"
echo "Node:        $(hostname)"
echo "TMPDIR:      $TMPDIR"
echo "Output CRAM: $OUTPUT_CRAM"
echo "Start time:  $(date)"
echo "========================================"

# ------------------------------------------------------------
# STEP 1A: Align paired-end reads to the GRCh38 reference.
# ------------------------------------------------------------

bwa-mem2 mem -t 16 \
-R '@RG\tID:father\tSM:father\tPL:ILLUMINA' \
"$REF/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
"$PROJECT_FOLDER/case1/father/forward.fq.gz" \
"$PROJECT_FOLDER/case1/father/reverse.fq.gz" \
> "$INTERMEDIATE_SAM"

# ------------------------------------------------------------
# STEP 1B: Sort SAM and convert it to BAM.
# ------------------------------------------------------------

samtools sort -@ 16 \
-o "$INTERMEDIATE_BAM" \
"$INTERMEDIATE_SAM"

# ------------------------------------------------------------
# STEP 1C: Convert BAM to CRAM.
# ------------------------------------------------------------

samtools view -@ 16 \
-C \
-T "$REF/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
-o "$OUTPUT_CRAM" \
"$INTERMEDIATE_BAM"

# ------------------------------------------------------------
# STEP 1D: Index the final CRAM file.
# ------------------------------------------------------------

samtools index "$OUTPUT_CRAM"

# ------------------------------------------------------------
# Remove temporary intermediate SAM and BAM files.
# ------------------------------------------------------------

rm "$INTERMEDIATE_SAM" "$INTERMEDIATE_BAM"

# ------------------------------------------------------------
# OPTIONAL BUT USEFUL LOGGING
# ------------------------------------------------------------

echo "========================================"
echo "Alignment completed successfully: father"
echo "CRAM:        $OUTPUT_CRAM"
echo "CRAM index:  ${OUTPUT_CRAM}.crai"
echo "Finish time: $(date)"
echo "========================================"
