# Read in bedtools fisher test results and convert to tsv
# file for later plotting
# Example format from bedtools website

# # Number of query intervals: 3
# # Number of db intervals: 2
# # Number of overlaps: 2
# # Number of possible intervals (estimated): 37
# # phyper(2 - 1, 3, 37 - 3, 2, lower.tail=F)
# # Contingency Table Of Counts
# #_________________________________________
# #           |  in -b       | not in -b    |
# #     in -a | 2            | 1            |
# # not in -a | 0            | 34           |
# #_________________________________________
# # p-values for fisher's exact test
# left    right   two-tail    ratio
# 1   0.0045045   0.0045045   inf
from pathlib import Path

TABLE_START = 4

def get_sample_region_strand_names(filepath):
    sample_name = Path(filepath).stem.split('.')[0]
    region = Path(filepath).stem.split('.')[1]
    strand = Path(filepath).stem.split('.')[2]
    return sample_name, region, strand

def sample_region_strand_dict(sample, region, strand):
    return dict(zip(['sample', 'region', 'strand'], [sample.strip(), region.strip(), strand.strip()]))


def read_fisher(filepath):
    fisher_dict = {}
    with open(filepath) as handle:
        for i in range(TABLE_START):
            line = handle.readline()
            line = line[1:].strip() # remove comment #
            line = line.split(":")
            fisher_dict[line[0].replace(" ", "_")] = line[1]

        # read until lines are uncommented

        line = handle.readline()
        while line[0] == "#":
            line = handle.readline()


        variable_names = line.strip().split("\t")
        values = handle.readline().strip().split("\t")

        fisher_dict.update(dict(zip(variable_names, values)))
        fisher_dict.update(
            sample_region_strand_dict(*get_sample_region_strand_names(filepath))
            )

    return fisher_dict


def write_as_tsv(fisher_dict, output_path):
    with open(output_path, "w") as handle:
        header = "\t".join(fisher_dict.keys()) + "\n"
        row = "\t".join(fisher_dict.values())
        print(list(fisher_dict.values()))
        handle.write(header)
        handle.write(row)
    return output_path


def main():
    input_file = str(snakemake.input)
    output = str(snakemake.output)
    #input_file = 'output/fisher/tests/TEST_SAMPLE_0.TEST_REGION_2.fwd.ftest'
    #output = 'test.tsv'
    fisher_data = read_fisher(input_file)
    write_as_tsv(fisher_data, output)


if __name__ == "__main__":
    main()
