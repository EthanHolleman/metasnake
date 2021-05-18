# For testing metaplot creation
# Generate bed files of random regions and samples
# which will have 100 "reads" mapped to each feature in
# the regions. This should produce flat metaplot curves
import random
from pathlib import Path
import pandas as pd
import numpy as np

CHRS = [f"chr{name}" for name in list(range(1, 3))]
MEAN_LEN = 4000
SD = 0
NUM_FEATS = 10
CHR_LEN = 1e6
OBS_PER_FEAT = 1000
NUM_REGIONS = 2
NUM_SAMPLES = 2
OUTPUT_DIR = "test_beds"


def random_region():
    '''Generate a number of random regions (these would be equal
    to genes or similar) for testing. 

    Returns:
        list: List of tuples describing regions in bed6.
    '''

    features = []
    for i in range(NUM_FEATS):
        chromo = random.choice(CHRS)
        start = random.randint(0, CHR_LEN)
        #end = start + abs(int(np.random.normal(MEAN_LEN, SD))) + 1
        #end = start + random.randint(start+1, start+1+MEAN_LEN)
        end = start + MEAN_LEN
        strand = random.choice(["-", "+"])
        assert end > start, f"End position in region < start! {end - start}"
        features.append(
            (
                chromo,  # chromosome
                start,  # start pos
                end,  # end pos
                i,  # name (index)
                0,  # score placeholder
                strand,  # strand
            )
        )

    return features


def random_sample_from_regions(regions):
    '''
    '''
    sample_obs = []
    for each_region in regions:
        for each_feature in each_region:
            chromo, start, end, name, score, strand = each_feature
            for i in range(OBS_PER_FEAT):
                
                if strand == "+":
                    obs_start = random.randint(start+1, start+2)
                    obs_end = obs_start + 5
                else:
                    obs_start = end-5
                    obs_end = end - 1

                #obs_start = abs(int(np.random.normal(MEAN_LEN, SD))) + 1
                #obs_end = random.randint(obs_start+1, end)
                

                assert obs_start >= start and obs_end <= end, 'Observation outside feature!'
                assert obs_end > obs_start, f'End not greater than start! {obs_start} {obs_end}'

                sample_obs.append((chromo, obs_start, obs_end, name, score, strand))
    return sample_obs


def write_list_to_bed(tuple_list, path):
    bed_df = pd.DataFrame(tuple_list)
    bed_df.to_csv(str(path), sep="\t", header=False, index=False)


def make_sample_tsv(sample_paths):
    sample_names = [Path(sample).stem for sample in sample_paths]
    abs_paths = [Path(sample).absolute() for sample in sample_paths]
    output_path = Path(OUTPUT_DIR).joinpath('samples.tsv')
    pd.DataFrame(
        list(zip(sample_names, abs_paths)), columns=['sample_name', 'filepath']
        ).to_csv(str(output_path), sep='\t')
    
    return str(output_path)


def make_regions_tsv(region_paths):
    sample_names = [Path(sample).stem for sample in region_paths]
    abs_paths = [Path(sample).absolute() for sample in region_paths]
    output_path = Path(OUTPUT_DIR).joinpath('regions.tsv')
    pd.DataFrame(
        list(zip(sample_names, abs_paths)), columns=['region_name', 'filepath']
        ).to_csv(str(output_path), sep='\t')
    
    return str(output_path)


def make_config_file(samples_file, regions_file):
    config = f'''
samples: "{samples_file}"
regions: "{regions_file}"
n_windows: 100
cluster_file: "cluster.yml"
genome: "test_beds/hg19.chrom.sizes"
name: "test_metaploter"
'''
    config_path = Path(OUTPUT_DIR).joinpath('config.yml')
    with open(str(config_path), 'w') as handle:
        handle.write(config)

    return str(config_path)
    

def main():
    if not Path(OUTPUT_DIR).is_dir():
        Path(OUTPUT_DIR).mkdir()

    sample_paths = []
    region_paths = []
    region_features = []

    for i in range(NUM_REGIONS):
        region_path = str(Path(OUTPUT_DIR).joinpath(f"TEST_REGION_{i}.bed"))
        region = random_region()
        write_list_to_bed(region, region_path)
        region_paths.append(region_path)
        region_features.append(region)

    for j in range(NUM_SAMPLES):
        sample_path = str(Path(OUTPUT_DIR).joinpath(f"TEST_SAMPLE_{j}.bed"))
        sample = random_sample_from_regions(region_features)
        write_list_to_bed(sample, sample_path)
        sample_paths.append(sample_path)
    
    make_config_file(
        make_sample_tsv(sample_paths),
        make_regions_tsv(region_paths)
    )

    
    



if __name__ == "__main__":
    main()
