library(CDMConnector) # At least 1.0.0
library(log4r)
library(DBI)
library(dplyr)
library(dbplyr)
library(here)
library(CodelistGenerator) # At least 1.6.0
library(DrugUtilisation) # At least 0.3.0
library(PatientProfiles) # At least 0.3.0
library(readr)

# database metadata and connection details -----
# The name/ acronym for the database
db_name <- "pharmetrics_100k"

# Set output folder location -----
# the path to a folder where the results from this analysis will be saved
output_folder <- here(paste0("Results_", db_name))
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
}

# Database connection details -----
# In this study we also use the DBI package to connect to the database
# set up the dbConnect details below
# https://darwin-eu.github.io/CDMConnector/articles/DBI_connection_examples.html 
# for more details.
# you may need to install another package for this 
# eg for postgres 
# db <- dbConnect(
#   RPostgres::Postgres(), 
#   dbname = server_dbi, 
#   port = port, 
#   host = host, 
#   user = user,
#   password = password
# )
server_dbi<-"cdm_iqvia_pharmetrics_plus_202203"
port<-Sys.getenv("DB_PORT")
host<-Sys.getenv("DB_HOST")
user<-Sys.getenv("DB_USER")
password<-Sys.getenv("DB_PASSWORD")

db <- dbConnect(RPostgres::Postgres(),
                dbname = server_dbi,
                port = port,
                host = host,
                user = user,
                password = password)

# The name of the schema that contains the OMOP CDM with patient-level data
cdm_database_schema <- "public_100k"

# The name of the schema where results tables will be created 
results_database_schema <- "results"

# Name of stem outcome table in the result schema where the outcome cohorts will
# be stored. 
# Notes: 
# - if there is an existing table in your results schema with the same names it
#   will be overwritten
# - more than one cohort will be created
# - name must be lower case
#stem_table <- "mc_"

# minimum counts that can be displayed according to data governance
minimum_counts <- 5

# create cdm reference ----
cdm <- CDMConnector::cdm_from_con(
  con = db,
  cdm_schema = cdm_database_schema,
  write_schema = c(schema = results_database_schema),
  cdm_name = db_name
)
# check database connection
# running the next line should give you a count of your person table
cdm$person %>% 
  tally()

# Run the study ------
source(here("RunAnalysis.R"))
