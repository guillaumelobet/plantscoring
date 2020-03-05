

library(tidyverse)
library(RSQLite)
library(DT)
library(data.table)
library(formattable)

init_path  <- "~/Desktop/test_clocl"

dbcon <- function(path){
  con <- dbConnect(RSQLite::SQLite(), paste0(path, "/aeroscan/data/database.sql"))
  return(con)
}


