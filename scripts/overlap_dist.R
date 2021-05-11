library(ggplot2)
library(ggpubr)
library(RColorBrewer)

# read in coverage bed file and create distrabution for each sample
# in reach region

get_sample_from_input_file <- function(input.path){

    unlist(strsplit(basename(input.path), '\\.'))[2]

}

get_region_from_input_file <- function(input.path){

    unlist(strsplit(basename(input.path), '\\.'))[1]

}

read_coverage_bed <- function(file.path){

    file.path <- as.character(file.path)
    print(file.path)
    df <- as.data.frame(read.table(file.path, header=F))
    colnames(df) <- c('chr', 'start', 'stop', 'bin', 'count')
    region <- get_region_from_input_file(file.path)
    sample <- get_sample_from_input_file(file.path)
    df$region <- region
    df$sample <- sample

}

plot <- function(big.df){
    n_samples <- length(unique(big.df$region))
    colors <- colorRampPalette(brewer.pal(8, "Dark2"))(length(n_samples))
    ggplot(big.df, aes(x=count, fill=region)) + theme_pubr() +
    geom_density(color='black', alpha=0.7) + scale_fill_manual(values=colors) +
    facet_wrap(~sample)

}

main <- function(){

    input.files <- snakemake@input
    output.file <- as.character(snakemake@output)
    save.image()
    dfs <- list()
    for (i in 1:length(input.files)){
        dfs[[i]] <- read_coverage_bed(input.files[i])
    }
    big.df <- do.call("rbind", dfs)
    plt <- plot(big.df)
    ggsave(output.file, plt, dpi=500, width=12, height=12)

}

if (! interactive()){
    main()
}

