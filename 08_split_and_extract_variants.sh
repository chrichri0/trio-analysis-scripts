# ------------------------------------------------------------
# SPLIT MULTIALLELIC SITES INTO BIALLELIC RECORDS
# ------------------------------------------------------------

bcftools norm -m -any -Oz -o trio_joint.filtered.split.vcf.gz trio_joint.filtered.vcf.gz

bcftools index -t trio_joint.filtered.split.vcf.gz


# ------------------------------------------------------------
# EXTRACT CHILD GENOTYPE INFORMATION
# ------------------------------------------------------------

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%FILTER\t[%GT\t%GQ\t%DP\t%AD]\n' --samples child trio_joint.filtered.split.vcf.gz > child_variants.split.tsv

awk '$5=="PASS"' child_variants.split.tsv > child_variants.split.pass.tsv


# The same bcftools query and PASS-filtering steps were performed
# separately for the father and mother using the corresponding sample names.
