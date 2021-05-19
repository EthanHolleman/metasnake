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
        compressed=temp('GSE149018_processed_data_files.tar.gz'),
        uncompressed='data/RNAss/done.txt'
    shell:'''
    rm -rf data/RNAss/
    mkdir -p data/RNAss/
    cd data/RNAss/
    wget -O {output.compressed} \
    "ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE149nnn/GSE149018/suppl/GSE149018%5Fprocessed%5Fdata%5Ffiles%2Etar%2Egz"
    tar -xf {output.compressed}
    touch {output.uncompressed}
    '''
    

rule touch_all_files:
    input:
        'data/RNAss/done.txt'
    output:
        expand(
           SAMPLES['filepath'].tolist()
        )
