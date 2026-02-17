# packages ---------------------------------------------------------------------
library(countrycode)
library(lubridate)
library(nanoparquet)
library(tidyverse)
library(writexl)

# load data --------------------------------------------------------------------
data_score <- read_rds("data/valpop_keyword.rds")
data_related <- read_rds("data/valpop_related.rds")
data_region <- read_rds("data/valpop_region.rds")

region_code <- read_csv("data/region_code.csv")

year_start <- 2010
year_end <- 2025

# merge data -------------------------------------------------------------------
data_score <- data_score %>%
    mutate(iso3 = countrycode(location, "iso2c", "iso3c")) %>%
    select(
        iso3,
        iso2 = location,
        category_1 = category,
        category_2 = group,
        topic = keyword,
        date,
        pgsi
    ) %>%
    arrange(iso2, category_1, category_2, topic, date) %>%
    mutate(year = year(date), .before = date) %>%
    filter(year >= year_start & year <= year_end) %>%
    unique() %>%
    summarise(
        pgsi = mean(pgsi),
        .by = c(iso3, iso2, category_1, category_2, topic, year, date)
    )

data_score_agg <- summarise(
    data_score,
    pgsi = mean(pgsi),
    .by = c(iso3, iso2, category_1, category_2, year, date)
)

data_related <- data_related %>%
    mutate(iso3 = countrycode(location, "iso2c", "iso3c")) %>%
    select(
        iso3,
        iso2 = location,
        category_1 = category,
        category_2 = group,
        topic = keyword,
        related_topic = related_term,
        year,
        related_pgsi = hits
    ) %>%
    arrange(iso2, category_1, category_2, topic, year) %>%
    filter(year >= year_start & year <= year_end) %>%
    unique() %>%
    mutate(related_topic = na_if(related_topic, "")) %>%
    filter(!is.na(related_topic))

data_region <- data_region %>%
    mutate(iso3 = countrycode(location, "iso2c", "iso3c")) %>%
    select(
        iso3,
        iso2 = location,
        category_1 = category,
        category_2 = group,
        topic = keyword,
        year,
        region_code,
        region_name,
        region_pgsi = hits
    ) %>%
    arrange(iso2, category_1, category_2, topic, year) %>%
    filter(year >= year_start & year <= year_end) %>%
    unique() %>%
    summarise(
        region_pgsi = mean(region_pgsi),
        .by = c(
            iso3,
            iso2,
            category_1,
            category_2,
            topic,
            year,
            region_code,
            region_name
        )
    ) %>%
    mutate(region_code = na_if(region_code, "")) %>%
    left_join(region_code, by = c("iso2", "region_name")) %>%
    mutate(region_code = coalesce(region_code, region_code_imp)) %>%
    select(-region_code_imp)

# data checks -----------------------------------------------------------------
data_score %>%
    count(iso2, category_1, category_2, topic, year, date) %>%
    filter(n > 1)

data_score %>%
    count(iso2, category_1, category_2, topic, year) %>%
    filter(n > 12)

data_score_agg %>%
    count(iso2, category_1, category_2, year, date) %>%
    filter(n > 1)

data_related %>%
    count(iso2, category_1, category_2, topic, related_topic, year) %>%
    filter(n > 1)

data_region %>%
    count(iso2, category_1, category_2, topic, year, region_name) %>%
    filter(n > 1)

data_region %>%
    filter(is.na(region_code)) %>%
    count(iso2, region_name)

data_region %>%
    filter(is.na(region_name)) %>%
    count(iso2, region_code)

# save data --------------------------------------------------------------------
write_parquet(data_score, "data/valpop_pgsi.parquet")
write_xlsx(data_score_agg, "data/valpop_pgsi_agg.xlsx")
write_parquet(data_score_agg, "data/valpop_pgsi_agg.parquet")
write_parquet(data_related, "data/valpop_pgsi_related.parquet")
write_parquet(data_region, "data/valpop_pgsi_region.parquet")
