#!/bin/bash

# Paths to your adapters file and the directory containing your fastq.xz files
ADAPTERS="/home/dayhoff/sdd/juan/db/adapters.txt"
FILES_DIR="."

# Log file
LOG_FILE="script_log.txt"

# Function to log messages
log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if adapters file exists and is not empty
if [[ ! -f "$ADAPTERS" || ! -s "$ADAPTERS" ]]; then
    log_message "Error: Adapter file '$ADAPTERS' does not exist or is empty."
      exit 1
fi


# Trim the sequences with fastq-mcf in parallel
log_message "Starting trimming of .fastq files with fastq-mcf."

find "$FILES_DIR" -name "*_R1_*.fastq" | sort | parallel -j 75 \
  'R1={}; \
  R2=$(echo $R1 | sed "s/_R1_/_R2_/"); \
  OUT1=$(basename $R1 .fastq)_q30.fastq; \
  OUT2=$(basename $R2 .fastq)_q30.fastq; \
  fastq-mcf /home/dayhoff/sdd/juan/db/adapters.txt -l 100 -q 30 $R1 $R2 -o $OUT1 -o $OUT2'

# Check if trimming was successful
if [[ $? -ne 0 ]]; then
    log_message "Error: Trimming of .fastq files failed."
      exit 1
fi
log_message "Trimming completed."

