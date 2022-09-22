library(rmarkdown) 
library(shellpipes)

rmarkdown::render(matchFile(".rmd"), output_format = latex_document())
