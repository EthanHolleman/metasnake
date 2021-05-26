# metasnake

Snakemake pipeline for creating metaplots of intersecting genomic data
specified in `bed` and `bedgraph` files. 

## Requirements 

The pipeline depends on having snakemake and conda available. See the
[Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)
installation documentation foe help with this. All other software dependencies
will be installed when the pipeline is first run as long as the `--use-conda`
flag is added to the `snakemake` call.

## Inputs

### Configuration

The pipeline relies on three input files; two tsv files, one describing
sample locations and the other region locations (genes, promoters etc.) and a config.yml file to tie everything together.


#### Config.yml

Should include the following terms

- samples: Path to samples tsv file relative to where you will run snakemake from
- regions: Path to regions tsv file relative to where you will run snakemake from
- n_windows: Number of equal size windows to divide each region into (number of bins)
- cluster_file: Path to a yml file defining cluster execution configuration relative to where you will run snakemake from
- genome: Genome size file for genome your regions are in relative to where you run snakemake from
- name: Name of the run, should be unique.

Example

```
samples: "runs/DRIP_against_hg19_genes/samples.tsv"
regions: "runs/DRIP_against_hg19_genes/regions.tsv"
n_windows: 100
cluster_file: "cluster.yml"
genome: "data/hg19/hg19.chrom.sizes"
name: "DRIPc_hg19_genes"
```

#### Samples .tsv

This should be a two column tsv file with column names `sample name`,
`filepath`, `operation` and `null_val`. Each filepath should be unique and a row should be uniquely identifiable through the combination of the
`sample_name` and `strand` columns. 

- `sample_name`: The name of the sample (no file extensions
this can confuse snakemake)
- `filename`: Path to the file that will be used as input for the sample
- `strand`: Strand of the regions in the file specified by `filename`. Can either be `fwd` or `rev`. 
- `operation`: The mathematical operation that should be used to summarize
    values that map to each bin. This can be any operation allowed by
    [bedtools map](https://bedtools.readthedocs.io/en/latest/content/tools/map.html). For samples who's value is read count or something equivalent then `sum` is recommended as the final result will be the mean of read count over each bin. However, if sample files have
    values that themselves are a statistic `mean` is recommended. This is because adding statistics together may or may not be meaningful.
- `null_val`: There are likely to be cases where there is no coverage for a given region. In some cases it might make sense to include these regions in calculations as 0 and in other cases it would be better to exclude these regions entirely. `null_val` column allows you to specify this behavior; whatever value is entered here will be passed to the `-null` argument or bedtools map. To exclude regions from downstream calculations set this value to `NC`.


#### Regions .tsv

Very similar to the samples tsv file but defines the regions of interest
that metaplots are created from. This could be genes, promoters, etc.
Also a two column tsv file but with headers `region_name`, `filepath` and `strand`. Same idea with these as in the samples tsv file.

Example

```
region_name	filepath
hg19_genes	/home/ethollem/projects/data/hg19/hg19_apprisplus_gene.bed
```

### Data files

Currently all input data must be specified in bedgraph format with
one file per strand for each sample or region. If a file requires
preprocessing to produce this format, it is recommended to create a new
snakemake rule file to produce the desired final output. This final output
can then be specified in either your `regions.tsv` or `samples.tsv` files
and the pipeline will generate that input before getting into metaplot related work.



