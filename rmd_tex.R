library(rmarkdown) 
library(shellpipes)

rmarkdown::render(matchFile(".rmd"), output_format = latex_document())


## Hacking authors

fn <- "undercount_short.tex"
newname <- "undercount_short_jmv.tex"

tex  <- readLines(fn)

newtex  <- gsub(pattern = "[\\]author[{]true [\\]and true [\\]and true [\\]and true[}]", replace = "\\\\include{authors}", x = tex)
writeLines(newtex, con=newname)



