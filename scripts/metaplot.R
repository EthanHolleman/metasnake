library(ggplot2)
library(ggpubr)
library(tidyr)
library(RColorBrewer)
#library(umap)


get_sample_from_input_file <- function(input.path){

    unlist(strsplit(basename(input.path), '\\.'))[2]

}

get_region_from_input_file <- function(input.path){

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

  print(file.path)
  print(typeof(file.path))
  df <- as.data.frame(read.table(file.path, header=F))
  df.agg <- as.data.frame(aggregate(df, list(df$V1), function(x) c(mean=mean(x), se=confidence_interval(x))))
  # aggregate by bin, taking the mean and standard error for each bin
  # return just bin, mean and se
  region <- get_region_from_input_file(file.path)
  sample <- get_sample_from_input_file(file.path)
  df.agg <- as.data.frame(df.agg$V2)
  df.agg$bin <- rownames(df.agg)
  df.agg$region <- region
  df.agg$sample <- sample
  df.agg  
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

# format_df_for_umap <- function(big.df){

#   # samples need to be rows and then columns
#   # become values, also need to seperate
#   # by each region
#   regions.dfs <- list()
#   regions <- unique(big.df$regions)
#   for (i in 1:length(regions)){

#     regions.dfs[[i]] <- subset(big.df, region==regions[[i]])

#   }
#   umap.dfs <- list()
#   for (i in 1:length(regions.dfs)){
    
#     df <- regions.dfs[[i]]
#     df <- spread(df, sample, bin)
#     umap <- as.data.frame(umap(df))




#   }



# }


input.files <- snakemake@input
dfs <- list()
for (i in 1:length(input.files)){
    dfs[[i]] <- read_meta(input.files[i])
}

big.df <- do.call("rbind", dfs)
region_plts <- list()

#colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(dfs))
regions <- unique(big.df$region)


# for (i in 1:length(regions)){

#   region_plts[[i]] <- plot_meta_region(big.df, regions[[i]])

# }

save.image()

alphabet <- c('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H')

plt <- plot_meta_region(big.df)

#plt <- ggarrange(plotlist=region_plts, labels=regions, nrow=length(region_plts), ncol=1)
ggsave(as.character(snakemake@output), plt, width=14, height=10, unit='in')


