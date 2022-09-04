library(ggplot2);theme_set(theme_bw(base_size=14))
library(directlabels)
library(shellpipes)

## rpcall("plot_cuminf.Rout plot_cuminf.R est_cuminf.rda")
loadEnvironments()

dat$type2 <- factor(dat$type,
                   levels = c("cumreport", "truecuminc",
                              "estcuminc"),
                   labels = c("reported\ncases",
                              "true\ncases",
                              "estimated\ncases")
                   )

gg <- (ggplot(dat,aes(Date,y=value,color=type2))
    + geom_line()
    + ylab("Cumulative Count")
    + theme_bw()
    + theme(legend.position = "none")
    + geom_dl(method = list(dl.trans(x = x + 0.1),
                            "last.bumpup"),
              aes(label = type2))
    + expand_limits(x = as.Date("2023-03-01"))
    + scale_colour_brewer(palette = "Dark2")
)

print(gg)


