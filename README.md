# toolpath_visualizer

Visualizes generated toolpaths from the CAM tools build for the NewMonster inverted Stewart Platform 6-axis router.

One sketch (`toolpath_visualizer.pde`) runs on **Windows 10** and **Linux** (Ubuntu). Pass the carving job folder as the first argument when possible; otherwise the sketch falls back to `GLOBAL_BASE` (platform-specific defaults).

## Controls (same on both platforms)

- `0`–`9` / `+` `-`: switch move file index
- arrow keys: pan; `z`/`Z`: zoom; `r`/`R`: tilt
- `c` / `a` / `f` / `b`: recenter / show all / page forward / back
- `m`: toggle color mode; `o`: open folder chooser
- `g`/`G`: moves vs NGC; `t`/`T`: tool-file naming

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

### Launch the sketch

IDE:

```bash
~/processing-4.5.6/bin/Processing /path/to/toolpath_visualizer
```

Then open the sketch and Run, or pass the job folder via the sketch arguments field.

CLI (preferred for a known job folder; `args[0]` becomes the base dir):

```bash
~/processing-4.5.6/bin/Processing cli \
  --sketch=$HOME/repos/toolpath_visualizer \
  --run \
  $HOME/E/carvings-stuff/Malamut-Anniversary/center-1
```

On Linux, if you omit `args[0]`, `GLOBAL_BASE` defaults to `~/E/carvings-stuff/CBCF-thinstar/star-web-1`. Trace output goes to `$TMPDIR/visualizer_in.txt` (usually `/tmp/visualizer_in.txt`).

### Fixture check (Linux-TANK)

```bash
~/processing-4.5.6/bin/Processing cli \
  --sketch=$HOME/repos/toolpath_visualizer \
  --run \
  $HOME/E/carvings-stuff/Malamut-Anniversary/center-1
```

Expect a P3D window with the toolpath drawn; number keys switch passes.
