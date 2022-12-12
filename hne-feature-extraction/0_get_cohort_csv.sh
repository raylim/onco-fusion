#!/bin/bash
source /gpfs/mskmind_ess/limr/mambaforge/etc/profile.d/conda.sh
conda activate transformer

python connector.py ../data/dataframes/hne_df.csv
