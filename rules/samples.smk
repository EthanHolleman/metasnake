from pathlib import Path


# rule sym_link_sample:
#     output:
#         'output/samples/sym_links/{sample_name}.{strand}.{bed_or_bedgraph}'
#     params:
#         sample_file=lambda wildcards: SAMPLES.loc[wildcards.sample_name]['filepath']
#     shell:'''
#     ln -sf {params.sample_file} {output}
#     '''


# rule sort_bed_for_bedgraph_conversion:
#     # sort a bed before converting to bedgraph
#     input:
#         'output/samples/sym_links/{sample_name}.{strand}.bed'
#     output:
#         'output/samples/sym_links/{sample_name}.{strand}.sorted.bed'
#     shell:'''
#     sort -k 1,1 -k2,2n {input} > {output}
#     '''


# rule convert_bed_to_bedgraph:
#     # convert all input bed files to bedgraph using bedtools genome cov
#     conda:
#         '../envs/bedtools.yml'
#     input:
#         'output/samples/sym_links/{sample_name}.{strand}.sorted.bed'
#     output:
#         'output/samples/bedgraph/{sample_name}.{strand}.bedgraph'
#     params:
#         genome=config['genome']
#     shell:'''
#     bedtools genomecov -bg -g {params.genome} -i {input} > {output}
#     '''


# rule sort_og_bedgraph:
#     input:
#         'output/samples/sym_links/{sample_name}.{strand}.bed'
#     output:
#         'output/samples/{sample_name}.{strand}.sorted.bedgraph'
#     shell:'''
#     sort -k1,1 -k2,2n {input} > {output}
#     ''' 


rule sort_samples_bedgraph:
    output:
        'output/samples/{sample_name}.{strand}.sorted.bedgraph'
    params:
        filepath=lambda wildcards: SAMPLES.loc[SAMPLES['sample_name'] == wildcards.sample_name]['filepath']
    shell:'''
    sort -k1,1 -k2,2n {input} > {output}
    '''


