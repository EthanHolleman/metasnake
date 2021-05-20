

rule generate_random_hg19_regions_fwd:
    output:
        'output/prep/random/random_fwd.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    bedtools random -g {params.genome} -n 10000 | cut -f 1,2,3,4 > {output}
    '''

rule generate_random_hg19_regions_rev:
    output:
        'output/prep/random/random_rev.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    bedtools random -g {params.genome} -n 10000 | cut -f 1,2,3,4 > {output}
    '''
