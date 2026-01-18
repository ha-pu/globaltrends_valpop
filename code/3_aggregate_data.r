### prepare internal category data

# packages ---------------------------------------------------------------------
library(globaltrends)
library(readxl)
library(tidyverse)

# load data --------------------------------------------------------------------
start_db()
score_base <- export_score(control = 1)
disconnect_db()

data_keywords <- read_xlsx("input/valpop_topics.xlsx", sheet = 2)

# aggregate by term ------------------------------------------------------------
valpop_keyword <- score_base %>%
    inner_join(data_keywords, by = c("keyword" = "code")) %>%
    select(
        control,
        location,
        category,
        group,
        keyword,
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

# save data --------------------------------------------------------------------
data_keyword <- bind_rows(
    read_rds("data/valpop_keyword.rds"),
    valpop_keyword
)
saveRDS(data_keyword, "data/valpop_keyword.rds")
