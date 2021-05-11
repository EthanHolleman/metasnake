from pathlib import Path

SAMPLE_NAMES = SAMPLES['sample_name'].tolist()
FILE_EXT = [Path(SAMPLES.loc[sample_name]['filepath']).suffix.replace('.', '') 
            for sample_name in SAMPLE_NAMES]



rule sym_link_all_samples:
    input:
        expand(
            'output/samples/sym_links/{sample_name}.{bed_or_bedgraph}',
            zip, sample_name=SAMPLE_NAMES, bed_or_bedgraph=FILE_EXT
        )


rule sym_link_sample:
    output:
        'output/samples/sym_links/{sample_name}.{bed_or_bedgraph}'
    params:
        sample_file=lambda wildcards: SAMPLES.loc[wildcards.sample_name]['filepath']
    shell:'''
    ln -sf {params.sample_file} {output}
    '''


rule seperate_bed6_strands_fwd:
    input:
        'output/samples/sym_links/{sample_name}.bed'
    output:
        'output/samples/stranded/{sample_name}.fwd.bed'
    shell:'''
    mkdir -p output/samples/stranded
    awk  '$6 == "+" {{print $0}}' {input} > {output}
    '''


rule seperate_bed6_strands_rev:
    input:
        'output/samples/sym_links/{sample_name}.bed'
    output:
        'output/samples/stranded/{sample_name}.rev.bed'
    shell:'''
    mkdir -p output/samples/stranded
    awk  '$6 == "-" {{print $0}}' {input} > {output}
    '''


rule sort_samples_bed6:
    input:
        'output/samples/stranded/{sample_name}.{strand}.bed'
    output:
        'output/samples/sorted_bed/{sample_name}.{strand}.sorted.bed'
    shell:'''
    mkdir -p output/samples/sorted_bed/
    sort -k1,1 -k2,2n {input} > {output}
    '''


rule sort_samples_bedgraph:
    input:
        'output/samples/sym_links/{sample_name}.bedgraph'
    output:
        'output/samples/sorted_bedgraph/{sample_name}.sorted.bedgraph'
    shell:'''
    mkdir -p output/samples/sorted_bedgraph/
    sort -k1,1 -k2,2n {input} > {output}
    '''


