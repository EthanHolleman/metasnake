

rule generate_random_hg19_regions:
    output:
        'output/prep/random/random_{direction}.uniform.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    bedtools random -g {params.genome} -n 100000 -l 3000 | cut -f 1,2,3,4 > {output}
    '''

rule randomize_lengths:
    input:
        'output/prep/random/random_{direction}.uniform.bedgraph'
    output:
        'output/prep/random/random_{direction}.bedgraph'
    params:
        genome=config['genome']
    script:'../scripts/randomize_bed.py'
