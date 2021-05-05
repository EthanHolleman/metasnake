
import pandas as pd
from pathlib import Path

SAMPLES = pd.read_table(config['samples']).set_index("sample_name", drop=False)
REGIONS = pd.read_table(config['regions']).set_index("region_name", drop=False)

wildcard_constraints:
   region = '\w+',
   sample_name = '\w+',
   strand = '\w+'


include: 'rules/drip.smk'

rule all:
    input:
        'output/metaplot.png',
        'data/DRIP/DRIPc.sorted.bed'


rule seperate_window_strands_fwd:
    output:
        'output/windowed_regions/{region}.fwd.bed'
    params:
        region_bed=lambda wildcards: REGIONS.loc[wildcards.region]['filepath']
    shell:'''
    awk '$6 == "+" {{print $0}}' {params.region_bed} > {output}
    '''


rule seperate_window_strands_rev:
    output:
        'output/windowed_regions/{region}.rev.bed'
    params:
        region_bed=lambda wildcards: REGIONS.loc[wildcards.region]['filepath']
    shell:'''
    awk  '$6 == "-" {{print $0}}' {params.region_bed} > {output}
    '''


rule window_regions_fwd:
    conda:
        'envs/bedtools.yml'
    input:
        'output/windowed_regions/{region}.fwd.bed'
    output:
        'output/windowed_regions/{region}.window.fwd.bed'
    params:
        window_size = config['n_windows'],
    shell:'''
    mkdir -p output/windowed_regions
    bedtools makewindows -b {input} \
    -n 100 -i winnum > {output}
    '''


rule window_regions_rev:
    conda:
        'envs/bedtools.yml'
    input:
        'output/windowed_regions/{region}.rev.bed'
    output:
        'output/windowed_regions/{region}.window.rev.bed'
    params:
        window_size = config['n_windows'],
    shell:'''
    mkdir -p output/windowed_regions
    bedtools makewindows -b {input} \
    -n 100 -i winnum -reverse > {output}
    '''


rule seperate_sample_strand_fwd:
    output:
        'output/samples/{sample_name}.fwd.bed'
    params:
        sample_file = lambda wildcards: SAMPLES.loc[wildcards.sample_name]['filepath']
    shell:'''
    awk '$6 == "+" {{print $0}}' {params.sample_file} > {output}
    '''


rule seperate_sample_strand_rev:
    output:
        'output/samples/{sample_name}.rev.bed'
    params:
        sample_file = lambda wildcards: SAMPLES.loc[wildcards.sample_name]['filepath']
    shell:'''
    awk '$6 == "-" {{print $0}}' {params.sample_file} > {output}
    '''


rule sort_sample_strands:
    input:
        'output/samples/{sample_name}.{strand}.bed'
    output:
        'output/samples/{sample_name}.{strand}.sorted.bed'
    shell:'''
    sort -k 1,1 -k2,2n {input} > {output}
    '''


rule sort_windowed_region_file:
    input:
        'output/windowed_regions/{region}.window.{strand}.bed'
    output:
        'output/windowed_regions/{region}.window.{strand}.sorted.bed'
    shell:'''
    sort -k 1,1 -k2,2n {input} > {output}
    '''


rule window_coverage_bed:
    conda:
        'envs/bedtools.yml'
    input:
        sample='output/samples/{sample_name}.{strand}.sorted.bed',
        windows='output/windowed_regions/{region}.window.{strand}.sorted.bed'

    output:
        'output/window_coverage/{region}.{sample_name}.{strand}.coverage.bed'
    shell:'''
    mkdir -p output/window_coverage
    bedtools coverage -sorted -a {input.windows} -b {input.sample} -counts > {output}
    '''


rule combine_coverage_strands:
    input:
        fwd='output/window_coverage/{region}.{sample_name}.fwd.coverage.bed',
        rev='output/window_coverage/{region}.{sample_name}.rev.coverage.bed'
    output:
        'output/window_coverage/{region}.{sample_name}.all.coverage.bed'
    shell:'''
    cat {input.fwd} {input.rev} > {output}
    '''


rule sort_coverage_bedgraph_by_window_num:
    input:
        'output/window_coverage/{region}.{sample_name}.all.coverage.bed'
    output:
        'output/window_coverage/{region}.{sample_name}.all.coverage.sorted.bed'
    shell:'''
    sort -k 1,1 -k2,2n {input} > {output}
    '''


rule average_coverage_by_window:
    conda: 
        'envs/bedtools.yml'
    input:
        'output/window_coverage/{region}.{sample_name}.all.coverage.sorted.bed'
    output:
        'output/average_coverage/{region}.{sample_name}.avg.tsv'
    shell:'''
    bedtools groupby -i {input} -g 4 -c 5 -o mean > {output}  && [[ -s {output} ]]
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


        


    

