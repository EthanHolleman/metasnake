# Read in bedtools fischer test results and convert to tsv
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

TABLE_START = 4


def read_fisher(filepath):
    fisher_dict = {}
    with open(filepath) as handle:
        for i in range(TABLE_START):
            line = handle.readline()
            line = line[1:].strip().replace(" ", "_")  # remove comment #
            line = line.split(":")
            fischer_dict[line[0]] = line[1]

        # read until lines are uncommented

        line = handle.readline()
        while line[0] == "#":
            line = line.readline()

        variable_names = line.strip().split("\t")
        values = handle.readline().split("\t")

        fischer_dict.update(dict(zip(variable_names, values)))

    return fischer_dict


def write_as_tsv(fischer_dict, output_path):
    with open(output_path, "w") as handle:
        header = "\t".join(fischer_dict.keys()) + "\n"
        row = "\t".join(fischer_dict.values())
        handle.write(header)
        handle.write(row)
    return output_path
