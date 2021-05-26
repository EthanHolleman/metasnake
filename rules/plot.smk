

def metaplot_basic_input(*args, **kwargs):
    '''Specifies input files for make_metaplot rule in a way that is aware
    of the sample files original file extension. This avoids confusing
    bed and bedgraph input sample files.
    '''
    return expand(
        'output/window_coverage/{region_name}.{sample_name}.all_stats.tsv',
        sample_name=set(SAMPLE_NAMES), region_name=set(REGION_NAMES)
    )


rule make_bin_heatmap:
    conda:
        '../envs/R.yml'
    input:
        'output/window_coverage/{region_name}.{sample_name}.all.coverage.bedgraph'
    output:
        'output/plots/{run_name}/{region_name}.{sample_name}.heatmap.pdf'
    script:'../scripts/regions_heatmap.R'


rule make_coverage_plots:
    conda:
        '../envs/chipseeker_a.yml'
    input:
        pre_cut='output/window_coverage/{region_name}.{sample_name}.all.no_coverage.bedgraph',
        post_cut='output/window_coverage/{region_name}.{sample_name}.all.coverage.bedgraph'
    output:
        'output/plots/{run_name}/{region_name}.{sample_name}.coverage_loss.pdf'
    script:'../scripts/plot_coverage.R'



rule make_metaplots_basic:
    conda:
        '../envs/R.yml'
    input:
        lambda wildcards: metaplot_basic_input()
    output:
        'output/plots/{run_name}/{run_name}.metaplot.basic.pdf'
    script:'../scripts/metaplot_basic.R'



rule make_coverage_dist_plot:
    conda:
        '../envs/R.yml'
    input:
        expand(
            'output/window_coverage/{region}.{sample_name}.all.coverage.bed',
            region=REGIONS['region_name'].tolist(),
            sample_name=SAMPLES['sample_name'].tolist()
        )
    output:
        'output/plots/{run_name}.overlap_count_dist.png'
    script:'../scripts/overlap_dist.R'


rule make_fisher_plots:
    conda:
        '../envs/R.yml'
    input:
        'output/fisher/tests/all_fischer_files.tsv'
    output:
        'output/plots/{run_name}.fisher.png'
    script:'../scripts/fisher_test_plots.R'
    