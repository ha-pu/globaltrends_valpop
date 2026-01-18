# packages ---------------------------------------------------------------------
library(countrycode)
library(nanoparquet)
library(readxl)
library(tidyverse)
library(writexl)

# load data --------------------------------------------------------------------
data_terms <- read_xlsx("input/valpop_topics.xlsx", sheet = 2)
data_score <- read_rds("data/valpop_keyword.rds")

# merge data -------------------------------------------------------------------
data_score <- data_terms %>%
    inner_join(data_score, by = c("code" = "keyword", "category", "group")) %>%
    mutate(iso3 = countrycode(location, "iso2c", "iso3c")) %>%
    select(
        iso3,
        iso2 = location,
        category_1 = category,
        category_2 = group,
        topic,
        date,
        pgsi
    ) %>%
    arrange(iso2, category_1, category_2, topic, date)

data_score_agg <- data_score %>%
    summarise(
        pgsi = mean(pgsi),
        .by = c(iso2, category_1, category_2, date)
    )

# save data --------------------------------------------------------------------
write_parquet(data_score, "data/valpop_pgsi.parquet")
write_xlsx(data_score_agg, "data/valpop_pgsi_agg.xlsx")
write_parquet(data_score_agg, "data/valpop_pgsi_agg.parquet")
