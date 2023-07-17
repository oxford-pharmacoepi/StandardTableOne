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
codelistMedications <- codesFromConceptSet(here("Cohorts", "Medications"), cdm)
cdm <- generateConceptCohortSet(cdm, "medications", codelistMedications)

# create table summary


# export results


# create zip file
info(logger, "ZIPPING RESULTS")
output_folder <- basename(output_folder)
zip(
  zipfile = file.path(paste0(output_folder, "/Results_", db_name, ".zip")),
  files = list.files(output_folder, full.names = TRUE)
)