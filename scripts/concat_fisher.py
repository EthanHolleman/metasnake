# Concatenate processed fisher files into one tsv file
# that can easily be read by R as a dataframe


def concatenate(filepaths, output_path):
    ref_header = []
    with open(output_path, "w") as handle:
        for i, fp in enumerate(filepaths):
            with open(fp) as fp_handle:
                content = fp_handle.readlines()
                assert len(content) == 2, "Content of f test file != 2 lines!"
                header = content[0]
                if i == 0:
                    ref_header = header
                    handle.write(header)
                    handle.write(content[1])
                else:
                    assert ref_header == header, "Headers do not match!"
                    handle.write('\n')
                    handle.write(content[1])
    return output_path


def main():
    input_files = list(snakemake.input)
    output_file = str(snakemake.output)
    written_output = concatenate(input_files, output_file)
    assert written_output == output_file


if __name__ == "__main__":
    main()
