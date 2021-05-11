rule sort_samples:
    input:
        'output/samples/{sample_name}.{strand}.{bed_or_bedgraph}'
    output:
        'output/samples/{sample_name}.{strand}.sorted.{bed_or_bedgraph}'
    shell:'''
     sort -k1,1 -k2,2n {input} > {output}
    '''

rule sym_link_all_samples:
    input:
        SAMPLES['filepath'].tolist()


rule sym_link_sample:
    input:
        '{sample_path}.{bed_or_bedgraph}''
    output:
        'samples/{sample_name}.{bed_or_bedgraph}'
    shell:'''
    ln -s {input} {output}
    '''

rule seperate_sample_fwd_strand:
    input:
        'samples/{sample_name}.{bed_or_bedgraph}'
    output:
        'output/samples/{sample_name}.fwd.bed'
    params:
        sample_path=lambda wildcards: SAMPLES.loc[wildcards.sample_name]['filepath']
    shell:'''
    awk  '$6 == "+" {{print $0}}' {params.sample_path} > {output}
    '''


rule seperate_sample_rev_strand:
    input:
        'samples/{sample_name}.{bed_or_bedgraph}'
    output:
        'output/samples/{sample_name}.rev.bed'
    params:
        sample_path=lambda wildcards: SAMPLES.loc[wildcards.sample_name]['filepath']
    shell:'''
    awk  '$6 == "-" {{print $0}}' {params.sample_path} > {output}
    '''