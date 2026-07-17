#!/bin/bash
cd /home/user/jarvis-installer/work
echo "waiting for transcription to finish..."
# wait until transcribe.py logs DONE
while ! grep -q "^DONE" transcribe.log 2>/dev/null; do
  if ! pgrep -f "python3 transcribe.py" >/dev/null; then
    if ! grep -q "^DONE" transcribe.log 2>/dev/null; then
      echo "ERROR: transcribe.py exited without DONE"; tail -20 transcribe.log; exit 1
    fi
  fi
  sleep 20
done
echo "transcription DONE. starting diarization..."
python3 diarize.py || { echo "diarize failed"; exit 1; }
echo "diarization done. assembling..."
python3 assemble.py || { echo "assemble failed"; exit 1; }
echo "PIPELINE_COMPLETE"
