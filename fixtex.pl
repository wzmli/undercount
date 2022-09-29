use strict;

while(<>){
	print;
}
newtex  <- gsub(pattern = "[\\]author[{]true [\\]and true [\\]and true [\\]and true[}]", replace = "\\\\include{authors}", x = tex)

newtex  <- gsub(pattern = "[\\]author[{]true [\\]and true [\\]and true [\\]and true[}]"
	, replace = " 
\\\\usepackage{authblk}
\\\\author[1,2]{Michael Li}
\\\\author[3]{Jonathan Dushoff}
\\\\author[2]{David J. D. Earn}
\\\\author[2,3]{Benjamin M. Bolker}
\\\\affil[1]{Public Health Risk Science Division, National Microbiology Laboratory, Public Health Agency of Canada}
\\\\affil[2]{Department of Mathematics and Statistics, McMaster University}
\\\\affil[3]{Department of Biology, McMaster University}

"
	, x = tex)


writeLines(newtex, con=newname)



