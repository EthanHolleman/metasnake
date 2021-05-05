
DRIP_SAMPLES = pd.read_csv(
    'samples/DRIP_samples.tsv', sep='\t'
).set_index('sample', drop=False)


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


rule bedgraph_to_bed:
    # input bedgraph with chr, start, end and score and return bed
    # with input, start, end, name (sample plus line number) score and strand
    input:
        'data/DRIP/{sample_strand}.bedgraph'
    output:
        'data/DRIP/{sample_strand}.bed'
    params:
        strand = lambda wildcards: '+' if 'fwd' in wildcards['sample_strand'] else '-',
        sample_name = lambda wildcards: wildcards['sample_strand']
    shell:'''
    awk '{{print $1 "\t" $2 "\t" $3 "\t" NR "_{params.sample_name}" "\t" $4 "\t" "{params.strand}"}}' {input} > {output}
    '''


rule concatenate_drip_bed_files:
    input:
        expand('data/DRIP/{sample_strand}.bed',
        sample_strand=DRIP_SAMPLES.index.tolist())
    output:
        'data/DRIP/DRIPc.bed'
    shell:'''
    cat {input} > {output}
    '''


rule sort_concat_drip_bed:
    input:
        'data/DRIP/DRIPc.bed'
    output:
        'data/DRIP/DRIPc.sorted.bed'
    shell:'''
    sort -k 1,1 -k2,2n {input} > {output}
    '''







        