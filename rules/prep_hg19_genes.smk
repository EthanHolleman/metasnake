# convert hg19 genes bed into strand seperated
# bedgraph files this assumes that hg19 file
# already exists in the data directory

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


rule orrient_at_TSS_2kb_rev:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/prep/hg19_apprisplus.rev.bedgraph'
    output:
        TSS='output/prep/hg19_apprisplus.rev.TSS.bedgraph',
        slop='output/prep/hg19_apprisplus.rev.TSS.2kb.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    awk '{{print $1 "\t" $3 "\t" $3+1 "\t" $4}}' {input} > {output.TSS} && [[ -s {output.TSS} ]]
    bedtools slop -i {output.TSS} -b 2000 > {output.slop} -g {params.genome} > {output.slop}
    '''


rule orrient_at_TSS_2kb_fwd:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/prep/hg19_apprisplus.fwd.bedgraph'
    output:
        TSS='output/prep/hg19_apprisplus.fwd.TSS.bedgraph',
        slop='output/prep/hg19_apprisplus.fwd.TSS.2kb.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    awk '{{print $1 "\t" $2 "\t" $2+1 "\t" $4}}' {input} > {output.TSS} && [[ -s {output.TSS} ]]
    bedtools slop -i {output.TSS} -b 2000 > {output.slop} -g {params.genome} > {output.slop}
    '''


rule orrient_at_TTS_2kb_rev:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/prep/hg19_apprisplus.rev.bedgraph'
    output:
        TSS='output/prep/hg19_apprisplus.rev.TTS.bedgraph',
        slop='output/prep/hg19_apprisplus.rev.TTS.2kb.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    awk '{{print $1 "\t" $2 "\t" $2+1 "\t" $4}}' {input} > {output.TSS} && [[ -s {output.TSS} ]]
    bedtools slop -i {output.TSS} -b 2000 > {output.slop} -g {params.genome} > {output.slop}
    '''


rule orrient_at_TTS_2kb_fwd:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/prep/hg19_apprisplus.fwd.bedgraph'
    output:
        TSS='output/prep/hg19_apprisplus.fwd.TTS.bedgraph',
        slop='output/prep/hg19_apprisplus.fwd.TTS.2kb.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    awk '{{print $1 "\t" $3 "\t" $3+1 "\t" $4}}' {input} > {output.TSS} && [[ -s {output.TSS} ]]
    bedtools slop -i {output.TSS} -b 2000 > {output.slop} -g {params.genome} > {output.slop}
    '''


rule sort_og_bedgraph:
    input:
        'output/prep/hg19_apprisplus.{strand}.bedgraph'
    output:
        'output/prep/hg19_apprisplus.{strand}.sorted.bedgraph'
    shell:'''
    sort -k1,1 -k2,2n {input} > {output}
    ''' 

