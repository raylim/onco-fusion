#!/bin/bash
source /gpfs/mskmind_ess/limr/mambaforge/etc/profile.d/conda.sh
conda activate transformer

output=qupath/data/results/$(basename ${1%%.svs}).geojson
if test -f $output; then
	echo "$output already exists"
else
	singularity run --env TF_FORCE_GPU_ALLOW_GROWTH=true,PER_PROCESS_GPU_MEMORY_FRACTION=0.8 -B $(dirname $1):/data/slides,qupath/data/results:/data/results,qupath/models:/models,qupath/scripts:/scripts --nv qupath/qupath-stardist_latest.sif java -Djava.awt.headless=true \
	-Djava.library.path=/qupath-gpu/build/dist/QuPath-0.2.3/lib/app \
	-jar /qupath-gpu/build/dist/QuPath-0.2.3/lib/app/qupath-0.2.3.jar \
	script --image /data/slides/$(basename $1) /scripts/stardist_nuclei_and_lymphocytes.groovy
fi
