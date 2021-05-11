rule download_encode_hmm_hmec:
    output:
        'data/encodeChromHMM/wgEncodeBroadHmmHmecHMM.bed'
    params:
        download_link='http://hgdownload.soe.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeBroadHmm/wgEncodeBroadHmmHmecHMM.bed.gz'
    shell:'''
    mkdir -p data/encodeChromHMM
    curl -L {params.download_link} -o {output}.gz
    gzip -d {output}.gz
    '''



