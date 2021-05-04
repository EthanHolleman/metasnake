
import pandas as pd
from pathlib import Path

SAMPLES = pd.read_table(config['samples']).set_index("sample_name", drop=False)
REGIONS = pd.read_table(config['regions']).set_index("region_name", drop=False)



rule all:
    input:
        'output/metaplot.png'





rule window_regions:
    conda:
        'envs/bedtools.yml'
    input:
        region_bed=lambda wildcards: REGIONS.loc[wildcards.region]['filepath']
    output:
        'output/windowed_regions/{region}.bed'
    params:
        window_size = config['n_windows'],

    output:
        ''
    shell:'''
    mkdir -p output/windowed_regions
    bedtools makewindows -b {input.region_bed} \
    -n 100 -i winnum > {output}
    '''


rule sort_region_file:
    input:
        'output/windowed_regions/{region}.bed'
    output:
        'output/windowed_regions/{region}.sorted.bed'
    shell:'''
    sort -k 1,1 -k2,2n {input} > {output}
    '''


rule window_coverage_bed:
    conda:
        'envs/bedtools.yml'
    input:
        windows='output/windowed_regions/{region}.sorted.bed'
    params:
        sample_path=lambda wildcards: SAMPLES.loc[wildcards.sample_name]['filepath'],
        sorted_sample='output/sort/{sample_name}.sorted.bed'

    output:
        'output/window_coverage/{region}.{sample_name}.coverage.bed'
    shell:'''
    mkdir -p output/sort
    sort -k 1,1 -k2,2n {params.sample_path} > {params.sorted_sample}
    mkdir -p output/window_coverage
    bedtools coverage -sorted -a {input.windows} -b {params.sorted_sample} -counts > {output}
    '''
#  # bedtools coverage -a {input.windows} -b {params.sample_path} -counts > {output}



rule sort_coverage_bedgraph_by_window_num:
    input:
        'output/window_coverage/{region}.{sample_name}.coverage.bed'
    output:
        'output/window_coverage/{region}.{sample_name}.coverage.sorted.bed'
    shell:'''
    sort -k 1,1 -k2,2n {input} > {output}
    '''


rule average_coverage_by_window:
    conda: 
        'envs/bedtools.yml'
    input:
        'output/window_coverage/{region}.{sample_name}.coverage.sorted.bed'
    output:
        'output/average_coverage/{region}.{sample_name}.avg.tsv'
    shell:'''
    bedtools groupby -i {input} -g 4 -c 5 -o mean > {output}
    '''


rule make_metaplots:
    conda:
        'envs/R.yml'
    input:
        expand(
            'output/average_coverage/{region}.{sample_name}.avg.tsv',
            region=REGIONS.index.values.tolist(),
            sample_name=SAMPLES.index.values.tolist()
            )
    output:
        'output/metaplot.png'
    script:"scripts/metaplot.R"


        


    

