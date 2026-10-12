# toolpath_visualizer

Visualizes generated toolpaths from the CAM tools build for the NewMonster inverted Stewart Platform 6-axis router.

One sketch (`toolpath_visualizer.pde`) runs on **Windows 10** and **Linux** (Ubuntu). Pass the carving job folder as the first argument when possible; otherwise the sketch falls back to `GLOBAL_BASE` (platform-specific defaults).

## Controls (same on both platforms)

- `[` / `]`: previous / next **job stage** folder (sibling under the job root)
  - If the parent directory has `job.json`, stages come from `stages[].prefix` (directories that exist; prefer those with `moves/`; recipe-none stages without a dir are skipped)
  - Otherwise: siblings matching the same `name-N` stem, sorted by `N`
- `0`–`9`: jump to move-file index when `N` &lt; 10
- `+` / `-`: previous / next pass among discovered `moves/moves-*.txt` (or opt / tool / `.ngc` variants per mode); clamped to files that exist on disk
- arrow keys: pan; `z`/`Z`: zoom; `u`/`d`: tilt
- `c` / `a` / `f` / `b`: recenter / show all / page forward / back
- `m`: toggle color mode; `I`: folder chooser
- `g`/`G`: moves vs NGC; `t`/`T`: tool-file naming; `o`/`O`: moves vs opt-moves

## Windows

1. Install [Processing 4](https://processing.org/download) for Windows.
2. Open `toolpath_visualizer.pde` in the Processing IDE and click Run, **or** from a shell:

```text
processing-java --sketch=C:\path\to\toolpath_visualizer --run E:\carvings-stuff\SomeJob\center-1
```

Default `GLOBAL_BASE` remains an `e:/Carvings-Stuff/...` path. Trace output goes to `C:/temp/visualizer_in.txt` (create `C:\temp` if needed).

## Linux (Ubuntu / Linux-TANK)

### Install Processing 4 (official portable zip — not apt)

Failed `.deb` installs have caused permission/JDK problems on this machine. Prefer the official **linux-x64 portable** archive from the [Processing 4 releases](https://github.com/processing/processing4/releases):

```bash
cd ~
curl -L -o processing-4.5.6-linux-x64-portable.zip \
  https://github.com/processing/processing4/releases/download/processing-1434-4.5.6/processing-4.5.6-linux-x64-portable.zip
unzip -q processing-4.5.6-linux-x64-portable.zip -d processing-4.5.6
# launcher:
~/processing-4.5.6/bin/Processing
```

Optional symlink: `ln -sfn ~/processing-4.5.6 ~/processing-4`

### System packages

OpenJDK 17 and Mesa/X11 GL libs are typically enough (Processing ships its own Temurin JDK in the portable tree):

```bash
sudo apt-get install -y openjdk-17-jdk libgl1 libglu1-mesa \
  libx11-6 libxi6 libxrandr2 libxrender1 libxxf86vm1 libxcursor1 libxinerama1
```

### Install the launcher (required)

Copy the repo script into your PATH as `run_toolpath_visualizer` (no `.sh`):

```bash
mkdir -p ~/.local/bin
cp /path/to/toolpath_visualizer/run_toolpath_visualizer.sh ~/.local/bin/run_toolpath_visualizer
chmod +x ~/.local/bin/run_toolpath_visualizer
# ensure ~/.local/bin is on PATH (add to ~/.bashrc if needed):
#   export PATH="$HOME/.local/bin:$PATH"
```

The installed command looks for the sketch at `~/repos/toolpath_visualizer` by default (or next to the script when run from the repo). Override with `TOOLPATH_VISUALIZER_HOME` if your checkout lives elsewhere. Override Processing with `PROCESSING` if needed.

### Launch the sketch

Required path (job dir becomes Processing `args[0]`):

```bash
run_toolpath_visualizer ~/E/carvings-stuff/Malamut-Anniversary/center-1
```

IDE (optional):

```bash
~/processing-4.5.6/bin/Processing /path/to/toolpath_visualizer
```

Then open the sketch and Run, or pass the job folder via the sketch arguments field.

Raw CLI equivalent:

```bash
~/processing-4.5.6/bin/Processing cli \
  --sketch=$HOME/repos/toolpath_visualizer \
  --run \
  $HOME/E/carvings-stuff/Malamut-Anniversary/center-1
```

On Linux, if you omit `args[0]`, `GLOBAL_BASE` defaults to `~/E/carvings-stuff/CBCF-thinstar/star-web-1`. Trace output goes to `$TMPDIR/visualizer_in.txt` (usually `/tmp/visualizer_in.txt`).

### Fixture check (Linux-TANK)

```bash
run_toolpath_visualizer ~/E/carvings-stuff/Malamut-Anniversary/center-1
```

Expect a P3D window with the toolpath drawn. HUD shows stage prefix and index. `]` / `[` hop `center-1` ↔ `center-2` (from parent `job.json`). `+` / `-` walk `moves-0` … `moves-12` inside the stage.
