rule average_coverage_by_window:
    conda: 
        '../envs/bedtools.yml'
    input:
        'output/window_coverage/{region}.{sample_name}.all.coverage.sorted.bed'
    output:
        'output/average_coverage/{region}.{sample_name}.avg.tsv'
    shell:'''
    bedtools groupby -i {input} -g 4 -c 5 -o mean > {output}  && [[ -s {output} ]]
    '''

# make rule for bedgraphs as well