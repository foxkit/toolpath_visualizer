#!/usr/bin/env bash
# Launch toolpath_visualizer with a job base directory as Processing args[0].
set -euo pipefail

usage() {
  echo "Usage: $0 <job-base-dir>" >&2
  echo "  Example: $0 ~/E/carvings-stuff/Malamut-Anniversary/center-1" >&2
  echo "  Override Processing with: PROCESSING=/path/to/Processing $0 <job-base-dir>" >&2
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

JOB_DIR=$1
# Expand ~ and relative paths
JOB_DIR=${JOB_DIR/#\~/$HOME}
if [[ ! -d "$JOB_DIR" ]]; then
  echo "error: job base directory not found: $1" >&2
  exit 1
fi
JOB_DIR=$(cd "$JOB_DIR" && pwd)

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SKETCH_DIR=$SCRIPT_DIR
if [[ ! -f "$SKETCH_DIR/toolpath_visualizer.pde" ]]; then
  echo "error: toolpath_visualizer.pde not found in $SKETCH_DIR" >&2
  exit 1
fi

resolve_processing() {
  if [[ -n "${PROCESSING:-}" ]]; then
    echo "$PROCESSING"
    return
  fi
  local cand
  for cand in \
    "$HOME/processing-4.5.6/bin/Processing" \
    "$HOME/processing-4/bin/Processing" \
    "$HOME/processing-4.5.6/processing" \
    "$HOME/processing-4/processing"
  do
    if [[ -x "$cand" ]]; then
      echo "$cand"
      return
    fi
  done
  return 1
}

if ! PROCESSING_BIN=$(resolve_processing); then
  echo "error: Processing launcher not found." >&2
  echo "  Tried ~/processing-4.5.6/bin/Processing and ~/processing-4/bin/Processing" >&2
  echo "  Set PROCESSING to the Processing executable path and retry." >&2
  exit 1
fi
if [[ ! -x "$PROCESSING_BIN" ]]; then
  echo "error: Processing is not executable: $PROCESSING_BIN" >&2
  exit 1
fi

echo "Processing: $PROCESSING_BIN"
echo "Sketch:     $SKETCH_DIR"
echo "Job dir:    $JOB_DIR (args[0])"

exec "$PROCESSING_BIN" cli --sketch="$SKETCH_DIR" --run "$JOB_DIR"
