# ------------------------------------------------------------
# LOAD SOFTWARE
# ------------------------------------------------------------

module purge
module load BCFtools/1.22.1-GCC-13.3.0


# ------------------------------------------------------------
# PREPARE FINAL CANDIDATE LIST FOR VCF RECONSTRUCTION
# ------------------------------------------------------------

cut -f1-4 de_novo_candidates_filtered.tsv > de_novo_for_annotation.tsv


# ------------------------------------------------------------
# CREATE BED FILE WITH CANDIDATE POSITIONS
# ------------------------------------------------------------

awk '{print $1"\t"$2-1"\t"$2}' de_novo_for_annotation.tsv > positions.bed

# Remove header and repeated BED intervals when multiple candidate
# alleles occur at the same genomic position

tail -n +2 positions.bed | awk '!seen[$0]++' > positions_noheader.bed


# ------------------------------------------------------------
# RECONSTRUCT THE CANDIDATE VCF
# ------------------------------------------------------------

# Copy the VCF header

bcftools view -h trio_joint.filtered.split.vcf.gz > de_novo_candidates.vcf

# Retrieve records at candidate positions and retain only exact
# CHROM, POS, REF and ALT matches

bcftools view -H --regions-overlap pos -R positions_noheader.bed trio_joint.filtered.split.vcf.gz | \
awk 'BEGIN {FS=OFS="\t"}
     NR==FNR {if (FNR>1) wanted[$1 FS $2 FS $3 FS $4]=1; next}
     (($1 FS $2 FS $4 FS $5) in wanted) {print}' \
de_novo_for_annotation.tsv - >> de_novo_candidates.vcf


# ------------------------------------------------------------
# COMPRESS AND INDEX THE CANDIDATE VCF
# ------------------------------------------------------------

bcftools view -Oz -o de_novo_candidates.vcf.gz de_novo_candidates.vcf

bcftools index -t de_novo_candidates.vcf.gz
