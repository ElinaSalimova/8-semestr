library('shiny')       # загрузка пакетов
library('lattice')
library('data.table')

file.URL <- 'https://raw.githubusercontent.com/ElinaSalimova/8-semestr/laba3/laba3.csv'
download.file(file.URL, destfile = 'laba3.csv')

df <- data.table(read.csv('laba3.csv', 
                          stringsAsFactors = F))

