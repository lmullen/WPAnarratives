library(readr)
library(dplyr)
library(stringr)

files <- list.files("data-raw/wpa-texts/", full.names = TRUE)
file_id <- basename(files)
texts <- lapply(files, read_file)
people <- read_csv("data-raw/people.csv")

texts_df <- data_frame(file = file_id, text = unlist(texts))

wpa_narratives <- left_join(people, texts_df, by = "file") %>%
  mutate(year = as.integer(str_extract(interview_date, "\\d{4}"))) %>%
  select(name_last, name_first, interviewer_name_last, interviewer_name_first,
         interview_year = year, interview_date, interview_address, interview_city = city,
         interview_state = state, age, text, filename = file)

# Note that there are people listed who don't have narratives for some reason
wpa_narratives <- wpa_narratives %>%
  filter(!is.na(text)) %>%
  mutate(text = str_replace_all(text, "\r\n", "\n"))

# Bad filename matches
#anti_join(texts_df, people) %>% View

devtools::use_data(wpa_narratives, compress = "xz", overwrite = TRUE)
