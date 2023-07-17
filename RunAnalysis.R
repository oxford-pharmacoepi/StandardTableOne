# create logger
log_file <- paste0(output_folder, "/log.txt")
logger <- create.logger()
logfile(logger) <- log_file
level(logger) <- "INFO"

# instantiate necessary cohorts
info(logger, "INSTANTIATE TARGET COHORTS")
cohortSet <- readCohortSet(
  path = here("Cohorts", "CohortToCharacterise")
)
cdm <- generateCohortSet(
  cdm = cdm, cohortSet = cohortSet, name = "target",
  overwrite = TRUE
)

# subset the cdm to only individuals in target cohort
info(logger, "SUBSETTING CDM")
cdm <- cdmSubsetCohort(cdm, "target")

# instantiate medications
info(logger, "INSTANTIATE MEDICATIONS")
codelistMedications <- codesFromConceptSet(here("Cohorts", "Medications"), cdm)
cdm <- generateConceptCohortSet(cdm, "medications", codelistMedications)

# instantiate conditions
info(logger, "INSTANTIATE CONDITIONS")
codelistConditions <- codesFromConceptSet(here("Cohorts", "Conditions"), cdm)
cdm <- generateConceptCohortSet(cdm, "conditions", codelistConditions)

# create table summary
result <- summariseCharacteristics(
  cohort = cdm$cohort1,
  ageGroup = list(c(0, 19), c(20, 39), c(40, 59), c(60, 79), c(80, 150)),
  tableIntersect = list(
    "Visits" = list(
      tableName = "visit_occurrence", value = "count", window = c(-365, 0)
     )
  ),
  cohortIntersect = list(
    "Medications" = list(
      targetCohortTable = "medications", value = "flag", window = c(-365, 0)
    ),
    "Conditions" = list(
      targetCohortTable = "conditions", value = "flag", window = c(-Inf, 0)
    )
  )
)

# export results
write_csv(result, here(output_folder, "table_one.csv"))

# create zip file
info(logger, "ZIPPING RESULTS")
output_folder <- basename(output_folder)
zip(
  zipfile = file.path(paste0(output_folder, "/Results_", db_name, ".zip")),
  files = list.files(output_folder, full.names = TRUE)
)