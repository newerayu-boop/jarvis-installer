#!/bin/bash
cd /home/user/jarvis-installer/work
echo "=== parallel transcription ==="
python3 parallel_transcribe.py || { echo "transcribe failed"; exit 1; }
echo "=== diarization ==="
python3 diarize.py || { echo "diarize failed"; exit 1; }
echo "=== assemble ==="
python3 assemble.py || { echo "assemble failed"; exit 1; }
echo "PIPELINE_COMPLETE"
