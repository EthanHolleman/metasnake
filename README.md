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

The pipeline relies on three input files; two tsv files, one describing
sample locations and the other region locations (genes, promoters etc.) and
a config.yml file to tie everything together

### Config.yml

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

### Samples .tsv

This should be a two column tsv file with column names `sample name` and
`filepath`. `sample_name` is the name of the same (no file extensions
this can confuse snakemake) and filepath is the abosolute path to the
sample file (bed or bedgraph). Path needs to ve absolute to avoid issues
with symbolic linking.

Example 

```
sample_name	filepath
GSM3939125	/home/ethollem/projects/GSM3939125.bed
```

### Regions .tsv

Very similar to the samples tsv file but defines the regions of interest
that metaplots are created from. This could be genes, promoters, etc.
Also a two column tsv file but with headers `region_name` and `filepath`. Same idea with these as in the samples tsv file.

Example

```
region_name	filepath
hg19_genes	/home/ethollem/projects/data/hg19/hg19_apprisplus_gene.bed
```



