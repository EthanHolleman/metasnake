library(ggplot2)
library(ggpubr)
library(tidyr)
library(ggforce)
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

make_metaplot_grid <- function(df, output.path){

    n_samples <- unique(df$sample)
    colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(n_samples))

    grid <- ggplot(df, aes(x=as.numeric(bin), y=mean)) + theme_pubr() +
    labs(x='bins') + 
    geom_ribbon(aes(ymax=mean+se, ymin=mean-se, x=as.numeric(bin), fill=sample), alpha=0.4) +
    geom_line(aes(color=sample)) + facet_grid(vars(sample), vars(region)) + 
    scale_color_manual(values=colors) + 
    theme(legend.position = "none") + theme(legend.position = "none")

    #ggsave(as.character(output.path), grid, width=14, height=10, unit='in')
    grid
}


make_mataplot_by_sample <- function(df, output.path){

    n_samples <- unique(df$sample)
    colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(n_samples))
    by_sample <- ggplot(df, aes(x=as.numeric(bin), y=mean)) + theme_pubr() +
    labs(x='bins') + 
    geom_ribbon(aes(ymax=mean+se, ymin=mean-se, x=as.numeric(bin), fill=sample), alpha=0.4) +
    geom_line(aes(color=sample)) + facet_wrap(~region) + 
    scale_color_manual(values=colors)
    #ggsave(as.character(output.path), by_sample, width=14, height=10, unit='in')
    by_sample

}

make_mataplot_by_region <- function(df){

    n_region <- unique(df$region)
    colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(n_region))
    by_region <- ggplot(df, aes(x=as.numeric(bin), y=mean)) + theme_pubr() +
    labs(x='bins') + 
    geom_ribbon(aes(ymax=mean+se, ymin=mean-se, x=as.numeric(bin), fill=region), alpha=0.4) +
    geom_line(aes(color=region)) + facet_wrap(~sample) + 
    scale_color_manual(values=colors)
    #ggsave(as.character(output.path), by_sample, width=14, height=10, unit='in')
    by_region

}



make_boxplots <- function(df, output.path){

    n_samples <- unique(df$region)
    colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(n_samples))
    boxplots <- ggplot(df, aes(x=sample, y=mean, fill=factor(region))) + geom_boxplot() +
    scale_fill_manual(values=colors) + stat_compare_means(method = "anova") +
    theme_pubr() + labs(fill='Region', x='Sample')
    #ggsave(as.character(output.path), by_sample, width=14, height=10, unit='in')
    boxplots

}

make_individual_metaplots <- function(df){
    plots <- list()
    counter <- 1
    regions <- unique(df$region)
    samples <- unique(df$sample)
    colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(length(regions) * length(samples)))
    for (each_region in regions){
        for (each_sample in samples){
            message(paste(each_region, each_sample))
            df.sub <- subset(df, region==each_region & sample==each_sample)
            plt <- ggplot(df.sub, aes(x=as.numeric(bin), y=mean))  +
                   labs(x='bins') + 
                    geom_ribbon(aes(ymax=mean+se, ymin=mean-se, x=as.numeric(bin), fill=region), alpha=0.4) +
                    geom_line(aes(color=region)) + scale_fill_manual(values = c(colors[counter])) +
                    ggtitle(paste(each_region, each_sample)) + theme_pubr()
            plots[[counter]] <- plt
            counter <- counter + 1
        }
    }

    plots
}



main <- function(){
    message('Making plots')
    input.files <- unique(snakemake@input)
    message(input.files)
    dfs <- list()
    for (i in 1:length(input.files)){
        dfs[[i]] <- read_tsv(input.files[[i]])
    }
    big.df <- do.call("rbind", dfs)
    metaplot.grid <- make_metaplot_grid(big.df, snakemake@output)
    metaplot.sample <- make_mataplot_by_sample(big.df, snakemake@output)
    metaplot.region <- make_mataplot_by_region(big.df)
    boxplot <- make_boxplots(big.df, snakemake@output)
    individual.plots <- make_individual_metaplots(big.df)
    all.plots <- list(metaplot.grid, metaplot.sample, metaplot.region, boxplot)
    all.plots <- c(all.plots, individual.plots)
    pdf(as.character(snakemake@output))
    widths <- c(11, 11, 7)
    heights <- c(7, 7, 7)
    for (i in 1:length(all.plots)){
        print(all.plots[[i]], width=widths[i], height=heights[i], dpi=500)
    }
    # plot indivual metaplots using facet_wrap_paginate
    # pages <- n_pages(metaplot.grid)
    # for (i in 1:pages){
    #     print(metaplot.grid + facet_wrap_paginate(1, 1, i))
    # }


    dev.off()
    message('Done!')

    #

    #gsave(as.character(snakemake@output), metaplot, width=14, height=10, unit='in')

}

if (! interactive()){
  main()
}