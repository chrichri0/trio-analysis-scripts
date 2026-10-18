# R environment used on UPPMAX/Pelle:
# R-bundle-CRAN/2026.07-foss-2026.1

library(dplyr)
library(tidyr)


# ------------------------------------------------------------
# LOAD CANDIDATE AND ANNOTATION TABLES
# ------------------------------------------------------------

# Original filtered candidates including genotype and
# sequencing-quality information

variants <- read.delim(
  "de_novo_candidates_filtered.tsv",
  stringsAsFactors = FALSE
)


# snpEff functional annotations

snpeff <- read.delim(
  "de_novo_snpEff_ANN.tsv",
  header = FALSE,
  sep = "\t",
  quote = "",
  comment.char = "",
  stringsAsFactors = FALSE
)

colnames(snpeff) <- c(
  "CHROM", "POS", "REF", "ALT", "ANN"
)


# ClinVar clinical annotations

clinvar <- read.delim(
  "de_novo_ClinVar.tsv",
  header = FALSE,
  sep = "\t",
  quote = "",
  comment.char = "",
  stringsAsFactors = FALSE
)

colnames(clinvar) <- c(
  "CHROM", "POS", "REF", "ALT",
  "CLNSIG", "CLNREVSTAT", "CLNDN",
  "CLNDISDB", "ORIGIN", "RS"
)


# ------------------------------------------------------------
# PREPARE TABLES FOR JOINING
# ------------------------------------------------------------

variants <- variants %>%
  mutate(
    CHROM = as.character(CHROM),
    POS = as.integer(POS)
  )

snpeff <- snpeff %>%
  mutate(
    CHROM = as.character(CHROM),
    POS = as.integer(POS)
  )

clinvar <- clinvar %>%
  mutate(
    CHROM = as.character(CHROM),
    POS = as.integer(POS)
  )


# Check for duplicate variant identities

anyDuplicated(
  variants[c("CHROM", "POS", "REF", "ALT")]
)

anyDuplicated(
  snpeff[c("CHROM", "POS", "REF", "ALT")]
)

anyDuplicated(
  clinvar[c("CHROM", "POS", "REF", "ALT")]
)


# ------------------------------------------------------------
# COMBINE CANDIDATE AND ANNOTATION TABLES
# ------------------------------------------------------------

priority <- variants %>%
  left_join(
    snpeff,
    by = c("CHROM", "POS", "REF", "ALT")
  ) %>%
  left_join(
    clinvar,
    by = c("CHROM", "POS", "REF", "ALT")
  )


# ------------------------------------------------------------
# PARSE SNPEFF ANN FIELD
# ------------------------------------------------------------

priority_ann <- priority %>%
  mutate(ANN = na_if(ANN, ".")) %>%
  separate_rows(ANN, sep = ",") %>%
  separate(
    ANN,
    into = c(
      "ANN_allele",
      "Consequence",
      "Impact",
      "Gene",
      "Gene_ID",
      "Feature_type",
      "Transcript_ID",
      "Transcript_biotype",
      "Rank",
      "HGVS_c",
      "HGVS_p",
      "cDNA_position",
      "CDS_position",
      "AA_position",
      "Distance",
      "ANN_notes"
    ),
    sep = "\\|",
    fill = "right",
    extra = "merge"
  )


# ------------------------------------------------------------
# COUNT UNIQUE HIGH/MODERATE VARIANTS
# ------------------------------------------------------------

n_distinct(
  priority_ann$KEY[
    priority_ann$Impact %in% c("HIGH", "MODERATE")
  ]
)


# ------------------------------------------------------------
# SELECT HIGH AND MODERATE ANNOTATIONS
# ------------------------------------------------------------

priority_high_mod_ann <- priority_ann %>%
  filter(
    Impact %in% c("HIGH", "MODERATE")
  )


# Inspect HIGH/MODERATE candidates

priority_high_mod_ann %>%
  select(
    CHROM,
    POS,
    REF,
    ALT,
    Gene,
    Consequence,
    Impact,
    child_AB,
    CLNSIG,
    CLNREVSTAT
  ) %>%
  print(n = 11)


# ------------------------------------------------------------
# INSPECT CLINVAR-CLASSIFIED VARIANTS
# ------------------------------------------------------------

priority_ann %>%
  filter(
    !is.na(CLNSIG),
    CLNSIG != "."
  ) %>%
  distinct(
    KEY,
    Gene,
    Impact,
    CLNSIG,
    CLNREVSTAT
  )
