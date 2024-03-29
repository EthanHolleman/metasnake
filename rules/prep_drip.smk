# Prep DRIP samples for metaplotting (convert wig to bedgraph)

DRIP_SAMPLES = pd.read_table('samples/DRIP_samples.tsv').set_index('sample', drop=False)

wildcard_constraints:
    sample_strand='\w+'


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
        'data/DRIP/{sample}_{strand}.bw'
    output:
        'output/prep/DRIP/{sample}_{strand}.bedgraph'
    shell:'''
    mkdir -p output/prep/DRIP/
    bigWigToBedGraph {input} {output}
    '''


# rule merge_drip_bedgraph:
#     conda:
#         '../envs/bedtools.yml'
#     input:
#         'output/prep/DRIP/{sample}_{strand}.premerge.bedgraph'
#     output:
#         'output/prep/DRIP/{sample}_{strand}.bedgraph'
#     shell:'''
#     bedtools merge -i {input} > {output}
#     '''


rule extend_drip_regions:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/prep/DRIP/{sample}_{strand}.bedgraph'
    output:
        'output/prep/DRIP/{sample}_{strand}.premerge.1kbext.bedgraph'
    params:
        genome = config['genome']
    shell:'''
    mkdir -p output/prep/DRIP/
    bedtools slop -i {input} -g {params.genome} -b 1000 > {output}
    '''


rule merge_extend_drip_regions:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/prep/DRIP/{sample}_{strand}.premerge.1kbext.bedgraph'
    output:
        'output/prep/DRIP/{sample}_{strand}.1kbext.bedgraph'
    params:
        genome = config['genome']
    shell:'''
    mkdir -p output/prep/DRIP/
    bedtools merge -i {input} > {output}
    '''







        