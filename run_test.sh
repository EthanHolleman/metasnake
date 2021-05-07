
#!/bin/bash -l

mkdir -p logs
source ~/anaconda3/etc/profile.d/conda.sh
conda activate snakemake
python test/rand_feats_samples.py
snakemake -j 14 -s snakefile --cluster-config cluster.yml \
--cluster "sbatch -p {cluster.partition} -t {cluster.time} -N {cluster.nodes} \
-n {cluster.cpus} --mem {cluster.mem} -J {cluster.name} -o {cluster.output} \
-e {cluster.output} --mail-type ALL --mail-user {cluster.email}" \
--conda-frontend=mamba \
--latency-wait 100 --verbose --use-conda --rerun-incomplete \
--configfile test_beds/config.yml