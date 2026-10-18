# ------------------------------------------------------------
# LOAD SOFTWARE
# ------------------------------------------------------------

module load snpEff/5.4a-GCCcore-13.3.0-Java-21
module load BCFtools/1.22.1-GCC-13.3.0

# ------------------------------------------------------------
# SNPEFF FUNCTIONAL ANNOTATION
# ------------------------------------------------------------

java -Xmx24g -jar "$EBROOTSNPEFF/snpEff.jar" \
  -dataDir "/gorilla/proj/uppmax2024-2-1/uppmax2024-2-1/rare_variants/snpeff_data/data" \
  -v GRCh38.mane.1.2.ensembl de_novo_candidates.vcf.gz \
  | bcftools view -Oz -o de_novo_snpEff.vcf.gz

bcftools index -t de_novo_snpEff.vcf.gz


# Extract snpEff ANN annotations for downstream analysis in R

bcftools query \
  -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/ANN\n' \
  de_novo_snpEff.vcf.gz \
  > de_novo_snpEff_ANN.tsv


# ------------------------------------------------------------
# CLINVAR CLINICAL ANNOTATION
# ------------------------------------------------------------

bcftools annotate \
  -a /gorilla/proj/uppmax2024-2-1/uppmax2024-2-1/rare_variants/ClinVar/clinvar_20250831.vcf.gz \
  -c INFO/CLNSIG,INFO/CLNREVSTAT,INFO/CLNDN,INFO/CLNDISDB,INFO/ORIGIN,INFO/RS \
  de_novo_candidates.vcf.gz \
  -Oz -o de_novo_ClinVar.vcf.gz

bcftools index -t de_novo_ClinVar.vcf.gz


# Extract ClinVar annotations for downstream analysis in R

bcftools query \
  -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/CLNSIG\t%INFO/CLNREVSTAT\t%INFO/CLNDN\t%INFO/CLNDISDB\t%INFO/ORIGIN\t%INFO/RS\n' \
  de_novo_ClinVar.vcf.gz \
  > de_novo_ClinVar.tsv
