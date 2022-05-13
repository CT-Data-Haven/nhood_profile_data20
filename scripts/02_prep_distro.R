source(file.path("_utils", "pkgs.R"))

hdrs <- jsonlite::read_json(file.path("to_viz", "indicators.json"), simplifyVector = TRUE) %>%
  purrr::map_dfr(purrr::pluck, "indicators") %>%
  select(indicator, display)

############ FLAT FILES BY CITY ########################################
prof_list <- readRDS(file.path("output_data", stringr::str_glue("all_nhood_{yr}_acs_health_comb.rds"))) %>%
  map(left_join, hdrs, by = "indicator") %>%
  map(distinct, name, display, year, .keep_all = TRUE) %>%
  map(tidyr::pivot_wider, id_cols = any_of(c("level", "town", "name")), names_from = c(display, year)) %>%
  map(mutate, level = fct_relabel(level, stringr::str_remove, "^\\d_"))

iwalk(prof_list, function(df, city) {
  city_nm <- janitor::make_clean_names(city)
  fn <- stringr::str_glue("{city_nm}_nhood_{yr}_acs_health_comb.csv")
  readr::write_csv(df, file.path("to_distro", fn), na = "")
})

############ DATA.WORLD ################################################
# repo <- stringr::str_glue("nhood_profile_data{yr_str}")
# dataset <- stringr::str_glue("ctdatahaven/profiles{yr_str}")


