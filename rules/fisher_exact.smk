

rule sort_regions_bed:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/{region}.{strand}.bed'
    output:
        'output/windowed_regions/{region}.{strand}.sorted.bed'
    shell:'''
    bedtools sort -i {input} > {output}
    '''

rule fisher_exact:
    conda:
        '../envs/bedtools.yml'
    input:
        genome=config['genome'],
        regions='output/windowed_regions/{region}.{strand}.sorted.bed',
        sample='output/samples/{sample_name}.{strand}.sorted.bed'
    output:
        'output/fisher/tests/{sample_name}.{region}.{strand}.ftest'
    shell:'''
    mkdir -p output/fisher/tests
    bedtools fisher -a {input.regions} -b {input.sample} \
    -g {input.genome} > {output}
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
    


