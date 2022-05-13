source(file.path("_utils/pkgs.R"))

############ DOWNLOAD DATA #############################################
# download assets from latest releases of cdc_aggs_20, acs2020
acs_repo <- sprintf("%sacs", yr)
cdc_repo <- sprintf("cdc_aggs%s", yr_str)

tibble::lst(acs_repo, cdc_repo) %>%
  rlang::set_names(stringr::str_remove, "_repo$") %>%
  map(function(rp) gh::gh("/repos/{owner}/{repo}/releases/latest", owner = "ct-data-haven", repo = rp)) %>%
  map(pluck, "assets") %>%
  map_depth(2, ~ .[c("url", "name")]) %>%
  flatten() %>%
  bind_rows() %>%
  filter(grepl("nhood.+\\.rds$", name)) %>%
  mutate(file = file.path("input_data", name)) %>%
  pwalk(function(url, name, file) {
    gh::gh(url, .accept = "application/octet-stream", .destfile = file, .overwrite = TRUE)
  })