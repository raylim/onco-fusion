#!/bin/bash

# source DSA_USERNAME and DSA_PASSWORD
. dsa_env.txt

export DSA_API=https://tlvimskambari1/dsa/api/v1
export DSA_COLLECTION=MSK-SPECTRUM

export LUNA_HOME=/gpfs/mskmind_ess/limr/repos/luna

source /gpfs/mskmind_ess/limr/mambaforge/etc/profile.d/conda.sh
conda activate $LUNA_HOME/.venv/luna

for json in dsa_annotations/heatmap/*.json dsa_annotations/stardist_polygon/*.json; do
	json=dsa_annotations/stardist_polygon/oncofusion-cell_${filename%%.svs}.json

	dsa_upload $DSA_API \
	    --collection_name $DSA_COLLECTION \
	    --image_filename $filename \
	    --annotation_filepath $json
done
