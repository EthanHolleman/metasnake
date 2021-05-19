# convert hg19 genes bed into strand seperated
# bedgraph files

GENES = 'data/hg19/hg19_apprisplus_gene.bed'

rule seperate_fwd_strand:
    input:
        GENES
    output:
        'output/prep/hg19_apprisplus.fwd.bed'
    shell:'''
    awk '$6 == "+" {{print $0}}' {input} > {output}
    '''


rule seperate_rev_strand:
    input:
        GENES
    output:
        'output/prep/hg19_apprisplus.rev.bed' 
    shell:'''
    awk '$6 == "-" {{print $0}}' {input} > {output}
    '''


rule sort_bed_for_bedgraph_conversion:
    # sort a bed before converting to bedgraph
    input:
        'output/prep/hg19_apprisplus.{strand}.bed'
    output:
        'output/prep/hg19_apprisplus.{strand}.sorted.bed'
    shell:'''
    sort -k 1,1 -k2,2n {input} > {output}
    '''


rule convert_bed_to_bedgraph:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/prep/hg19_apprisplus.{strand}.sorted.bed'
    output:
        'output/prep/hg19_apprisplus.{strand}.bedgraph'
    shell:'''
    awk '{{ print $1"\t"$2"\t"$3"\t"$5 }}' {input} > {output}
    '''


rule sort_og_bedgraph:
    input:
        'output/prep/hg19_apprisplus.{strand}.bedgraph'
    output:
        'output/prep/hg19_apprisplus.{strand}.sorted.bedgraph'
    shell:'''
    sort -k1,1 -k2,2n {input} > {output}
    ''' 

