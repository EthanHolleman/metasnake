FWD = 'data/DRIPc/DRIPc_minus_macs.bed'
REV = 'data/DRIPc/DRIPc_plus_macs.bed'


rule convert_dripc_mac_to_bedgraph:
    input:
        fwd=FWD,
        rev=REV
    output:
        fwd='output/prep/DRIPc_macs/DRIPc_plus_macs.bedgraph',
        rev='output/prep/DRIPc_macs/DRIPc_minus_macs.bedgraph'
    shell:'''
    cut {input.fwd} -f 1,2,3,5 > {output.fwd}
    cut {input.rev} -f 1,2,3,5 > {output.rev}
    '''

rule make_shuffled_drip:
    input:
        bedgraph='output/prep/DRIPc_macs/DRIPc_{direction}_macs.bedgraph'
    output:
        'output/prep/DRIPc_macs/DRIPc_{direction}_macs.shuffled.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    bedtools shuffle -i {input} -g {params.genome} > {output}
    '''


rule make_extended_dripc_macs_bedgraph:
    input:
        'output/prep/DRIPc_macs/DRIPc_{direction}_macs.bedgraph'
    output:
        'output/prep/DRIPc_macs/DRIPc_{direction}_macs.ext1kb.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    bedtools slop -i {input} -g {params.genome} -b 1000 > {output}
    '''


rule orrient_at_DRIP_start_2kb_rev:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/prep/DRIPc_macs/DRIPc_minus_macs.bedgraph'
    output:
        start='output/prep/DRIPc_macs/DRIPc_minus_macs.start.bedgraph',
        slop='output/prep/DRIPc_macs/DRIPc_minus_macs.start.2kb.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    awk '{{print $1 "\t" $3 "\t" $3+1 "\t" $4}}' {input} > {output.start} && [[ -s {output.start} ]]
    bedtools slop -i {output.start} -b 2000 > {output.slop} -g {params.genome} > {output.slop}
    '''


rule orrient_at_DRIP_end_2kb_fwd:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/prep/DRIPc_macs/DRIPc_plus_macs.bedgraph'
    output:
        start='output/prep/DRIPc_macs/DRIPc_plus_macs.start.bedgraph',
        slop='output/prep/DRIPc_macs/DRIPc_plus_macs.start.2kb.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    awk '{{print $1 "\t" $2 "\t" $2+1 "\t" $4}}' {input} > {output.start} && [[ -s {output.start} ]]
    bedtools slop -i {output.start} -b 2000 > {output.slop} -g {params.genome} > {output.slop}
    '''



