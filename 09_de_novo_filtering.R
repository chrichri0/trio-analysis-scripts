module purge
module load R-bundle-CRAN/2026.07-foss-2026.1
R

library(dplyr)
library(tidyr)

# ------------------------------------------------------------
# READ PASS VARIANT TABLES
# ------------------------------------------------------------

child <- read.table(
  "child_variants.split.pass.tsv",
  header = FALSE,
  sep = "\t",
  stringsAsFactors = FALSE
)

# Remove FILTER column because all retained records are PASS
child <- child[, -5]

# Rename columns
colnames(child) <- c(
  "CHROM", "POS", "REF", "ALT",
  "child_GT", "child_GQ", "child_DP", "child_AD"
)

# The same steps were performed for the father and mother.


# ------------------------------------------------------------
# CREATE VARIANT KEY
# ------------------------------------------------------------

# CHROM, POS, REF and ALT were used because multiallelic splitting can
# produce separate records at the same genomic position.

child <- child %>%
  mutate(KEY = paste(CHROM, POS, REF, ALT, sep = ":"))

father <- father %>%
  mutate(KEY = paste(CHROM, POS, REF, ALT, sep = ":"))

mother <- mother %>%
  mutate(KEY = paste(CHROM, POS, REF, ALT, sep = ":"))


# ------------------------------------------------------------
# JOIN CHILD, FATHER AND MOTHER
# ------------------------------------------------------------

trio <- child %>%
  inner_join(
    father %>% select(KEY, father_GT, father_GQ, father_DP, father_AD),
    by = "KEY"
  ) %>%
  inner_join(
    mother %>% select(KEY, mother_GT, mother_GQ, mother_DP, mother_AD),
    by = "KEY"
  )


# ------------------------------------------------------------
# SPLIT ALLELE DEPTH INTO REF AND ALT COUNTS
# ------------------------------------------------------------

trio <- trio %>%
  separate(
    child_AD,
    into = c("child_AD_ref", "child_AD_alt"),
    sep = ",",
    convert = TRUE,
    fill = "right"
  )

trio <- trio %>%
  separate(
    father_AD,
    into = c("father_AD_ref", "father_AD_alt"),
    sep = ",",
    convert = TRUE,
    fill = "right"
  )

trio <- trio %>%
  separate(
    mother_AD,
    into = c("mother_AD_ref", "mother_AD_alt"),
    sep = ",",
    convert = TRUE,
    fill = "right"
  )


# ------------------------------------------------------------
# DE NOVO GENOTYPE PATTERN
# ------------------------------------------------------------

de_novo <- trio %>%
  filter(
    child_GT %in% c("0/1", "1/0", "0|1", "1|0"),
    father_GT %in% c("0/0", "0|0"),
    mother_GT %in% c("0/0", "0|0")
  )


# ------------------------------------------------------------
# GENOTYPE QUALITY FILTER
# ------------------------------------------------------------

de_novo_gq <- de_novo %>%
  filter(
    child_GQ >= 20,
    father_GQ >= 20,
    mother_GQ >= 20
  )


# ------------------------------------------------------------
# READ DEPTH FILTER
# ------------------------------------------------------------

de_novo_gq_dp <- de_novo_gq %>%
  filter(
    child_DP >= 15,
    father_DP >= 15,
    mother_DP >= 15
  )


# ------------------------------------------------------------
# PARENTAL ALT-READ FILTER
# ------------------------------------------------------------

de_novo_parentAD <- de_novo_gq_dp %>%
  filter(
    father_AD_alt == 0,
    mother_AD_alt == 0
  )


# ------------------------------------------------------------
# CHILD ALLELE BALANCE
# ------------------------------------------------------------

de_novo_ab <- de_novo_parentAD %>%
  mutate(
    child_AB = child_AD_alt / (child_AD_ref + child_AD_alt)
  )

de_novo_ab_filtered <- de_novo_ab %>%
  filter(
    child_AB >= 0.3,
    child_AB <= 0.7
  )


# ------------------------------------------------------------
# SHORT-VARIANT FILTER
# ------------------------------------------------------------

de_novo_filtered <- de_novo_ab_filtered %>%
  filter(
    nchar(REF) <= 10,
    nchar(ALT) <= 10
  )
