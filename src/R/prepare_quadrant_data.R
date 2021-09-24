# produces data by geographical quadrant

library(lubridate)
library(stringr)
library(dplyr)
library(tidyr)

a10 <- readRDS("data/processed/bci_reproductives.rds")

# divide data into four quadrants
a10 <- a10 %>%
  mutate(WE=ifelse(gx > 500, "W", "E")) %>%
  mutate(NS=ifelse(gy > 250, "N", "S")) %>%
  mutate(quarter=paste(NS, WE,sep=""))

# lack geo data for certain trees, which are then excluded
nogeo <- a10 %>%
  filter(is.na(WE))

a11 <- a10 %>%
  drop_na() %>%
  arrange(quarter, species, tree_id, censusyear)

a11 <- a11 %>%
  select(tree_id, species_id, species, quarter, censusyear, present) %>%
  arrange(quarter, species, tree_id)

saveRDS(a11, "data/processed/bci_reproductives_quartered.rds")
