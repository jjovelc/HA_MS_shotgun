# Define PATHs

# Define PATHs
BWT2_INDEX="/home/dayhoff/sdd/juan/pipelines/greengenes2/bowtie2_index/greengenes2_shotgun"
SHOTGUN_DATA="/home/dayhoff/sdd/juan/projects/heatherArmstrong/MS_study/samples/working_data_5M"

# Function to run Bowtie2 for a single sample
run_bowtie2() {
    FILE=$1
    # Define corresponding R2 file
    R2_FILE=${FILE/_R1_/_R2_}
    # Define output prefix
    OUTPUT_PREFIX=${FILE/_R1_*/}
    # Run Bowtie2 and save the output to a SAM file
    bowtie2 -p 4 -x "$BWT2_INDEX" -1 "$FILE" -2 "$R2_FILE" \
            --seed 42 --very-sensitive -k 16 --np 1 --mp "1,1" \
            --rdg "0,1" --rfg "0,1" --score-min "L,0,-0.05" \
            --no-head --no-unal > "${OUTPUT_PREFIX}.sam"
}

export -f run_bowtie2

# Find all R1 files and run the function in parallel for up to 20 samples at a time
find ${SHOTGUN_DATA} -name "*_R1_001_q30_5M.fastq" | parallel -j 20 run_bowtie2 {}
