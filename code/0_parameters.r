# Install packages

# packages ---------------------------------------------------------------------
# devtools::install_github(repo = "ha-pu/globaltrends", ref = "parquet")
# install.packages("readxl")
# install.packages("tidyverse")

# save new year ----------------------------------------------------------------
year <- readr::read_lines("input/new_year.txt")
year <- as.integer(year) + 1
if (year > 2025) stop()
readr::write_lines(year, "input/new_year.txt")
