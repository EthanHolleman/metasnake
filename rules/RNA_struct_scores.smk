# Download and process bedgraph files from GSE149018 RNA structure (double
# stranded ness) score calculations
import pandas as pd


ss_samples = pd.read_table(
    'samples/RNAss_samples.tsv'
)


rule download_processed_data_tar:
    output:
        compressed=temp('data/RNAss/GSE149018_processed_data_files.tar.gz'),
        RNAss_dir=directory('data/RNAss')
    shell:'''
    mkdir -p data/RNAss/
    wget -O {output.compressed} \
    "ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE149nnn/GSE149018/suppl/GSE149018%5Fprocessed%5Fdata%5Ffiles%2Etar%2Egz"
    tar -xf {output.compressed} -C {output.RNAss_dir}
    '''
    

rule convert_wt_stranded_bedgraphs_to_bed:
    # want to convert bedgraph 
    output:
        'data/RNAss/{sample}.{strand}.bed'
    params:
        input_file=lambda wildcards: ss_samples.loc[
            (ss_samples['sample_name'] == 'ssR749H' ) & (ss_samples['strand'] == 'fwd')
            ]['filename'][0],
        strand_char=lambda wildcards: '+' if wildcards.strand == 'fwd' else '-',
        sample_name = lambda wildcards: wildcards.sample
    shell:'''
    awk '{{print $1 "\t" $2 "\t" $3 "\t" "{params.sample_name}_"NR "\t" $4 "\t" "{params.strand_char}"}}' \
    data/RNAss/{params.input_file} > {output}
    '''


rule convert_all_files:
    input:
        expand(
            'data/RNAss/{sample}.{strand}.bed',
            zip, sample=ss_samples['sample_name'].tolist(),
            strand=ss_samples['strand'].tolist()
        )
    output:
        'data/RNAss/convert_all.done'

