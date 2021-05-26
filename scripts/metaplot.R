library(ggplot2)
library(ggpubr)
library(tidyr)
library(RColorBrewer)
library(umap)


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


confidence_interval <- function(x){

  n <- length(x)
  s <- sd(x)
  qnorm(0.975)*s/sqrt(n)

}

range01 <- function(x){(x-min(x))/(max(x)-min(x))}

read_meta <- function(file.path){
  file.path <- as.character(file.path)

  as.data.frame(read.table(file.path, header=F))

}

label_dataframe <- function(df, filepath){
  # use region and sample extracted from filepath
  # to label a dataframe with that info as columns
  region <- get_region_from_input_file(filepath)
  sample <- get_sample_from_input_file(filepath)
  df$sample <- sample
  df$region <- region

  df

}

process_data_for_metaplot <- function(df){
  # aggregate data by bin number, take mean, 95% confidence interval
  # and label with sample and region. Standardize data to mean 1 and
  # sd of 1 before processing. 
  df.vals <- df[, c(4, 5)]  # take only the bin number and score
  #df.vals[, 2] <- scale(df.vals[, 2])
  df.agg <- as.data.frame(aggregate(df.vals, 
                          list(bin=df.vals[, 1]), 
                          function(x) c(mean=mean(x), se=confidence_interval(x)))
                          )
  bin <- df.agg$bin
  df.agg <- as.data.frame(df.agg$V5)  # holds mean and se
  df.agg$bin <- bin
  df.agg$sample <- unique(df$sample)
  df.agg$region <- unique(df$region)

  df.agg

}


format_data_for_umap <- function(df, n_bins=100){

  groups <-  split(df, (seq(nrow(df))-1) %/% n_bins)
  regions <- list()
  for (i in 1:length(groups)){
    #spread.df <- as.data.frame(spread(groups[[i]], bin, mean))
    g <- groups[[i]]
    region.coords <- 
    groups[[i]] <- spread.df
    #region.name <- paste(g[1, 1], g[1, 2], g[nrow(g), 2], sep="_")
    sample <- unique(g$sample)
    region <- unique(g$region)
    regions[[i]] <- list(region=region, sample=sample, scores=g$V5)
  }
  df.umap <- do.call("rbind", groups)
  df.umap
  
}


plot_meta_region <- function(df.agg){

    # by_region <- ggplot(df.agg, aes(x=as.numeric(bin), y=mean, color=sample)) + theme_pubclean() +
    # labs(x='bins') + 
    # geom_ribbon(aes(ymax=mean+se, ymin=mean-se, x=as.numeric(bin), fill=sample), alpha=0.7) +
    # geom_line(color='black') + facet_wrap(~region)
    #df.agg.region <- subset(df.agg, region==region.name)
    n_samples <- unique(df.agg$sample)
    colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(n_samples))

    by_sample <- ggplot(df.agg, aes(x=as.numeric(bin), y=mean)) + theme_pubr() +
    labs(x='bins') + 
    geom_ribbon(aes(ymax=mean+se, ymin=mean-se, x=as.numeric(bin), fill=sample), alpha=0.4) +
    geom_line(aes(color=sample)) + facet_grid(vars(sample), vars(region), scales="free") + scale_color_manual(values=colors) + 
    scale_fill_manual(values=colors) + theme(legend.position = "none")

    by_sample

}

plot_umap <- function(df.umap){
  # still need to consider regions 
  colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(n_samples))
  obs <- do.call('rbind', df.umap$scores)
  embeddings <- as.data.frame(umap(obs)$embeddings)
  colnames(embeddings) <- c('umap_1', 'umap_2')
  embeddings$region <- unlist(df.umap$region)
  embeddings$sample <- unlist(df.umap$sample)
  plt <- ggplot(embeddings$layout, aes(x=umap_1, y='umap_2', color=sample)) + 
        geom_point(alpha=0.2) + theme_pubr() + scale_fill_manual(values=colors) +
        facet_wrap(~region)
  plt
}


main <- function(){

  input.files <- unique(snakemake@input)
  print(input.files)
  dfs <- list()
  save.image('madebigdf.Rdata')
  for (i in 1:length(input.files)){
    print(input.files[[i]])
    data <- read_meta(input.files[[i]])
    print('data type')
    print(typeof(data))
    data.label <- label_dataframe(data, as.character(input.files[[i]]))
    dfs[[i]] <- process_data_for_metaplot(data.label)
    print(colnames(dfs[[i]]))
  }
  big.df <- do.call("rbind", dfs)
  #umap.df <- format_data_for_umap(big.df)
  #save.image('umap.Rdata')
  metaplot <- plot_meta_region(big.df)
  print(colnames(big.df))
  ggsave(as.character(snakemake@output), metaplot, width=14, height=10, unit='in')



}


if (! interactive()){
  main()
}


# big.df <- do.call("rbind", dfs)
# #umaps <- format_df_for_umap(big.df)
# save.image('test.RData')
# region_plts <- list()

# #colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(dfs))
# regions <- unique(big.df$region)


# # for (i in 1:length(regions)){

# #   region_plts[[i]] <- plot_meta_region(big.df, regions[[i]])

# # }



# alphabet <- c('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H')

# plt <- plot_meta_region(big.df)

# #plt <- ggarrange(plotlist=region_plts, labels=regions, nrow=length(region_plts), ncol=1)
# ggsave(as.character(snakemake@output), plt, width=14, height=10, unit='in')


