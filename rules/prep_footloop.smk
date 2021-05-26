
FOOTLOOP_PATH = 'data/footloop/footloop_all.bed'

rule seperate_fwd_strand_footloop:
    input:
        FOOTLOOP_PATH
    output:
        'output/prep/footloop.fwd.bed'
    shell:'''
    awk '$6 == "+" {{print $0}}' {input} > {output}
    '''


rule seperate_rev_strand_footloop:
    input:
        FOOTLOOP_PATH
    output:
        'output/prep/footloop.rev.bed' 
    shell:'''
    awk '$6 == "-" {{print $0}}' {input} > {output}
    '''


rule covert_footloop_bed_to_bedgraph:
    input:
         'output/prep/footloop.{strand}.bed'
    output:
        'output/prep/footloop.{strand}.bedgraph'
    shell:'''
    cut {input} -f 1,2,3,5 > {output}
    '''


rule make_footloop_initiation_site_regions:
    # inputs full length footloop sites and returns regions 1kb around the
    # start site in both upstream and downstream directions. Made with
    # intention of comaparing RNA structure scores around R-loop
    # initiation sites
    input:
        'output/prep/footloop.{strand}.bedgraph'
    output:
        'output/prep/footloop.{strand}.1kbext.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    bedtools slop -i {input} -g {params.genome} -b 1000 > {output}
    '''



