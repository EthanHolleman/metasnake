# For testing metaplot creation
# Generate bed files of random regions and samples
# which will have 100 "reads" mapped to each feature in
# the regions. This should produce flat metaplot curves
import random
from pathlib import Path
import pandas as pd

CHRS = [f'chr{name}' for name in list(range(1, 23)) + ['X', 'Y']]
MEAN_LEN = 4000
SD = 2000
NUM_FEATS = 10000
CHR_LEN = 248956422  # len chr1 hg19
OBS_PER_FEAT = 10
NUM_REGIONS = 4
NUM_SAMPLES = 4
OUTPUT_DIR = 'test_beds'

def random_region():
   
    features = []
    for i in range(num_features):
        chromo = random.choice(CHRS)
        start = random.randint(0, CHR_LEN)
        end = start + np.random.normal(MEAN_LEN, SD)
        strand = random.choice(['-', '+'])
        features.append(
            (
                chromo,  # chromosome
                start,   # start pos
                end,     # end pos
                i        # name (index)
                0        # score placeholder
                strand   # strand
            )
        )
    return features


def random_sample_from_regions(regions):
    sample_obs = []
    for each_region in regions:
        for each_feature in each_region:
            for i in range(OBS_PER_FEAT)
                chromo, start, end, name, score, strand = feature
                obs_start = random.randint(start, end)
                obs_end = random.randint(obs_start, end)
                sample_obs.append(
                    (chromo, obs_start, obs_end, name, score, strand)
                )
    return sample_obs


def write_list_to_bed(tuple_list, path):
    bed_df = pd.DataFrame(tuple_list)
    bed_df.to_csv(str(path), sep='\t', header=False, index=False)


def make_sample_tsv(sample_paths):
    sample_names = [Path(sample).name for sample in sample_paths]
    pd.DataFrame([
        
    ])


def main():
    if not Path(OUTPUT_DIR).is_dir():
        Path(OUTPUT_DIR).mkdir()
    
    sample_paths = []
    region_paths= []
    region_features = []
    
    for i in range(NUM_REGIONS):
        region_path = str(Path(OUTPUT_DIR).joinpath(f'TEST_REGION_{i}.bed'))
        region = random_region()
        write_list_to_bed(region, region_path)
        regions.append(region_path)
        region_features.append(region)

    for j in range(NUM_SAMPLES):
        sample_path = str(Path(OUTPUT_DIR).joinpath(f'TEST_SAMPLE_{j}.bed'))
        sample = random_sample_from_regions(region_features)
        write_list_to_bed(sample_path)
        samples.append(sample_path)


        
    






        
    