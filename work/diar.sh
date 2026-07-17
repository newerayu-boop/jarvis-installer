#!/bin/bash
cd /home/user/jarvis-installer/work
python3 diarize.py && python3 assemble.py && echo "DIAR_COMPLETE"
