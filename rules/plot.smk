
def metaplot_input(*args, **kwargs):
    '''Specifies input files for make_metaplot rule in a way that is aware
    of the sample files original file extension. This avoids confusing
    bed and bedgraph input sample files.
    '''
    return expand(
        'output/window_coverage/{region_name}.{sample_name}.all.coverage.bedgraph',
        sample_name=set(SAMPLE_NAMES), region_name=set(REGION_NAMES)
    )


rule make_metaplots:
    conda:
        '../envs/R.yml'
    input:
        lambda wildcards: metaplot_input()
    output:
        'output/plots/{run_name}.metaplot.png'
    script:"../scripts/metaplot.R"



rule make_coverage_dist_plot:
    conda:
        '../envs/R.yml'
    input:
        expand(
            'output/window_coverage/{region}.{sample_name}.all.coverage.bed',
            region=REGIONS.index.values.tolist(),
            sample_name=SAMPLES.index.values.tolist()
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
    