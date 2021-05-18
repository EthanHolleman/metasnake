from pathlib import Path


rule sort_samples_bedgraph:
    input:
        expand(SAMPLES['filepath'].tolist())
    output:
        'output/samples/{sample_name}.{strand}.sorted.bedgraph'
    params:
        filepath=lambda wildcards: SAMPLES.loc[(SAMPLES['sample_name'] == wildcards.sample_name) & (SAMPLES['strand'] == wildcards.strand)]['filepath'][0]
    shell:'''
    mkdir -p output/samples/
    sort -k1,1 -k2,2n {params.filepath} > {output}
    '''


