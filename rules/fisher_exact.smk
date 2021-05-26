

rule sort_chrom_sizes:
    # I was in sorting hell last night, for some reasons was getting all kinds
    # of sort ordering related errors from bedtools. Fisher test was
    # saying "he following record with a different sort order than the genomeFile"
    # so I sort the genomeFile using the same sort command used to sort all
    # of the inputs before passing it to fisher.
    # https://www.biostars.org/p/174690/
    input:
        genome=config['genome']
    output:
        temp('output/genome/sorted_genome.sizes')
    shell:'''
    sort -k1,1 -k2,2 {input} > {output}
    '''


rule fisher_exact:
    conda:
        '../envs/bedtools.yml'
    input:
        genome='output/genome/sorted_genome.sizes',
        regions='output/windowed_regions/stranded/{region}.{strand}.sorted.bed',
        sample='output/samples/sorted_bed/{sample_name}.{strand}.sorted.bed'
    output:
        'output/fisher/tests/{sample_name}.{region}.{strand}.ftest'
    shell:'''
    mkdir -p output/fisher/tests
    bedtools fisher -a {input.regions} -b {input.sample} \
    -g {input.genome} > {output}  && [[ -s {output} ]]
    '''


rule sort_unseperated_regions:
    input:
        'output/windowed_regions/sym_links/{region_name}.bedgraph'
    output:
        'output/fisher/sorted/{region_name}.sorted.bedgraph'
    shell:'''
    sort -k1,1 -k2,2n {input} > {output}
    '''


rule fisher_exact_bedgraph:
    conda:
        '../envs/bedtools.yml'
    input:
        genome='output/genome/sorted_genome.sizes',
        regions='output/fisher/sorted/{region_name}.sorted.bedgraph',
        sample='output/samples/sorted_bedgraph/{sample_name}.sorted.bedgraph'
    output:
        'output/fisher/tests/{sample_name}.{region}.ftest'
    shell:'''
    mkdir -p output/fisher/tests
    bedtools fisher -a {input.regions} -b {input.sample} \
    -g {input.genome} > {output}  && [[ -s {output} ]]
    '''


rule process_ficher_file:
    input:
        'output/fisher/tests/{sample_name}.{region}.{strand}.ftest'
    output:
        'output/fisher/tests/{sample_name}.{region}.{strand}.ftest.tsv'
    script:
        '../scripts/fisher.py'


rule concatenate_processed_fisher_files:
    input:
        expand(
            'output/fisher/tests/{sample_name}.{region}.{strand}.ftest.tsv',
            sample_name=SAMPLES.index.values.tolist(),
            region=REGIONS.index.values.tolist(),
            strand=['fwd', 'rev']
        )
    output:
        'output/fisher/tests/all_fischer_files.tsv'
    script:'../scripts/concat_fisher.py'
    


