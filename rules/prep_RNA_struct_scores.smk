# Download and process bedgraph files from GSE149018 RNA structure (double
# stranded ness) score calculations
import pandas as pd
from pathlib import Path


# ss_samples = pd.read_table(
#     'samples/RNAss_samples.tsv'
# ).set_index("sample_name", drop=False)

SAMPLE_DIR = str(Path(SAMPLES['filepath'].iloc[0]).parent)


rule download_processed_data_tar:
    output:
        compressed=temp('data/RNAss/GSE149018_processed_data_files.tar.gz'),
        RNAss_dir=directory(SAMPLE_DIR)
    shell:'''
    mkdir -p data/RNAss/
    wget -O {output.compressed} \
    "ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE149nnn/GSE149018/suppl/GSE149018%5Fprocessed%5Fdata%5Ffiles%2Etar%2Egz"
    tar -xf {output.compressed} -C {output.RNAss_dir}
    '''



rule touch_all_files:
    input:
        SAMPLE_DIR
    output:
        expand(
           SAMPLES['filepath'].tolist()
        )
