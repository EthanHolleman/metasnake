

rule sort_regions_bedgraph:
    input:
        expand(REGIONS['filepath'].tolist())
    output:
        'output/regions/{region_name}.{strand}.sorted.bedgraph'
    params:
        filepath=lambda wildcards: REGIONS.loc[
            f'{wildcards.region_name}{wildcards.strand}', 'filepath'
            ]
    shell:'''
    sort  -k1,1 -k2,2n {params.filepath} > {output}
    '''