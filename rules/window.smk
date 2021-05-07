
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