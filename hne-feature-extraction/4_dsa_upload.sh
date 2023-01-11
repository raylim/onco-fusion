#!/bin/bash

# source DSA_USERNAME and DSA_PASSWORD
. dsa_env.txt

export DSA_API=https://tlvimskambari1/dsa/api/v1
export DSA_COLLECTION=MSK-SPECTRUM

export SCALE_FACTOR=32
export TILE_SIZE=128
export MAGNIFICATION=20

export LUNA_HOME=$HOME/repos/luna

#export LUNA_HOME=/gpfs/mskmind_ess/limr/repos/luna

source /gpfs/mskmind_ess/limr/mambaforge/etc/profile.d/conda.sh
conda activate $LUNA_HOME/.venv/luna

filename=`basename $1`

sample_name=${filename%.svs}

#dsa bitmask-polygon '{"tumor": "bitmaps/tissue_type_classifier_weights/'${sample_name}'/Tumor.png", "stroma": "bitmaps/tissue_type_classifier_weights/'${sample_name}'/Stroma.png", "adipose": "bitmaps/tissue_type_classifier_weights/'${sample_name}'/Fat.png", "necrosis": "bitmaps/tissue_type_classifier_weights/'${sample_name}'/Necrosis.png" }' \
#    --annotation_name oncofusion-tissue \
#    --image_filename $filename \
#    --output_dir dsa_annotations/bitmask \
#    --line_colors '{"tumor": "rgb(255,0,0)", "stroma": "rgb(0,255,0)", "adipose": "rgb(0,0,255)", "necrosis": "rgb(255,0,255)"}' \
#    --fill_colors '{"tumor": "rgba(255,0,0,100)", "stroma": "rgba(0,255,0,100)", "adipose": "rgba(0,0,255,100)", "necrosis": "rgba(255,0,255,100)"}' \
#    --scale_factor $SCALE_FACTOR

#sample_name=SPECTRUM-OV-025_S1_INFRACOLIC_OMENTUM_R1
#filename=SPECTRUM-OV-025_S1_INFRACOLIC_OMENTUM_R1.svs
#type=Fat
#dsa bmp-polygon bitmaps/tissue_type_classifier_weights/${sample_name}/${type}.png \
#    --annotation_name oncofusion-${type,,} \
#    --image_filename $filename \
#    --output_dir dsa_annotations/bmp \
#    --label '{0: "Fat"}' \
#    --scale_factor $SCALE_FACTOR \
#    --line_colors '{"Tumor": "rgb(255,0,0)", "Stroma": "rgb(0,255,0)", "Fat": "rgb(0,0,255)", "Necrosis": "rgb(255,0,255)"}' \
#    --fill_colors '{"Tumor": "rgba(255,0,0,100)", "Stroma": "rgba(0,255,0,100)", "Fat": "rgba(0,0,255,100)", "Necrosis": "rgba(255,0,255,100)"}'
#dsa_upload $DSA_API \
#    --collection_name $DSA_COLLECTION \
#    --image_filename $filename \
#    --annotation_filepath dsa_annotations/bmp/oncofusion-${type,,}_${sample_name}.json \
#    --username $DSA_USERNAME \
#    --password $DSA_PASSWORD
#sample_name=SPECTRUM-OV-025_S1_INFRACOLIC_OMENTUM_R1
# filename=SPECTRUM-OV-025_S1_INFRACOLIC_OMENTUM_R1.svs

# for type in Tumor Stroma Fat Necrosis; do
#     dsa bmp-polygon bitmaps/tissue_type_classifier_weights/${sample_name}/$type.png \
#         --annotation_name oncofusion-${type,,} \
#         --image_filename $filename \
#         --output_dir dsa_annotations/bmp \
#         --label '{0: "'$type'"}' \
#         --line_colors '{"Tumor": "rgb(255,0,0)", "Stroma": "rgb(0,255,0)", "Fat": "rgb(0,0,255)", "Necrosis": "rgb(255,0,255)"}' \
#         --fill_colors '{"Tumor": "rgba(255,0,0,100)", "Stroma": "rgba(0,255,0,100)", "Fat": "rgba(0,0,255,100)", "Necrosis": "rgba(255,0,255,100)"}' \
#         --scale_factor $SCALE_FACTOR
#
#     dsa_upload $DSA_API \
#         --collection_name $DSA_COLLECTION \
#         --image_filename $filename \
#         --annotation_filepath dsa_annotations/bmp/oncofusion-${type,,}_${sample_name}.json \
#         --username $DSA_USERNAME \
#         --password $DSA_PASSWORD
# done


sed '1s/score_0/Stroma/g; 1s/score_1/Tumor/; 1s/score_2/Fat/; 1s/score_3/Necrosis/' ${sample_name}.csv > tissue_type_classifier_weights/${sample_name}_renamed.csv
perl -MEnv -F, -lane 'chop; if ($. == 1) { print $_ . ",coordinates" } else { ($x, $y) = $F[0] =~ /(\d+)_(\d+)\.png/; print $_ . "," . "\"($x,$y)\"";}' tissue_type_classifier_weights/${sample_name}_renamed.csv > tissue_type_classifier_weights/${sample_name}_renamed_coord.csv

dsa heatmap tissue_type_classifier_weights/${sample_name}_renamed.csv \
    --annotation_name oncofusion-tissue \
    --image_filename $filename \
    --output_dir dsa_annotations/heatmap \
    -c Stroma -c Tumor -c Fat -c Necrosis \
    --tile_size $TILE_SIZE \
    --line_colors '{"Tumor": "rgb(255,0,0)", "Stroma": "rgb(0,255,0)", "Fat": "rgb(0,0,255)", "Necrosis": "rgb(255,0,255)"}' \
    --fill_colors '{"Tumor": "rgba(255,0,0,100)", "Stroma": "rgba(0,255,0,100)", "Fat": "rgba(0,0,255,100)", "Necrosis": "rgba(255,0,255,100)"}'


dsa_upload $DSA_API \
    --collection_name $DSA_COLLECTION \
    --image_filename $filename \
    --annotation_filepath dsa_annotations/heatmap/oncofusion-tissue_${sample_name}.json \
    --username $DSA_USERNAME \
    --password $DSA_PASSWORD

dsa stardist-polygon \
    qupath/data/results/${sample_name}.geojson \
    --output_dir dsa_annotations/stardist_polygon \
    --annotation_name oncofusion-cell \
    --image_filename $filename \
    --line_colors '{"Other": "rgb(0,255,0)", "Lymphocyte": "rgb(255,0,0)"}' \
    --fill_colors '{"Other": "rgba(0,255,0,100)", "Lymphocyte": "rgba(255,0,0,100)"}'

dsa_upload $DSA_API \
    --collection_name $DSA_COLLECTION \
    --image_filename $filename \
    --annotation_filepath dsa_annotations/stardist_polygon/oncofusion-cell_${sample_name}.json \
    --username $DSA_USERNAME \
    --password $DSA_PASSWORD
