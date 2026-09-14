#!/bin/bash -l
#SBATCH -A uppmax2024-2-1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH -t 20:00:00
#SBATCH -J alignment_child
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

OUTPUT_CRAM="$WORKSPACE/child_aligned.cram"

# Temporary files are stored in node-local $TMPDIR,
# NOT in permanent project storage.
INTERMEDIATE_SAM="$TMPDIR/aligned_reads_child.sam"
INTERMEDIATE_BAM="$TMPDIR/aligned_reads_child.bam"

# ------------------------------------------------------------
# OPTIONAL SAFETY CHECKS
# These verify that the required directories/files exist before
# spending hours running the alignment.
# ------------------------------------------------------------

if [[ ! -d "$WORKSPACE" ]]; then
echo "ERROR: Workspace does not exist: $WORKSPACE"
exit 1
fi

if [[ ! -r "$REF/Homo_sapiens.GRCh38.dna.primary_assembly.fa" ]]; then
echo "ERROR: Reference genome cannot be found or read."
exit 1
fi

if [[ ! -r "$PROJECT_FOLDER/case1/child/forward.fq.gz" ]]; then
echo "ERROR: Child forward FASTQ cannot be found or read."
exit 1
fi

if [[ ! -r "$PROJECT_FOLDER/case1/child/reverse.fq.gz" ]]; then
echo "ERROR: Child reverse FASTQ cannot be found or read."
exit 1
fi

# ------------------------------------------------------------
# OPTIONAL BUT USEFUL LOGGING
# This information will appear in the Slurm output file.
# ------------------------------------------------------------

echo "========================================"
echo "Starting alignment: child"
echo "Node:        $(hostname)"
echo "TMPDIR:      $TMPDIR"
echo "Output CRAM: $OUTPUT_CRAM"
echo "Start time:  $(date)"
echo "========================================"

# ------------------------------------------------------------
# STEP 1A: Align paired-end reads to the GRCh38 reference.
# The large SAM file is written to $TMPDIR.
# ------------------------------------------------------------

bwa-mem2 mem -t 16 \
-R '@RG\tID:child\tSM:child\tPL:ILLUMINA' \
"$REF/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
"$PROJECT_FOLDER/case1/child/forward.fq.gz" \
"$PROJECT_FOLDER/case1/child/reverse.fq.gz" \
> "$INTERMEDIATE_SAM"

# ------------------------------------------------------------
# STEP 1B: Sort SAM and convert it to BAM.
# The BAM also remains in $TMPDIR.
# ------------------------------------------------------------

samtools sort -@ 16 \
-o "$INTERMEDIATE_BAM" \
"$INTERMEDIATE_SAM"

# ------------------------------------------------------------
# STEP 1C: Convert BAM to CRAM.
# The final CRAM is written permanently to your workspace.
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
# $TMPDIR would also be cleaned after the job finishes.
# ------------------------------------------------------------

rm "$INTERMEDIATE_SAM" "$INTERMEDIATE_BAM"

# ------------------------------------------------------------
# OPTIONAL BUT USEFUL LOGGING
# Because set -e is enabled, this point should only be reached
# if all preceding commands completed successfully.
# ------------------------------------------------------------

echo "========================================"
echo "Alignment completed successfully: child"
echo "CRAM:        $OUTPUT_CRAM"
echo "CRAM index:  ${OUTPUT_CRAM}.crai"
echo "Finish time: $(date)"
echo "========================================"
