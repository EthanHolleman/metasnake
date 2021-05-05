# randomly sample the input sample
# to use as a test against later

rule random_regions:
    output:
        random_regions='output/random/random_{region}.{strand}.bed'