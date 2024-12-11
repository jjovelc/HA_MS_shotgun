#!/bin/bash

# Relevant QIIME2 page: https://cap-lab.bio/q2-books/02-read-analysis.html

# Import biom files and perform various analyses for multiple taxonomic levels

# Define the levels and output prefixes
levels=("phylum" "family" "genus" "species")

# Import BIOM files
for level in "${levels[@]}"; do
  qiime tools import \
    --input-path ${level}.biom \
    --type 'FeatureTable[Frequency]' \
    --input-format BIOMV210Format \
    --output-path ${level}.qza
done

# Generate barplots
for level in "${levels[@]}"; do
  qiime taxa barplot \
    --i-table ${level}.qza \
    --m-metadata-file metadata.tsv \
    --o-visualization taxa-bar-plot-${level}.qzv
done

# Generate relative-frequency tables
for level in "${levels[@]}"; do
  qiime feature-table relative-frequency \
    --i-table ${level}.qza \
    --o-relative-frequency-table ${level}-rf.qza
done

# Alpha diversity analysis
# Observed features
for level in "${levels[@]}"; do
  qiime diversity alpha \
    --i-table ${level}-rf.qza \
    --p-metric "observed_features" \
    --o-alpha-diversity obs-feat-${level}-rf.qza
done

# Shannon index
for level in "${levels[@]}"; do
  qiime diversity alpha \
    --i-table ${level}-rf.qza \
    --p-metric "shannon" \
    --o-alpha-diversity shannon-${level}-rf.qza
done

# Export alpha diversity results
# Observed features
for level in "${levels[@]}"; do
  qiime tools export \
    --input-path obs-feat-${level}-rf.qza \
    --output-path observed-features-alpha-diversity-${level}
done

# Shannon index
for level in "${levels[@]}"; do
  qiime tools export \
    --input-path shannon-${level}-rf.qza \
    --output-path shannon-alpha-diversity-${level}
done

# Beta diversity analysis
metrics=("jaccard" "weighted_unifrac" "unweighted_unifrac" "braycurtis")
for metric in "${metrics[@]}"; do
  for level in "${levels[@]}"; do
    qiime diversity beta \
      --i-table ${level}-rf.qza \
      --p-metric ${metric} \
      --o-distance-matrix ${metric}-${level}.qza
  done
done

# PCoA analysis (Bray-Curtis)
for level in "${levels[@]}"; do
  qiime diversity pcoa \
    --i-distance-matrix braycurtis-${level}.qza \
    --o-pcoa braycurtis-${level}-pcoa.qza
done

# Visualize distance matrix using Emperor
for level in "${levels[@]}"; do
  qiime emperor plot \
    --i-pcoa braycurtis-${level}-pcoa.qza \
    --m-metadata-file metadata.tsv \
    --o-visualization braycurtis-${level}-emperor.qzv
done
