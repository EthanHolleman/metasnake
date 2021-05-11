library(ggplot2)
library(ggpubr)
library(RColorBrewer)



ftest_heatmap <- function(df, strand){

  title <- paste('Fisher exact test', strand)
  hm <- ggplot(df, aes(x=sample, y=region, fill=two.tail)) + 
            geom_tile() + theme_pubr() + ggtitle(title) +
            theme(axis.text.x = element_text(angle = 45, hjust=1)) +
            labs(x='', y='')
  hm

}

num_overlaps_plt <- function(df, strand){

  title <- paste('Proportion of overlaps', strand)
  colors <- colorRampPalette(brewer.pal(8, "Dark2"))(nrow(df))
  df$total_obs <- df$Number_of_query_intervals + df$Number_of_db_intervals
  df$prop_overlap <- df$Number_of_overlaps / df$Number_of_possible_intervals_.estimated.

  plt <- ggplot(df, aes(x=as.factor(sample), y=prop_overlap, fill=region)) +
        geom_bar(color='black', stat='identity', position=position_dodge()) +
        theme_pubr() + scale_fill_manual(values=colors) + 
        labs(y='Overlaps / number estimated possible', x='Sample') +
        ggtitle(title)

  plt
  

}


plots <- function(fish.df){


    # strand sample region and all variables that could be grouped together
    strand.df.fwd <- subset(fish.df, strand=='fwd')
    strand.df.rev <- subset(fish.df, strand=='rev')
    fwd.heatmap <- ftest_heatmap(strand.df.fwd, '+ strand')
    rev.heatmap <- ftest_heatmap(strand.df.rev, '- strand')
    prop.overlap.fwd <- num_overlaps_plt(strand.df.fwd, '+ strand')
    prop.overlap.rev <- num_overlaps_plt(strand.df.rev, '- strand')
    
    heatmaps <- ggarrange(
       fwd.heatmap , rev.heatmap, nrow=1, ncol=2, common.legend = TRUE
    )
    fishers <- ggarrange(
      prop.overlap.fwd, prop.overlap.rev, nrow=1, ncol=2, common.legend = TRUE
    )
    main.plt <- ggarrange(
      fishers, heatmaps, labels=c('A', 'B'), nrow=2, ncol=1
    )
    main.plt

}


main <- function(){
    input.file <- as.character(snakemake@input)  # concatenated fischer test file
    output.file <- as.character(snakemake@output)
    #input.file <- "/home/ethollem/projects/metaploter/output/fisher/tests/all_fischer_files.tsv"
    #output.file <- 'test.fish.png'
    fish.df <- as.data.frame(read.table(input.file, header=T))
    plts <- plots(fish.df)
    print(plts)
    print(typeof(plts))
    ggsave(output.file, plts, width=16, height=12, dpi=600)

}


if (! interactive()){
  main()
}


