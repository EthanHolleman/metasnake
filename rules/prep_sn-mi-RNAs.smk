
sn_mi_RNAs_bed = 'data/sno-miRNA/sno-miRNA.bed'

rule seperate_fwd_strand_miRNA:
    input:
        sn_mi_RNAs_bed
    output:
        'output/prep/sn-mi-RNA.fwd.bed' 
    shell:'''
    awk '$6 == "+" {{print $0}}' {input} > {output}
    '''


rule seperate_rev_strand_miRNA:
    input:
        sn_mi_RNAs_bed
    output:
        'output/prep/sn-mi-RNA.rev.bed' 
    shell:'''
    awk '$6 == "-" {{print $0}}' {input} > {output}
    '''

rule convert_miRNA_to_bedgraph:
    input:
         'output/prep/sn-mi-RNA.{strand}.bed'
    output:
        'output/prep/sn-mi-RNA.{strand}.bedgraph'
    shell:'''
    cut {input} -f 1,2,3,5 > {output}
    '''
