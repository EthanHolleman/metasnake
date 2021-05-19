
rule sort_regions_bedgraph:
    input:
        expand(REGIONS['filepath'].tolist())
    output:
        'output/regions/{region_name}.{strand}.sorted.bedgraph'
    params:
        filepath=lambda wildcards: REGIONS.loc[(REGIONS['region_name'] == wildcards.region_name) & (REGIONS['strand'] == wildcards.strand)]['filepath'][0]
    shell:'''
    sort  -k1,1 -k2,2n {params.filepath} > {output}
    '''