#!/usr/bin/env bash
# Launch toolpath_visualizer with a job base directory as Processing args[0].
# Works from the repo root or when installed as ~/.local/bin/run_toolpath_visualizer.
set -euo pipefail

usage() {
  echo "Usage: $0 <job-base-dir>" >&2
  echo "  Example: $0 ~/E/carvings-stuff/Malamut-Anniversary/center-1" >&2
  echo "  Override Processing with: PROCESSING=/path/to/Processing $0 <job-base-dir>" >&2
  echo "  Override sketch repo with: TOOLPATH_VISUALIZER_HOME=/path/to/repo $0 <job-base-dir>" >&2
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

resolve_sketch_dir() {
  local cand
  if [[ -n "${TOOLPATH_VISUALIZER_HOME:-}" ]]; then
    cand=${TOOLPATH_VISUALIZER_HOME/#\~/$HOME}
    if [[ -f "$cand/toolpath_visualizer.pde" ]]; then
      echo "$cand"
      return
    fi
    echo "error: TOOLPATH_VISUALIZER_HOME set but toolpath_visualizer.pde missing: $cand" >&2
    return 1
  fi
  # Running from the repo (or a copy that still sits next to the .pde)
  if [[ -f "$SCRIPT_DIR/toolpath_visualizer.pde" ]]; then
    echo "$SCRIPT_DIR"
    return
  fi
  # Installed to ~/.local/bin — default checkout location on Linux-TANK
  for cand in \
    "$HOME/repos/toolpath_visualizer" \
    "$HOME/repos/foxkit/toolpath_visualizer"
  do
    if [[ -f "$cand/toolpath_visualizer.pde" ]]; then
      echo "$cand"
      return
    fi
  done
  echo "error: could not find toolpath_visualizer.pde" >&2
  echo "  Tried: next to this script, ~/repos/toolpath_visualizer" >&2
  echo "  Set TOOLPATH_VISUALIZER_HOME to the sketch repo and retry." >&2
  return 1
}

if ! SKETCH_DIR=$(resolve_sketch_dir); then
  exit 1
fi
SKETCH_DIR=$(cd "$SKETCH_DIR" && pwd)

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
