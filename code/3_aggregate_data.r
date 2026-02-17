### prepare internal category data

# packages ---------------------------------------------------------------------
library(globaltrends)
library(lubridate)
library(readxl)
library(tidyverse)

# load data --------------------------------------------------------------------
start_db()
data_score <- export_score(control = 1)
data_related <- gt.env$tbl_related %>%
    select(term, location, start_date, end_date, related_term, hits) %>%
    collect()
data_region <- gt.env$tbl_region %>%
    select(-batch_o) %>%
    collect()
disconnect_db()

data_keywords <- read_xlsx("input/valpop_topics.xlsx", sheet = 2)

# aggregate by term ------------------------------------------------------------
valpop_keyword <- data_score %>%
    inner_join(data_keywords, by = c("keyword" = "code")) %>%
    select(
        control,
        location,
        category,
        group,
        keyword = topic,
        date,
        score
    ) %>%
    unique() %>%
    filter(score != Inf & group != "Drop") %>%
    summarise(
        pgsi = sum(score),
        .by = c(control, location, category, group, keyword, date)
    ) %>%
    mutate(
        month = month(date),
        year = year(date)
    ) %>%
    summarise(
        pgsi = mean(pgsi),
        .by = c(control, location, category, group, keyword, month, year)
    ) %>%
    mutate(
        date = dmy(paste(1, month, year, sep = "-"))
    ) %>%
    select(-month, -year)

# map related terms ------------------------------------------------------------
valpop_related <- data_related %>%
    inner_join(data_keywords, by = c("term" = "code")) %>%
    mutate(year = year(start_date)) %>%
    select(
        category,
        group,
        keyword = topic,
        location,
        year,
        related_term,
        hits
    )

# map regions ------------------------------------------------------------------
valpop_region <- data_region %>%
    inner_join(data_keywords, by = c("term" = "code")) %>%
    mutate(year = year(start_date)) %>%
    select(
        category,
        group,
        keyword = topic,
        location,
        year,
        region_code,
        region_name,
        hits
    )

# save data --------------------------------------------------------------------
valpop_keyword <- bind_rows(
    read_rds("data/valpop_keyword.rds"),
    valpop_keyword
)
valpop_related <- bind_rows(
    read_rds("data/valpop_related.rds"),
    valpop_related
)
valpop_region <- bind_rows(
    read_rds("data/valpop_region.rds"),
    valpop_region
)

saveRDS(valpop_keyword, "data/valpop_keyword.rds")
saveRDS(valpop_related, "data/valpop_related.rds")
saveRDS(valpop_region, "data/valpop_region.rds")
