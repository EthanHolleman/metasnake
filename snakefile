
import pandas as pd
from pathlib import Path

SAMPLES = pd.read_table(config['samples']).set_index("sample_name", drop=False)
REGIONS = pd.read_table(config['regions']).set_index("region_name", drop=False)

wildcard_constraints:
   region = '\w+',
   sample_name = '\w+',
   strand = '\w+'


include: 'rules/drip.smk'
include: 'rules/fisher_exact.smk'
include: 'rules/plot.smk'
include: 'rules/window.smk'

rule all:
    input:
        # 'output/metaplot.png',
        # 'data/DRIP/DRIPc.sorted.bed',
        'output/fisher/tests/all_fischer_files.tsv'
        


    

