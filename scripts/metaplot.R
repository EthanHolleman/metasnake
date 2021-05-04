library(ggplot2)
library(ggpubr)


get_sample_from_input_file <- function(input.path){

    unlist(strsplit(basename(input.path), '\\.'))[2]

}

get_region_from_input_file <- function(input.path){

    unlist(strsplit(basename(input.path), '\\.'))[1]

}


standard_error <- function(x){
  
  sd(x)/sqrt(length(x))
}

read_meta <- function(file.path){
  file.path <- as.character(file.path)

  print(file.path)
  print(typeof(file.path))
  df <- as.data.frame(read.table(file.path, header=F))
  df.agg <- as.data.frame(aggregate(df, list(df$V1), function(x) c(mean=mean(x), se=standard_error(x))))
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

plot_meta <- function(df.agg){
  
    # by_region <- ggplot(df.agg, aes(x=as.numeric(bin), y=mean, color=sample)) + theme_pubclean() +
    # labs(x='bins') + 
    # geom_ribbon(aes(ymax=mean+se, ymin=mean-se, x=as.numeric(bin), fill=sample), alpha=0.7) +
    # geom_line(color='black') + facet_wrap(~region)

    by_sample <- ggplot(df.agg, aes(x=as.numeric(bin), y=mean, color=region)) + theme_pubclean() +
    labs(x='bins') + 
    geom_ribbon(aes(ymax=mean+se, ymin=mean-se, x=as.numeric(bin), fill=region), alpha=0.7) +
    geom_line(color='black') + facet_wrap(~sample)

    by_sample

}

input.files <- snakemake@input
dfs <- list()
for (i in 1:length(input.files)){
    dfs[[i]] <- read_meta(input.files[i])
}

big.df <- do.call("rbind", dfs)
plt <- plot_meta(big.df)
ggsave(as.character(snakemake@output), plt, width=14, height=10, unit='in')


