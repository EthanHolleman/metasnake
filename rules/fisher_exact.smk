

rule fisher_exact:
    conda:
        '../envs/bedtools.yml'
    input:
        genome=config['genome'],
        regions='output/windowed_regions/{region}.{strand}.bed',
        sample='output/samples/{sample_name}.{strand}.bed'
    output:
        'output/fischer/tests/{sample_name}.{region}.{strand}.ftest'
    shell:'''
    bedtools fisher -a {input.regions} -b {input.sample} \
    -g {input.genome} > {output}
    '''

rule fisher_exact_plot:
    conda:
        '../envs/R.yml'
    input:
        fwd='output/fischer/{sample_name}.{region}.fwd.ftest',
        rev='output/fischer/{sample_name}.{region}.rev.ftest'
    output:
        'output/fischer/Rdata/{sample_name}.{region}.rds'
    script:""

