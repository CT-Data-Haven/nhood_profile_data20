library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
library(purrr, warn.conflicts = FALSE, quietly = TRUE)
library(forcats, warn.conflicts = FALSE, quietly = TRUE)

# move this to makefile
yr <- 2020
yr_str <- substr(as.character(yr), 3, 4)

# 2 neighborhood names are duplicated across cities--all have downtown, bpt & stam have South End
dupe_nhoods <- c("Downtown", "South End")

# just using this for dev
make_hdr <- function(x, width = 80) {
  left <- strrep("#", 12)
  center <- toupper(x)
  r_len <- width - nchar(center) - 2
  right <- strrep("#", r_len)
  cat(paste(left, center, right))
}