


rule make_window_regions:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/regions/{region_name}.{strand}.sorted.bedgraph'
    output:
        'output/windowed_regions/windows/{region_name}.{strand}.windowed.bedgraph'
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
        'output/windowed_regions/windows/{region_name}.{strand}.windowed.bedgraph'
    output:
        'output/windowed_regions/windows/{region_name}.{strand}.windowed.sorted.bedgraph'
    shell:'''
    sort -k1,1 -k2,2n {input} > {output}
    '''


rule window_coverage_bedgraph:
    # Calculate summary statistic for windowed regions using bedtools map.
    # Map will collect regions by their number and then apply the operation
    # specified in the sample.tsv file for that sample. If creating a metaplot
    # of something along the lines of "reads" then a sum op should be used
    # because this results in final output being average number of "reads"
    # at that window number. However if the input data is itself already some
    # kind of statistic it makes more sense to use a mean operation since
    # the sum of the statistics may or may not be meaningful.
    # The null val parameter is also important as this is used when there is no
    # "coverage" for a given region spefied by the sample file. Setting this
    # to "NC" in the sample.tsv file will throw out these no coverage region.
    # Another plausible case would to be to set this value to 0 to include these
    # regions in metaplot calculations. However, if a non-NC value is used it
    # must be an integer.
    conda:
        '../envs/bedtools.yml'
    input:
        windows='output/windowed_regions/windows/{region_name}.{strand}.windowed.sorted.bedgraph',
        sample='output/samples/{sample_name}.{strand}.sorted.bedgraph'
    output:
        'output/window_coverage/coverage/{region_name}.{sample_name}.{strand}.coverage.bedgraph'
    params:
        operation = lambda wildcards: SAMPLES.loc[
            f'{wildcards.sample_name}{wildcards.strand}', 'operation'
            ],
        null_val = lambda wildcards: SAMPLES.loc[
            f'{wildcards.sample_name}{wildcards.strand}', 'null_val'
            ]
    shell:'''
    bedtools map -a {input.windows} -b {input.sample} -null "{params.null_val}" \
    -c 4 -o {params.operation} > {output} 
    '''


rule remove_no_coverage_regions:
    input:
        'output/window_coverage/coverage/{region_name}.{sample_name}.{strand}.coverage.bedgraph'
    output:
        'output/window_coverage/coverage/{region_name}.{sample_name}.{strand}.coverage.cov.bedgraph'
    shell:'''
    awk '$5 != "NC" {{print $0}}' {input} > {output}
    '''


rule combine_coverage_strands:
    input:
        fwd='output/window_coverage/coverage/{region_name}.{sample_name}.fwd.coverage.cov.bedgraph',
        rev='output/window_coverage/coverage/{region_name}.{sample_name}.rev.coverage.cov.bedgraph'
    output:
        'output/window_coverage/{region_name}.{sample_name}.all.coverage.bedgraph'
    shell:'''
    cut -b 1- {input.fwd} {input.rev} > {output}
    '''


rule combine_coverage_strands_include_no_coverage:
    input:
        fwd='output/window_coverage/coverage/{region_name}.{sample_name}.fwd.coverage.bedgraph',
        rev='output/window_coverage/coverage/{region_name}.{sample_name}.rev.coverage.bedgraph'
    output:
        'output/window_coverage/{region_name}.{sample_name}.all.no_coverage.bedgraph'
    shell:'''
    cut -b 1- {input.fwd} {input.rev} > {output}
    '''


rule sort_coverage_for_groupby:
    # sort by window number
    input:
        'output/window_coverage/{region_name}.{sample_name}.all.coverage.bedgraph'
    output:
        'output/window_coverage/{region_name}.{sample_name}.all.coverage.sorted.bedgraph'
    shell:'''
    sort -k4,4 {input} > {output}
    '''


rule group_bins_mean:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/window_coverage/{region_name}.{sample_name}.all.coverage.sorted.bedgraph'
    output:
        'output/window_coverage/{region_name}.{sample_name}.all.grouped.mean.tsv'
    shell:'''
    bedtools groupby -i {input} -g 4 -o mean -c 5 > {output} && [[ -s {output} ]]
    '''


rule group_bins_sd:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/window_coverage/{region_name}.{sample_name}.all.coverage.sorted.bedgraph'
    output:
        'output/window_coverage/{region_name}.{sample_name}.all.grouped.sd.tsv'
    shell:'''
    bedtools groupby -i {input} -g 4 -o stdev -c 5 > {output} && [[ -s {output} ]]
    '''


rule group_bins_count:
    conda:
        '../envs/bedtools.yml'
    input:
        'output/window_coverage/{region_name}.{sample_name}.all.coverage.sorted.bedgraph'
    output:
        'output/window_coverage/{region_name}.{sample_name}.all.grouped.count.tsv'
    shell:'''
    bedtools groupby -i {input} -g 4 -o count -c 5 > {output} && [[ -s {output} ]]
    '''


rule combine_mean_sd_count_groups:
    input:
        mean='output/window_coverage/{region_name}.{sample_name}.all.grouped.mean.tsv',
        sd='output/window_coverage/{region_name}.{sample_name}.all.grouped.sd.tsv',
        item_count='output/window_coverage/{region_name}.{sample_name}.all.grouped.count.tsv'
    output:
        'output/window_coverage/{region_name}.{sample_name}.all_stats.tsv'
    shell:'''
    paste {input.mean} {input.sd} {input.item_count} | cut -f 1,2,4,6 > {output}
    # columns should be bin, mean, ds and count
    '''
    






rule window_coverage_all_samples:
    input:
        expand(
            'output/window_coverage/{region_name}.{sample_name}.all.coverage.bedgraph',
            zip, sample_name=SAMPLES.index.tolist(),
            region_name=REGIONS.index.tolist()
        )
    output:
        'output/window_coverage/window_coverage_all_samples.done'
    shell:'''
    touch {output}
    '''





# rule seperate_fwd_from_combined_stranded_regions:
#     # allows input to be provided that has both strands. Strand in the
#     # regions file should be set to both. Since has the strand assume
#     # to be bed6 formated
#     input:
#         'output/windowed_regions/sym_links/{region_name}.both.bed'
#     output:
#         'output/windowed_regions/sep_bed/{region_name}.fwd.bed'
#     shell:'''
#     awk '$6 == "+" {{print $0}}' {input} > {output}
#     '''

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


