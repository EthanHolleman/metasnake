
REGION_NAMES = REGIONS['region_name'].tolist()
REGION_FILE_EXT = [Path(REGIONS.loc[region_name]['filepath']).suffix.replace('.', '') 
            for region_name in REGION_NAMES]


rule sym_link_all_regions:
    input:
        expand(
            'output/windowed_regions/sym_links/{region_name}.{bed_or_bedgraph}',
            zip, region_name=REGION_NAMES, bed_or_bedgraph=REGION_FILE_EXT
        )


rule sym_link_region:
    output:
        'output/windowed_regions/sym_links/{region_name}.{bed_or_bedgraph}'
    params:
        region_file=lambda wildcards: REGIONS.loc[wildcards.region_name]['filepath']
    shell:'''
    ln -s {params.region_file} {output}
    '''

# just like samples assume regions to be bed6 (strands and scores) if
# passed as bed files
rule seperate_window_strands_fwd:
    input:
        'output/windowed_regions/sym_links/{region_name}.bed'
    output:
        'output/windowed_regions/stranded/{region_name}.fwd.bed' 
    shell:'''
    awk '$6 == "+" {{print $0}}' {input} > {output}
    '''


rule seperate_window_strands_rev:
    input:
        'output/windowed_regions/sym_links/{region_name}.bed'
    output:
        'output/windowed_regions/stranded/{region_name}.rev.bed'
    shell:'''
    awk '$6 == "-" {{print $0}}' {input} > {output}
    '''


rule window_regions_fwd_bed:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/stranded/{region_name}.fwd.bed'
    output:
        'output/windowed_regions/stranded_windows/{region_name}.window.fwd.bed'
    params:
        window_size = config['n_windows'],
    shell:'''
    mkdir -p output/windowed_regions
    bedtools makewindows -b {input} \
    -n 100 -i winnum > {output}
    '''


rule window_regions_rev_bed:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/stranded/{region_name}.rev.bed'
    output:
        'output/windowed_regions/stranded_windows/{region_name}.window.rev.bed'
    params:
        window_size = config['n_windows'],
    shell:'''
    mkdir -p output/windowed_regions
    bedtools makewindows -b {input} \
    -n 100 -i winnum -reverse > {output}
    '''


rule window_regions_bedgraph:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/sym_links/{region_name}.bedgraph'
    output:
        'output/windowed_regions/bedgraph_regions/{region_name}.window.bedgraph'
    shell:'''
    mkdir -p output/windowed_regions/bedgraph_regions
    bedtools makewindows -b {input} \
    -n 100 -i winnum > {output}
    '''


rule sort_windowed_bed_region_file:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/stranded_windows/{region}.window.{strand}.bed'
    output:
        'output/windowed_regions/stranded_windows/{region}.window.{strand}.sorted.bed'
    shell:'''
    sort -k1,1 -k2,2n {input} > {output}
    '''


rule sort_windowed_bedgraph_region_file:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/bedgraph_regions/{region_name}.window.bedgraph'
    output:
        'output/windowed_regions/bedgraph_regions/{region_name}.window.sorted.bedgraph'
    shell:'''
    sort -k1,1 -k2,2n {input} > {output}
    '''


rule window_coverage_bed:
    conda:
        '../envs/bedtools.yml'
    input:
        windows='output/windowed_regions/stranded_windows/{region}.window.{strand}.sorted.bed',
        sample='output/samples/sorted_bed/{sample_name}.{strand}.sorted.bed'
    output:
        'output/window_coverage/{region}.{sample_name}.{strand}.coverage.bed'
    shell:'''
    mkdir -p output/window_coverage
    bedtools coverage -sorted -a {input.windows} -b {input.sample} -counts > {output}
    '''


rule window_coverage_bedgraph:
    # handle samples given as bedgraph input. This requires bedtools map since
    # one line will represent up to n number of "reads" instead of the one
    # to one relationship for regular bed files. So we take the sum of
    # the scores of bedgraph locations that overlap window intervals. 
    # STILL NEEDS WORK:
    # Need a way to recognize the input files read from tsv are bed vs
    # bedgraph
    conda:
        '../envs/bedtools.yml'
    input:
        windows='output/windowed_regions/bedgraph_regions/{region_name}.window.sorted.bedgraph',
        sample='output/samples/sorted_bedgraph/{sample_name}.sorted.bedgraph'
    output:
        'output/window_coverage/{region}.{sample_name}.coverage.bedgraph'
    shell:'''
    bedtools map -a {input.windows} -b {input.sample} -c 4 -o sum > {output} 
    '''


rule combine_coverage_strands:
    input:
        fwd='output/window_coverage/{region}.{sample_name}.fwd.coverage.bed',
        rev='output/window_coverage/{region}.{sample_name}.rev.coverage.bed'
    output:
        'output/window_coverage/{region}.{sample_name}.all.coverage.bed'
    shell:'''
    cut -b 1- {input.fwd} {input.rev} > {output}
    '''