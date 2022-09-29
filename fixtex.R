library(shellpipes)

tex  <- readLines(matchFile(".tex"))

newtex  <- gsub(pattern = "[\\]author[{]true [\\]and true [\\]and true [\\]and true[}]", replace = "\\\\include{authors}", x = tex)

writeLines(newtex, con=newname)

