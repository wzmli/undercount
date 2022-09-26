library(rmarkdown) 
library(shellpipes)

rmarkdown::render(matchFile(".rmd"), output_format = "word_document")
