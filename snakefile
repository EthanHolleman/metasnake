
import pandas as pd
from pathlib import Path

SAMPLES = pd.read_table(config['samples']).set_index("sample_name", drop=False)
REGIONS = pd.read_table(config['regions']).set_index("region_name", drop=False)
RUN_NAME = config['name']

wildcard_constraints:
   region = '\w+',
   sample_name = '\w+',
   strand = '\w+',
   bed_or_bedgraph = '\w+',
   fwd_rev_strand = '\bfwd\b|\brev\b'


include: 'rules/drip.smk'
include: 'rules/fisher_exact.smk'
include: 'rules/plot.smk'
include: 'rules/window.smk'
include: 'rules/average_windows.smk'
include: 'rules/samples.smk'
include: 'rules/prep_RNA_struct_scores.smk'
include: 'rules/prep_hg19_genes.smk'


METAPLOT = 'output/plots/{}.metaplot.png'.format(RUN_NAME)
# # These plots below are in progress
# FISHER_PLOT = 'output/plots/{}.fisher.png'.format(RUN_NAME)
# OVERLAP_DIST = 'output/plots/{}.overlap_count_dist.png'.format(RUN_NAME)

REGION_FILES = REGIONS['filepath'].tolist()
SAMPLE_FILES = SAMPLES['filepath'].tolist()
SAMPLE_NAMES = SAMPLES['sample_name'].tolist()
REGION_NAMES = REGIONS['region_name'].tolist()
STRAND = SAMPLES['strand'].tolist()

# Sample and/or region files may require additional processing to create
# the files that will actually go into the pipeline. This is the case for
# DRIPc data I used which needed to be converted from wig to bed format.
# This is accomplished by adding an additional file to the samples folder
# which specifies paths to the precursor files. Then create a new smk file
# with rules that define how to make the files specified by either the
# samples or regions tsv which are given in the config file. That way
# when these filepaths are given to rule all, they can be generated from the
# precursor files if they do not already exist. 

rule all:
    input:
      regions=REGION_FILES,  # check if any region or sample files need prep
      samples=SAMPLE_FILES,
      plots=[METAPLOT]



    

