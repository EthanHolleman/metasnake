
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
        'output/windowed_regions/sym_links/{region_name}.{strand}.{bed_or_bedgraph}'
    params:
        region_file=lambda wildcards: REGIONS.loc[wildcards.region_name]['filepath']
    shell:'''
    mkdir -p output/windowed_regions/sym_links
    ln -sf {params.region_file} {output}
    '''

# just like samples assume regions to be bed6 (strands and scores) if
# # passed as bed files
# rule seperate_window_strands_fwd:
#     input:
#         'output/windowed_regions/sym_links/{region_name}.bed'
#     output:
#         'output/windowed_regions/stranded/{region_name}.fwd.bed' 
#     shell:'''
#     awk '$6 == "+" {{print $0}}' {input} > {output}
#     '''


# rule seperate_window_strands_rev:
#     input:
#         'output/windowed_regions/sym_links/{region_name}.bed'
#     output:
#         'output/windowed_regions/stranded/{region_name}.rev.bed'
#     shell:'''
#     awk '$6 == "-" {{print $0}}' {input} > {output}
#     '''
rule sort_regions:
    input:
        'output/windowed_regions/sym_links/{region_name}.{strand}.{bed_or_bedgraph}'
    output:
        'output/windowed_regions/sorted/{region_name}.{strand}.sorted.{bed_or_bedgraph}'
    shell:'''
    sort -k 1,1 {input} > {output}
    '''


rule convert_bed_regions_to_bedgraph:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/sorted/{region_name}.{strand}.sorted.bed'
    output:
        'output/windowed_regions/sorted/{region_name}.{strand}.sorted.bedgraph'
    params:
        genome=config['genome']
    shell:'''
    bedtools genomecov -bg -g {params.genome} -i {input} > {output}
    '''


rule window_bedgraph_regions_fwd:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/sorted/{region_name}.fwd.sorted.bedgraph'
    output:
        'output/windowed_regions/windows/{region_name}.fwd.window.bedgraph'
    params:
        window_size = config['n_windows'],
    shell:'''
    mkdir -p output/windowed_regions
    bedtools makewindows -b {input} \
    -n 100 -i winnum > {output}
    '''

# treat all regions as fwd
rule window_bedgraph_regions_fwd:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/sorted/{region_name}.all.sorted.bedgraph'
    output:
        'output/windowed_regions/windows/{region_name}.all.window.bedgraph'
    params:
        window_size = config['n_windows'],
    shell:'''
    mkdir -p output/windowed_regions
    bedtools makewindows -b {input} \
    -n 100 -i winnum > {output}
    '''


rule window_bedgraph_regions_rev:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/sorted/{region_name}.rev.sorted.bedgraph'
    output:
        'output/windowed_regions/windows/{region_name}.rev.window.bedgraph'
    params:
        window_size = config['n_windows'],
    shell:'''
    mkdir -p output/windowed_regions
    bedtools makewindows -b {input} \
    -n 100 -i winnum -reverse > {output}
    '''


rule sort_windowed_region_file:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/windows/{region_name}.{strand}.window.bedgraph'
    output:
        'output/windowed_regions/windows/{region_name}.{strand}.window.sorted.bedgraph'
    shell:'''
    sort -k1,1 -k2,2n {input} > {output}
    '''


rule window_coverage_bedgraph:

    conda:
        '../envs/bedtools.yml'
    input:
        windows='output/windowed_regions/windows/{region_name}.{strand}.window.sorted.bedgraph',
        sample='output/samples/bed_to_bedgraph/{sample_name}.{strand}.sorted.bedgraph'
    output:
        'output/window_coverage/{region_name}.{sample_name}.{strand}.coverage.bedgraph'
    shell:'''
    bedtools map -a {input.windows} -b {input.sample} -null "0" -c 4 -o sum > {output} 
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