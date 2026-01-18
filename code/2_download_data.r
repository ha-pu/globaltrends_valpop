# Download data

# packages ---------------------------------------------------------------------
library(globaltrends)
library(tidyverse)

# parameters -------------------------------------------------------------------
readRenviron(".env")

initialize_python(
  api_key = Sys.getenv("GOOGLE_API_KEY"), # Google Trends API key
  conda_env = Sys.getenv("CONDA_ENV") # Location of Conda environment
)

start_db()
batch_object <- read_rds("data/batch_object.rds")

# control keywords -------------------------------------------------------------
download_control(control = 1, locations = gt.env$eu_plus)

# object keywords --------------------------------------------------------------
download_object(object = batch_object, control = 1, locations = gt.env$eu_plus)

# compute score ----------------------------------------------------------------
compute_score(object = batch_object, control = 1, locations = gt.env$eu_plus)

# disconnect -------------------------------------------------------------------
disconnect_db()
