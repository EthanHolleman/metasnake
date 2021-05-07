rule make_metaplots:
    conda:
        '../envs/R.yml'
    input:
        expand(
            'output/average_coverage/{region}.{sample_name}.avg.tsv',
            region=REGIONS.index.values.tolist(),
            sample_name=SAMPLES.index.values.tolist()
            )
    output:
        'output/metaplot.png'
    script:"../scripts/metaplot.R"