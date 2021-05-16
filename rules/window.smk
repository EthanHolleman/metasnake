
REGION_NAMES = REGIONS['region_name'].tolist()
REGION_FILE_EXT = [Path(REGIONS.loc[region_name]['filepath']).suffix.replace('.', '') 
            for region_name in REGION_NAMES]


# BED_REGIONS, BEDGRAPH_REGIONS = [], []
# for rn, ext in zip(REGION_NAMES, REGION_FILE_EXT):
#     if ext == 'bed':
#         BED_REGIONS.append(rn)
#     else:
#         BEDGRAPH_REGIONS.append(rn)



rule sym_link_region_bed:
    output:
        'output/windowed_regions/sym_links/{region_name}.{strand}.bedgraph'
    params:
        region_file=lambda wildcards: REGIONS.loc[wildcards.region_name]['filepath']
    shell:'''
    mkdir -p output/windowed_regions/sym_links
    ln -sf {params.region_file} {output}
    '''


rule seperate_fwd_from_combined_stranded_regions:
    # allows input to be provided that has both strands. Strand in the
    # regions file should be set to both. Since has the strand assume
    # to be bed6 formated
    input:
        'output/windowed_regions/sym_links/{region_name}.both.bed'
    output:
        'output/windowed_regions/sep_bed/{region_name}.fwd.bed'
    shell:'''
    awk '$6 == "+" {{print $0}}' {input} > {output}
    '''

# rule seperate_rev_from_combined_stranded_regions:
#     # allows input to be provided that has both strands. Strand in the
#     # regions file should be set to both. Since has the strand assume
#     # to be bed6 formated
#     input:
#         'output/windowed_regions/sym_links/{region_name}.both.bed'
#     output:
#         'output/windowed_regions/sep_bed/{region_name}.rev.bed'
#     shell:'''
#     awk '$6 == "-" {{print $0}}' {input} > {output}
#     '''


# rule convert_bed_regions_to_bedgraph_fwd:
#     conda:
#         '../envs/bedtools.yml'
#     input:
#         'output/windowed_regions/sep_bed/{region_name}.fwd.bed'
#     output:
#         sorted_bed='output/windowed_regions/sorted/{region_name}.fwd.sorted.bed',
#         bedgraph='output/windowed_regions/bedgraph/{region_name}.fwd.sorted.bed.bedgraph'
#     params:
#         genome=config['genome']
#     shell:'''
#     sort -k 1,1 {input} > {output.sorted_bed}
#     bedtools genomecov -bg -g {params.genome} -i {input} > {output}
#     '''


# rule convert_bed_regions_to_bedgraph_rev:
#     conda:
#         '../envs/bedtools.yml'
#     input:
#         'output/windowed_regions/sep_bed/{region_name}.rev.bed'
#     output:
#         sorted_bed='output/windowed_regions/convert_sorted/{region_name}.rev.sorted.bed',
#         bedgraph='output/windowed_regions/bedgraph/{region_name}.rev.sorted.bed.bedgraph'
#     params:
#         genome=config['genome']
#     shell:'''
#     sort -k 1,1 {input} > {output.sorted_bed}
#     bedtools genomecov -bg -g {params.genome} -i {input} > {output}
#     '''


rule sort_bedgraph_inputs:
    input:
        'output/windowed_regions/sym_links/{region_name}.{strand}.bedgraph'
    output:
        'output/windowed_regions/sorted/{region_name}.{strand}.sorted.bedgraph'
    shell:'''
    sort -k 1,1 -k2,2n {input} > {output}
    '''


rule make_window_regions:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/sorted/{region_name}.{strand}.sorted.bedgraph'
    output:
        'output/windowed_regions/windows/{region_name}.{strand}.bedgraph'
    params:
        window_size = config['n_windows'],
        reverse_winnums = lambda wildcards: '-reverse' if (wildcards.strand == 'rev') else ''
    shell:'''
    mkdir -p output/windowed_regions
    bedtools makewindows -b {input} \
    -n 100 -i winnum {params.reverse_winnums} > {output}
    '''


rule sort_windowed_region_file:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/windowed_regions/windows/{region_name}.{strand}.bedgraph'
    output:
        'output/windowed_regions/windows/{region_name}.{strand}.sorted.bedgraph'
    shell:'''
    sort -k1,1 -k2,2n {input} > {output}
    '''


rule window_coverage_bedgraph:
    conda:
        '../envs/bedtools.yml'
    input:
        windows='output/windowed_regions/windows/{region_name}.{strand}.sorted.bedgraph',
        sample='output/samples/{sample_name}.{strand}.sorted.bedgraph'
    output:
        'output/window_coverage/{region_name}.{sample_name}.{strand}.coverage.bedgraph'
    shell:'''
    bedtools map -a {input.windows} -b {input.sample} -null "0" -c 4 -o sum > {output} 
    '''


rule window_coverage_all_samples:
    input:
        expand(
            'output/window_coverage/{region_name}.{sample_name}.{strand}.coverage.bedgraph',
            zip, sample_name=SAMPLES.index.tolist(), strand=SAMPLES['strand'].tolist(),
            region_name=REGION_NAMES
        )
    output:
        'bigdone.txt'
    shell:'''
    touch bigdone.txt
    '''

# rule combine_coverage_strands:
#     input:
#         fwd='output/window_coverage/{region_name}.{sample_name}.fwd.coverage.bedgraph',
#         rev='output/window_coverage/{region_name}.{sample_name}.rev.coverage.bedgraph'
#     output:
#         'output/window_coverage/{region_name}.{sample_name}.all.coverage.bed'
#     shell:'''
#     cut -b 1- {input.fwd} {input.rev} > {output}
#     '''