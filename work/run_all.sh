#!/bin/bash
cd /home/user/jarvis-installer/work
echo "=== parallel transcription ==="
python3 parallel_transcribe.py || { echo "transcribe failed"; exit 1; }
echo "=== embeddings ==="
python3 embed.py || { echo "embed failed"; exit 1; }
echo "=== cluster (KMeans 2-way) ==="
python3 cluster.py || { echo "cluster failed"; exit 1; }
echo "=== assemble ==="
python3 assemble.py || { echo "assemble failed"; exit 1; }
echo "PIPELINE_COMPLETE"
