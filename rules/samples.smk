from pathlib import Path

SAMPLE_NAMES = SAMPLES['sample_name'].tolist()
FILE_EXT = [Path(SAMPLES.loc[sample_name]['filepath']).suffix.replace('.', '') 
            for sample_name in SAMPLE_NAMES]
STRAND = SAMPLES['strand'].tolist()



rule sym_link_all_samples:
    input:
        expand(
            'output/samples/{sample_name}.{strand}.{bed_or_bedgraph}',
            zip, sample_name=SAMPLE_NAMES, bed_or_bedgraph=FILE_EXT,
            strand=STRAND  # fwd rev or all 
        )


rule sym_link_sample:
    output:
        'output/samples/{sample_name}.{strand}.{bed_or_bedgraph}'
    params:
        sample_file=lambda wildcards: SAMPLES.loc[wildcards.sample_name]['filepath']
    shell:'''
    ln -sf {params.sample_file} {output}
    '''


rule sort_bed_for_bedgraph_conversion:
    # sort a bed before converting to bedgraph
    input:
        'output/samples/{sample_name}.{strand}.bed'
    output:
        'output/samples/{sample_name}.{strand}.sorted.bed'
    shell:'''
    sort -k 1,1 {input} > {output}
    '''


rule convert_bed_to_bedgraph:
    # convert all input bed files to bedgraph using bedtools genome cov
    conda:
        '../envs/bedtools.yml'
    input:
        'output/samples/{sample_name}.{strand}.sorted.bed'
    output:
        'output/samples/{sample_name}.{strand}.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    bedtools genomecov -bg -g {params.genome} -i {input} > {output}
    '''


rule sort_samples_bedgraph:
    input:
        'output/samples/{sample_name}.{strand}.bedgraph'
    output:
        'output/samples/{sample_name}.{strand}.sorted.bedgraph'
    shell:'''
    sort -k1,1 -k2,2n {input} > {output}
    '''


