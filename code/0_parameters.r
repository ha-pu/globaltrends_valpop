# Install packages

# packages ---------------------------------------------------------------------
# devtools::install_github(repo = "ha-pu/globaltrends", ref = "parquet")
# install.packages("readxl")
# install.packages("tidyverse")

# save new year ----------------------------------------------------------------
year <- 2025
readr::write_lines(year, "input/new_year.txt")
