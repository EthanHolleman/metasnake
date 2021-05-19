# Prep DRIP samples for metaplotting (convert wig to bedgraph)


rule download_drip_samples:
    output:
        'data/DRIP/{sample_strand}.bw'
    params:
        download_link = lambda wildcards: DRIP_SAMPLES.loc[wildcards.sample_strand]['url']
    shell:'''
    mkdir -p data/DRIP
    curl -L {params.download_link} -o {output}
    '''


rule bigwig_to_bedgraph:
    conda:
        '../envs/ucsc.yml'
    input:
        'data/prep/DRIP/{sample_strand}.bw'
    output:
        'data/prep/DRIP/{sample_strand}.bedgraph'
    shell:'''
    mkdir -p data/prep/DRIP/
    bigWigToBedGraph {input} {output}
    '''







        