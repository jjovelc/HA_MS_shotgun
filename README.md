# Shotgun metagenomics in paediatric MS 

Initially, all libraries were used to taxonomic (kraken2) and functional (humann3) profiling using the Dayhoff platform.

## Greengenes profiling

Selected libraries were used for microbiome profiling using the Greengenes pipeline. Relevant links follow:

1. [Greengenes in RNA central](https://rnacentral.org/expert-database/greengenes)
2. [Greengenes2 paper in Nat. Biotech.](https://www.nature.com/articles/s41587-023-01845-1)
3. [Woltka paper](https://journals.asm.org/doi/10.1128/msystems.00167-22)

### Data processing

1. Sequences were quality trimmed using script trim_fastq_in_parallel.sh

2. Five million sequences were cropped from each library:

```bash
	# Define the directory containing the FASTQ files
	FILES_DIR="/home/dayhoff/sdd/juan/projects/heatherArmstrong/MS_study/samples"

	# crop top 5M sequences
	find "$FILES_DIR" -name "*_q30.fastq" | sort | parallel -j 25 \
	'FILE={}; \
	head -n 20000000 "$FILE" > "${FILE/.fastq/_5M.fastq}"'	
```

3. Alignments were conducted with script run_bowtie2_parallel.sh

4. Taxonomic classification of reads was coducted with Woltka

```bash
	SAMS_DIR="/home/dayhoff/sdd/juan/projects/heatherArmstrong/MS_study/samples/working_data_5M/aligned_sam_files"

	woltka classify \
		--input  "$SAMS_DIR" \
		--map    taxonomy/taxid.map \
		--nodes  taxonomy/nodes.dmp \
		--names  taxonomy/names.dmp \
		--name-as-id \
		--rank   phylum,family,genus,species \
		--output tax_output
```

5. Functional classification of reads was conducted with Woltka

```bash
	SAMS_DIR="/home/dayhoff/sdd/juan/projects/heatherArmstrong/MS_study/samples/working_data_5M/aligned_sam_files"

	woltka classify \
		--input  "$SAMS_DIR" \
		--coords function/coords.txt.xz \
		--map    function/uniref/uniref.map.xz \
		--map    function/go/process.tsv.xz \
		--rank   uniref,process \
		--output funct_output_dir

```

6. Post-processing with qiime was conducted with script qiime2_after_woltka_wLoops.sh
