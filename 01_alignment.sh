#!/bin/bash -l
#SBATCH -A uppmax2024-2-1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH -t 20:00:00
#SBATCH -J alignment_child
#SBATCH --mail-type=ALL

# This script shows the alignment workflow for the child sample.
# The same workflow was applied independently to the father and mother,
# using the corresponding FASTQ files, sample-specific read-group information,
# and output filenames.

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

# Temporary files will be stored in node-local $TMPDIR
INTERMEDIATE_SAM="$TMPDIR/aligned_reads_child.sam"
INTERMEDIATE_BAM="$TMPDIR/aligned_reads_child.bam"

# ------------------------------------------------------------
# STEP 1: Align paired-end reads to the GRCh38 reference
# The  SAM file is written to $TMPDIR
# ------------------------------------------------------------

bwa-mem2 mem -t 16 \
-R '@RG\tID:child\tSM:child\tPL:ILLUMINA' \
"$REF/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
"$PROJECT_FOLDER/case1/child/forward.fq.gz" \
"$PROJECT_FOLDER/case1/child/reverse.fq.gz" \
> "$INTERMEDIATE_SAM"

# ------------------------------------------------------------
# STEP 2: Sort SAM and convert it to BAM
# The BAM also remains in $TMPDIR
# ------------------------------------------------------------

samtools sort -@ 16 \
-o "$INTERMEDIATE_BAM" \
"$INTERMEDIATE_SAM"

# ------------------------------------------------------------
# STEP 3: Convert BAM to CRAM
# The final CRAM is written permanently to our workspace
# ------------------------------------------------------------

samtools view -@ 16 \
-C \
-T "$REF/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
-o "$OUTPUT_CRAM" \
"$INTERMEDIATE_BAM"

# ------------------------------------------------------------
# STEP 4: Index the final CRAM file
# ------------------------------------------------------------

samtools index "$OUTPUT_CRAM"
