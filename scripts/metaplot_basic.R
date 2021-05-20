library(ggplot2)
library(ggpubr)
library(tidyr)
library(RColorBrewer)


get_sample_from_input_file <- function(input.path){
    input.path <- as.character(input.path)
    unlist(strsplit(basename(input.path), '\\.'))[2]

}

get_region_from_input_file <- function(input.path){
    input.path <- as.character(input.path)
    unlist(strsplit(basename(input.path), '\\.'))[1]

}


standard_error <- function(x){
  
  sd(x)/sqrt(length(x))
}


confidence_interval <- function(sd, count){

  qnorm(0.975)*sd/sqrt(count)

}

read_tsv <- function(filepath){

    region <- get_region_from_input_file(filepath)
    sample <- get_sample_from_input_file(filepath)
    df <- as.data.frame(read.table(filepath, header=F))
    colnames(df) <- c('bin', 'mean', 'sd', 'count')
    se <- list()
    for (i in 1:nrow(df)){
        se[[i]] <- confidence_interval(df[i, ]$sd, df[i, ]$count)
    }
    df$mean <- as.numeric(df$mean)
    df$sample <- sample
    df$region <- region
    df$se <- as.numeric(unlist(se))

    df

}

make_metaplot <- function(df){

    n_samples <- unique(df$sample)
    colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(n_samples))

    by_sample <- ggplot(df, aes(x=as.numeric(bin), y=mean)) + theme_pubr() +
    labs(x='bins') + 
    geom_ribbon(aes(ymax=mean+se, ymin=mean-se, x=as.numeric(bin), fill=sample), alpha=0.4) +
    geom_line(aes(color=sample)) + facet_grid(vars(sample), vars(region), scales="free") + 
    scale_color_manual(values=colors) + 
    theme(legend.position = "none") + theme(legend.position = "none")

    by_sample

}

main <- function(){

    input.files <- unique(snakemake@input)
    save.image('basicmeta.RData')
    dfs <- list()
    for (i in 1:length(input.files)){
        dfs[[i]] <- read_tsv(input.files[[i]])
    }
    big.df <- do.call("rbind", dfs)
    metaplot <- make_metaplot(big.df)
    ggsave(as.character(snakemake@output), metaplot, width=14, height=10, unit='in')

}

if (! interactive()){
  main()
}