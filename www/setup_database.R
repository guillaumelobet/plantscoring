# Copyright © 2019, Université catholique de Louvain
# All rights reserved.
# 
# Copyright © 2019 Forschungszentrum Jülich GmbH
# All rights reserved.
# 
# Developers: Guillaume Lobet
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


rm(list = ls())

# REQURIED LIBRARIES 
library(RSQLite)
library(DBI)
library(tidyverse)


#--------------------------------------------------
# SETUP DATABASE
path <- "~/Desktop/test_cloclo/"
con <- dbConnect(RSQLite::SQLite(), paste0(path, "/aeroscan/data/database.sql"))

#--------------------------------------------------
# RESULTS TABLE

seminals <- data.frame(Datetime = character(0), 
                      Folder = character(0), 
                      QR = character(0),
                      seminal_number = numeric(0))
dbWriteTable(con, "seminals", seminals, overwrite = TRUE)






