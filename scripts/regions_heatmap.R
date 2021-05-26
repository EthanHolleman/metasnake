library(gplots)
library(RColorBrewer)

format_converage_data <- function(file.path){

    df <- read.table(as.character(file.path), header=F)
    groups <- split(df[, 5], (seq(nrow(df))-1) %/% max(df[, 4]))
    # rows of the df will be ordered by their window id in blocks of n
    # where n is the number of windows per region. So we can split the data
    # frame into blocks of size n to recover the original regions
    matrix.df <- as.data.frame((do.call(rbind, groups)))
    colnames(matrix.df) <- 1:ncol(matrix.df)
    as.matrix(matrix.df)


}

make_heatmap <- function(matrix.bins, output.path){
    pdf(as.character(output.path))
    heatmap.2(matrix.bins, Colv = NA, trace='none', col=brewer.pal(11,"RdBu"))
    dev.off()
}


main <- function(){

    matrix.bins <- format_converage_data(snakemake@input)
    message('Made matrix')
    make_heatmap(matrix.bins, snakemake@output)
    message('Plotted heatmap')

}


if (! interactive()){

    main()

}

