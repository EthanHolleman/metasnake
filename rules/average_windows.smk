rule average_coverage_by_window_bedgraph:
    # group a windowed coverage file by the window number
    # reverse strands are already reoriented because when windowing
    # the window numbers are applied in reverse making the first window
    # in the 5' -> 3' orrrientation have the greatest label number. 
    # Then take the average of the scores (which are the number of features
    # overlapping that window and average them). This then becomes what
    # is plotted in the metaplot.
    conda: 
        '../envs/bedtools.yml'
    input:
        'output/window_coverage/{region}.{sample_name}.all.coverage.bed'
    output:
        'output/average_coverage/bedgraph/{region}.{sample_name}.avg.tsv'
    shell:'''
    bedtools groupby -i {input} -g 4 -c 5 -o mean > {output}  && [[ -s {output} ]]
    '''


