# Kode for å lese timeplan fra timeplan.uit.no, lagrer denne som google sheets og evt excelark

# Mappe til kurset/der du vil lagre fila
getwd()
setwd("H:/undervisning/SOK3020")
dir()

require(pacman) || {install.packages("pacman"); require(pacman)}
p_load(tidyverse)
p_load(rvest)

# rydder
rm(list=ls())
# Kopierer url fra timeplan uit.no
# Velg format: liste

# Endre URL etter behov
url <-"http://timeplan.uit.no/emne_timeplan.php?year=2018&module%5B%5D=SOK-3020-1&week=25-52&View=list"

page <- read_html(url)
table <- html_nodes(page, 'table')
table <- html_table(table, fill=TRUE)

# Lag liste
dlist <- lapply(table, FUN = function(x) {as.tibble(t(apply(x, 1, unlist)))})

#browseURL("https://renkun-ken.github.io/rlist-tutorial/index.html")
p_load(rlist)
p_load(pipeR)

# Liste til data
df <- dlist %>>% list.stack
# def variabelnavn
colnames(df) <- df[1,]
# Sletter
df <- df %>% filter(!Dato=="Dato")

# Dele dato
df <- df %>% separate(Dato, 
           into = c("Dag", "Dato"), 
           sep = "(?<=[A-Za-z])(?=[0-9])")

df$Dato <- as.Date(df$Dato, format="%d.%m.%Y")
df$Uke <- strftime(df$Dato, format = "%V")

# Velger
df <- df %>% select(Dag,Dato,Uke,Tid,Rom)
df

# Lagre

#browseURL("https://cran.r-project.org/web/packages/googlesheets/vignettes/basic-usage.html#make-new-sheets-from-local-delimited-files-or-excel-workbooks")
p_load(googlesheets)

# Endre filnavn
df %>% write.csv("timeplanSOK3020.csv", row.names = FALSE)

# Dine google sheets
#browseURL("https://docs.google.com/spreadsheets/")

# laste opp i google sheets
timeplanSOK3020 <- gs_upload("timeplanSOK3020.csv")

# sjekk
timeplanSOK3020 %>% gs_read()


#################################################
# Til de som vil lagre excelfiler i mappa på disk
# browseURL("https://ropensci.org/technotes/2017/09/08/writexl-release/")
p_load(writexl)
write_xlsx(df, "timeplanSOK3020.xlsx")
#################################################