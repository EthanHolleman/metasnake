
# DRIP_SAMPLES = pd.read_csv(
#     'samples/DRIP_samples.tsv', sep='\t'
# ).set_index('sample', drop=False)


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
        'data/DRIP/{sample_strand}.bw'
    output:
        'data/DRIP/{sample_strand}.bedgraph'
    shell:'''
    bigWigToBedGraph {input} {output}
    '''







        