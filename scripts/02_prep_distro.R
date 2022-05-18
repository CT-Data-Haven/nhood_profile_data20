source(file.path("_utils", "pkgs.R"))

dwapi::configure(Sys.getenv("DW_AUTH_TOKEN"))

hdrs <- jsonlite::read_json(file.path("to_viz", "indicators.json"), simplifyVector = TRUE) %>%
  purrr::map_dfr(purrr::pluck, "indicators") %>%
  select(indicator, display)

############ FLAT FILES BY CITY ########################################
prof_list <- readRDS(file.path("output_data", stringr::str_glue("all_nhood_{yr}_acs_health_comb.rds"))) %>%
  map(left_join, hdrs, by = "indicator") %>%
  map(distinct, name, display, year, .keep_all = TRUE) %>%
  map(tidyr::pivot_wider, id_cols = any_of(c("level", "town", "name")), names_from = c(display, year)) %>%
  map(mutate, level = fct_relabel(level, stringr::str_remove, "^\\d_"))

dist_files <- imap(prof_list, function(df, city) {
  city_nm <- janitor::make_clean_names(city)
  fn <- stringr::str_glue("{city_nm}_nhood_{yr}_acs_health_comb.csv")
  readr::write_csv(df, file.path("to_distro", fn), na = "")
  as.character(fn)
})

############ DATA.WORLD ################################################
# kinda circular that this depends on its own repo :-/
repo <- stringr::str_glue("nhood_profile_data{yr_str}")
ds_own <- "ctdatahaven"
dataset <- paste0("profiles", yr_str)

nhood_req <- tibble::enframe(dist_files, name = "city", value = "fn") %>%
  tidyr::unnest(fn) %>%
  mutate(
    desc = paste("ACS basic indicators, CDC life expectancy estimates, PLACES Project averages,", city),
    url = file.path("https://github.com/CT-Data-Haven", repo, "blob", "main", "to_distro", fn)
  ) %>%
  pmap(function(city, fn, desc, url) {
    dwapi::file_create_or_update_request(file_name = fn, url = url, description = desc, labels = list("clean data"))
  })

walk(nhood_req, ~ dwapi::update_dataset(owner_id = ds_own, dataset_id = dataset, dwapi::dataset_update_request(files = list(.))))

dwapi::update_dataset(owner_id = ds_own, dataset_id = dataset, dwapi::dataset_update_request(license = "CC-BY-SA"))
dwapi::sync(owner_id = ds_own, dataset_id = dataset)