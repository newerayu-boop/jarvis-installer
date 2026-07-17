#!/bin/bash
cd /home/user/jarvis-installer/work
python3 embed.py && python3 cluster.py && python3 assemble.py && echo "ALL_DONE"
