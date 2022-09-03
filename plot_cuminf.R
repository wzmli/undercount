library(ggplot2);theme_set(theme_bw(base_size=14))
library(shellpipes)

loadEnvironments()

gg <- (ggplot(dat,aes(Date,y=value,color=type))
	+ geom_line()
	+ ylab("Cumulative Count")
	+ theme(legend.position = "bottom")
)

print(gg)


