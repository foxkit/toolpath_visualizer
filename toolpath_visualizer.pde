import processing.net.*;


import processing.opengl.*;
import java.util.*;

//String GLOBAL_BASE = "e:/carvings-stuff/CBCF-TreeOfLife/center";
//String GLOBAL_BASE = "e:/carvings-stuff/plate-11-2s-web-hex/foo-6";
//String GLOBAL_BASE = "e:/carvings-stuff/CBCF-plate-devel/ots1";
//String GLOBAL_BASE = "e:/carvings-stuff/CBCF-plate-devel/onetoolstar-1";
//String GLOBAL_BASE = "e:/carvings-stuff/plate-11-2s-hex/foo-1";
//String GLOBAL_BASE = "e:/carvings-stuff/Giraffe-Cavities/cavity-1";
//String GLOBAL_BASE = "e:/carvings-stuff/CBCF-TreeOfLife3/center";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Evan-Ring-Box/message-rev5-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Evan-Ring-Box/image-rev5-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Evan-Ring-Box-Cavities/cavity-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Evan-Ring-Box-Cavities/cavity-2";
//String GLOBAL_BASE = "e:/Carvings-Stuff/HamsaBox/cavities-2";
//String GLOBAL_BASE = "e:/Carvings-Stuff/HamsaBox-3in/Ani-Dodi-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Boxes-3x4in/Elephant-Simpler4-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/CompassCanes/compass-2";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Boxes-3x4in/LionCub3-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Boxes-3x4in/4x3-2";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Sue-Virge/center-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/CompassCanes/center-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Leo/cb-Leo-6/center";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Emunah-RKP/center-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/HoshaiahCane/blank-back";
//String GLOBAL_BASE = "e:/Carvings-Stuff/HoshaiahCane/center-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/KyleScott/4in5x3in5-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Marcy-baby/text-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Marcy-baby/center-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/David-Verge/back-2";
//String GLOBAL_BASE = "e:/Carvings-Stuff/David-Verge/front-2";
//String GLOBAL_BASE = "e:/Carvings-Stuff/test/test-2";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Marcy-2/center-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/CBC-TreeOfLife5/center";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Sheila/center-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/convectionplate/frontrecess-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/Earl/2x6";
//String GLOBAL_BASE = "e:/Carvings-Stuff/convectionplate/frontrecess-hexagon-1";
// Default carving folder when no args[0] / folder selection is provided.
// Windows keeps the historical drive-letter path; Linux uses ~/E/... (TANK layout).
String GLOBAL_BASE = "e:/Carvings-Stuff/CBCF-thinstar/star-web-1";
//String GLOBAL_BASE = "e:/Carvings-Stuff/CBCF-thinstar/star-web-UO";


float WEIGHT_CONSTANT = 2.0;

int use_tool_file = 0;
int use_ngc_file = 0;

int file_number = 0;
int tool_selector[] = { 101, 102, 103, 104, 105, 106, 108, 112, 116, 604, 1308, 616, 1000 };

float SCALE_STEP = 1.05;

//String move_file_suffix = "/opt-moves-";
String move_file_suffix = "/moves/moves-";
//String opt_file_suffix  = "/opt-moves-";
String opt_file_suffix  = "/tmp/opt-moves-";

// Trace/debug writer path: Windows C:/temp, Linux java.io.tmpdir (set in initPlatformPaths)
String trace_file = "C:/temp/visualizer_in.txt";

int use_move_files = 1;

// Soften platform-specific defaults without breaking Windows.
// Prefer args[0] (see setupCore) or folder selection over GLOBAL_BASE.
void initPlatformPaths()
{
  if (platform == WINDOWS)
  {
    GLOBAL_BASE = "e:/Carvings-Stuff/CBCF-thinstar/star-web-1";
    trace_file = "C:/temp/visualizer_in.txt";
  }
  else
  {
    GLOBAL_BASE = System.getProperty("user.home") + "/E/carvings-stuff/CBCF-thinstar/star-web-1";
    String tmp = System.getProperty("java.io.tmpdir");
    if (!tmp.endsWith("/") && !tmp.endsWith("\\"))
      tmp += "/";
    trace_file = tmp + "visualizer_in.txt";
  }
  print("platform="); print(platform);
  print(" GLOBAL_BASE="); println(GLOBAL_BASE);
  print("trace_file="); println(trace_file);
}

float min_x =  100000.0;
float max_x = -100000.0;
float min_y =  100000.0;
float max_y = -100000.0;
float min_z =  100000.0;
float max_z = -100000.0;

int move_speed = 0;
int cut_speed = 0;
static int min_cut_speed = 90000;
static int max_cut_speed = 0;
static int min_move_speed = 90000;
static int max_move_speed = 0;
static int min_speed = 90000;
static int max_speed = 0;

float res_scale = 1.0;


float x_shift = 0.0;
float y_shift = 0.0;
float z_shift = 0.0;
float view_angle = 0.0;

int colorDisplayMode = 0;  // 0 = speed/style, 1 = movement-type (Z plane / Z-only / 3D)
float COORD_EPSILON = 0.0001;

BufferedReader reader;
PrintWriter writer;
String line;

PFont f;


class NMcoord
{
  float x, y, z;
  int line_num;
  int speed;
  char style;  // M, C, D (drop not yet available)
  NMcoord (char style_init, int speed_init, float x_init, float y_init, float z_init, int line_num_init)
  {
    style = style_init;
    x = x_init;
    y = y_init;
    z = z_init;
    speed = speed_init;
    line_num = line_num_init;
  }
}

ArrayList coordList;

String selectedBaseDir = "";
String baseDir;
String moveFile;
String suffix;
String prefix;

// Job stage navigation ([ / ]): absolute paths of sibling stage folders.
ArrayList stageDirs = new ArrayList();
int stageIndex = -1;
String stageLabel = "";

// Pass discovery for +/- clamp: sorted file_number values that exist on disk.
ArrayList passNumbers = new ArrayList();

String jobParentOf(String dir)
{
  File f = new File(dir);
  File parent = f.getParentFile();
  if (parent == null)
    return "";
  return parent.getAbsolutePath();
}

String leafName(String dir)
{
  return new File(dir).getName();
}

// Minimal job.json scan: collect stages[]."prefix" string values in order.
ArrayList extractJobPrefixes(String jobJsonPath)
{
  ArrayList prefixes = new ArrayList();
  String[] lines = loadStrings(jobJsonPath);
  if (lines == null)
    return prefixes;
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i < lines.length; i++)
    sb.append(lines[i]).append('\n');
  String content = sb.toString();
  int idx = 0;
  while (true)
  {
    int key = content.indexOf("\"prefix\"", idx);
    if (key < 0)
      break;
    int colon = content.indexOf(':', key + 8);
    if (colon < 0)
      break;
    int q1 = content.indexOf('"', colon + 1);
    if (q1 < 0)
      break;
    int q2 = content.indexOf('"', q1 + 1);
    if (q2 < 0)
      break;
    String value = content.substring(q1 + 1, q2);
    if (value.length() > 0)
      prefixes.add(value);
    idx = q2 + 1;
  }
  return prefixes;
}

boolean stageDirUsable(File stageDir)
{
  if (stageDir == null || !stageDir.isDirectory())
    return false;
  File moves = new File(stageDir, "moves");
  return moves.isDirectory();
}

void discoverStages()
{
  stageDirs = new ArrayList();
  stageIndex = -1;
  stageLabel = "";
  if (baseDir == null || baseDir.length() == 0)
    return;

  String jobRoot = jobParentOf(baseDir);
  if (jobRoot.length() == 0)
    return;

  File jobJson = new File(jobRoot, "job.json");
  ArrayList candidates = new ArrayList();

  if (jobJson.isFile())
  {
    ArrayList prefixes = extractJobPrefixes(jobJson.getAbsolutePath());
    for (int i = 0; i < prefixes.size(); i++)
    {
      String pfx = (String) prefixes.get(i);
      File stageDir = new File(jobRoot, pfx);
      // Skip recipe-none / missing dirs; prefer stages that have moves/.
      if (stageDirUsable(stageDir) || stageDir.isDirectory())
        candidates.add(stageDir.getAbsolutePath());
    }
    // Prefer entries that have moves/; if any do, drop those without.
    ArrayList withMoves = new ArrayList();
    for (int i = 0; i < candidates.size(); i++)
    {
      String path = (String) candidates.get(i);
      if (stageDirUsable(new File(path)))
        withMoves.add(path);
    }
    if (withMoves.size() > 0)
      candidates = withMoves;
  }

  if (candidates.size() == 0)
  {
    // Fallback: siblings matching same stem "name-N", sorted by N.
    String leaf = leafName(baseDir);
    int dash = leaf.lastIndexOf('-');
    if (dash > 0)
    {
      String stem = leaf.substring(0, dash);
      String numPart = leaf.substring(dash + 1);
      boolean numeric = numPart.length() > 0;
      for (int i = 0; i < numPart.length(); i++)
      {
        if (numPart.charAt(i) < '0' || numPart.charAt(i) > '9')
        {
          numeric = false;
          break;
        }
      }
      if (numeric)
      {
        File parent = new File(jobRoot);
        File[] kids = parent.listFiles();
        ArrayList nums = new ArrayList();
        ArrayList paths = new ArrayList();
        if (kids != null)
        {
          for (int i = 0; i < kids.length; i++)
          {
            if (!kids[i].isDirectory())
              continue;
            String n = kids[i].getName();
            if (!n.startsWith(stem + "-"))
              continue;
            String rest = n.substring(stem.length() + 1);
            boolean ok = rest.length() > 0;
            for (int j = 0; j < rest.length(); j++)
            {
              if (rest.charAt(j) < '0' || rest.charAt(j) > '9')
              {
                ok = false;
                break;
              }
            }
            if (!ok)
              continue;
            int nVal = int(rest);
            // insert sorted by N
            int insertAt = nums.size();
            for (int k = 0; k < nums.size(); k++)
            {
              if (nVal < ((Integer) nums.get(k)).intValue())
              {
                insertAt = k;
                break;
              }
            }
            nums.add(insertAt, Integer.valueOf(nVal));
            paths.add(insertAt, kids[i].getAbsolutePath());
          }
        }
        candidates = paths;
      }
    }
  }

  stageDirs = candidates;
  String baseAbs = new File(baseDir).getAbsolutePath();
  for (int i = 0; i < stageDirs.size(); i++)
  {
    String p = (String) stageDirs.get(i);
    if (new File(p).getAbsolutePath().equals(baseAbs))
    {
      stageIndex = i;
      break;
    }
  }
  if (stageIndex < 0 && stageDirs.size() > 0)
  {
    // Current dir not in list (e.g. opened a non-stage folder); keep index unset.
    stageLabel = leafName(baseDir);
  }
  else if (stageIndex >= 0)
  {
    stageLabel = leafName((String) stageDirs.get(stageIndex));
  }
  else
  {
    stageLabel = leafName(baseDir);
  }
  print("stages="); print(stageDirs.size());
  print(" index="); print(stageIndex);
  print(" label="); println(stageLabel);
}

void discoverPasses()
{
  passNumbers = new ArrayList();
  if (baseDir == null || baseDir.length() == 0)
    return;

  if (use_ngc_file == 1)
    suffix = ".ngc";
  else
    suffix = ".txt";

  if (use_tool_file == 1)
  {
    String dirPrefix;
    if (use_move_files == 1)
      dirPrefix = baseDir + move_file_suffix;
    else
      dirPrefix = baseDir + opt_file_suffix;
    for (int i = 0; i < tool_selector.length; i++)
    {
      String path = dirPrefix + "tool-" + nf(tool_selector[i], 0) + suffix;
      if (new File(path).isFile())
        passNumbers.add(Integer.valueOf(i));
    }
  }
  else
  {
    File scanDir;
    String filePrefix;
    if (use_move_files == 1)
    {
      scanDir = new File(baseDir, "moves");
      filePrefix = "moves-";
    }
    else
    {
      scanDir = new File(baseDir, "tmp");
      filePrefix = "opt-moves-";
    }
    File[] files = scanDir.listFiles();
    if (files != null)
    {
      for (int i = 0; i < files.length; i++)
      {
        if (!files[i].isFile())
          continue;
        String name = files[i].getName();
        if (!name.startsWith(filePrefix) || !name.endsWith(suffix))
          continue;
        // Skip tool-named files in moves mode (moves-tool-101.txt).
        String mid = name.substring(filePrefix.length(), name.length() - suffix.length());
        if (mid.startsWith("tool-"))
          continue;
        boolean ok = mid.length() > 0;
        for (int j = 0; j < mid.length(); j++)
        {
          if (mid.charAt(j) < '0' || mid.charAt(j) > '9')
          {
            ok = false;
            break;
          }
        }
        if (!ok)
          continue;
        int nVal = int(mid);
        int insertAt = passNumbers.size();
        for (int k = 0; k < passNumbers.size(); k++)
        {
          if (nVal < ((Integer) passNumbers.get(k)).intValue())
          {
            insertAt = k;
            break;
          }
        }
        // de-dupe
        boolean exists = false;
        for (int k = 0; k < passNumbers.size(); k++)
        {
          if (((Integer) passNumbers.get(k)).intValue() == nVal)
          {
            exists = true;
            break;
          }
        }
        if (!exists)
          passNumbers.add(insertAt, Integer.valueOf(nVal));
      }
    }
  }
  print("passes="); println(passNumbers.size());
}

int passListIndexOf(int n)
{
  for (int i = 0; i < passNumbers.size(); i++)
  {
    if (((Integer) passNumbers.get(i)).intValue() == n)
      return i;
  }
  return -1;
}

void clampFileNumberToPasses()
{
  if (passNumbers.size() == 0)
    return;
  if (passListIndexOf(file_number) >= 0)
    return;
  // Snap to nearest existing pass (prefer lower, then first).
  int best = ((Integer) passNumbers.get(0)).intValue();
  int bestDist = abs(best - file_number);
  for (int i = 1; i < passNumbers.size(); i++)
  {
    int n = ((Integer) passNumbers.get(i)).intValue();
    int d = abs(n - file_number);
    if (d < bestDist)
    {
      best = n;
      bestDist = d;
    }
  }
  file_number = best;
}

void stepPass(int delta)
{
  discoverPasses();
  if (passNumbers.size() == 0)
  {
    // Fallback: unbounded-ish but floor at 0.
    file_number = max(0, file_number + delta);
    return;
  }
  int idx = passListIndexOf(file_number);
  if (idx < 0)
  {
    clampFileNumberToPasses();
    idx = passListIndexOf(file_number);
  }
  if (idx < 0)
    return;
  int next = idx + delta;
  if (next < 0)
    next = 0;
  if (next >= passNumbers.size())
    next = passNumbers.size() - 1;
  file_number = ((Integer) passNumbers.get(next)).intValue();
}

void goToStage(int delta)
{
  discoverStages();
  if (stageDirs.size() == 0)
  {
    println("No sibling stages found");
    return;
  }
  int idx = stageIndex;
  if (idx < 0)
    idx = 0;
  idx += delta;
  if (idx < 0)
    idx = 0;
  if (idx >= stageDirs.size())
    idx = stageDirs.size() - 1;
  if (idx == stageIndex && stageIndex >= 0)
    return;
  selectedBaseDir = (String) stageDirs.get(idx);
  stageIndex = idx;
  stageLabel = leafName(selectedBaseDir);
  file_number = 0;
  front_limit = 0;
  println("Stage -> " + selectedBaseDir);
  setupView();
}

void resetBounds()
{
  min_x =  100000.0;
  max_x = -100000.0;
  min_y =  100000.0;
  max_y = -100000.0;
  min_z =  100000.0;
  max_z = -100000.0;
  min_cut_speed = 90000;
  max_cut_speed = 0;
  min_move_speed = 90000;
  max_move_speed = 0;
  min_speed = 90000;
  max_speed = 0;
}

void setupCore()
{
  int i;
  float tempX = 0, tempY = 0, tempZ = 0; 
  
  // Resolution order: folder UI selection, then CLI args[0], then GLOBAL_BASE.
  if (selectedBaseDir == "")
  {
    if (args != null && args.length > 0 && args[0] != null && args[0].length() > 0)
    {
      baseDir = args[0];
    }
    else
    { 
      baseDir = GLOBAL_BASE;
    }
  }
  else
  {
    baseDir = selectedBaseDir;
  }
  print("baseDir="); println(baseDir);

  resetBounds();
  discoverStages();
  discoverPasses();

  coordList = new ArrayList();
  
  if (use_move_files == 1)
    prefix = baseDir + move_file_suffix;
  else
    prefix = baseDir + opt_file_suffix;
    
  if (use_ngc_file == 1)
    suffix = ".ngc";
  else
    suffix = ".txt";
    
  if (use_tool_file == 1)
  {
    moveFile = prefix + "tool-" + nf(tool_selector[file_number],0) + suffix;
  }
  else
  {
    moveFile = prefix + nf(file_number,0) + suffix;
  }
  
  String title = moveFile;
  if (stageDirs.size() > 0 && stageIndex >= 0)
    title = stageLabel + " [" + (stageIndex + 1) + "/" + stageDirs.size() + "]  " + moveFile;
  surface.setTitle(title);
  writer = createWriter(trace_file);
  reader = createReader(moveFile);  
  if (reader != null)  
  {
    if (use_ngc_file == 1)
    {
      try 
      {
        float X, Y, Z, F;
        X = -10000.0;
        Y = -10000.0;
        Z = -10000.0;
        F = -10000.0;
        line = reader.readLine();
        writer.print(line);
        // text(line, 10, 25, 0);
        for (i = 0, line = reader.readLine(); 
             // (i < 10000000) && 
               (line != null);
             i++, line = reader.readLine())
        {
          if (line == null)
            break;
          if (line.length() < 2)
            continue;
          if ((i % 10000) == 0)
          {
            print(i); print(" G-> "); println(coordList.size());
          }
          if (line.charAt(0) == '(')
          {
            // do nothing
          }
          else if ((line.charAt(0) == 'G') &&
                   (line.charAt(1) == '1'))
          {
            String[] numbers = splitTokens(line, "GXYZAF ");
            String[] labels  = splitTokens(line, "-0123456789. ");
            int speed;
            // println("labels[0][0..2] = " + labels[0].charAt(0) + labels[0].charAt(1) + labels[0].charAt(2));
            if (labels.length != numbers.length)
            {
              println("l.l=" + labels.length + 
                      "  != n.l=" + numbers.length + 
                      "  line=\"" + line + "\"");
            }
            else if ((labels.length > 0) && 
                     (labels[0].charAt(0) == 'G') &&
                     (numbers[0].charAt(0) == '1'))
            {
              if (labels.length > 1)
              {
                if (labels[1].charAt(0) == 'X')
                  X = float(numbers[1]);
                if (labels[1].charAt(0) == 'Y')
                  Y = float(numbers[1]);
                if (labels[1].charAt(0) == 'Z')
                  Z = float(numbers[1]);
                if (labels[1].charAt(0) == 'F')
                  F = float(numbers[1]);
              }
              if (labels.length > 2)
              {
                if (labels[2].charAt(0) == 'X')
                  X = float(numbers[2]);
                if (labels[2].charAt(0) == 'Y')
                  Y = float(numbers[2]);
                if (labels[2].charAt(0) == 'Z')
                  Z = float(numbers[2]);
                if (labels[2].charAt(0) == 'F')
                  F = float(numbers[2]);
              }
              if (labels.length > 3)
              {
                if (labels[3].charAt(0) == 'X')
                  X = float(numbers[3]);
                if (labels[3].charAt(0) == 'Y')
                  Y = float(numbers[3]);
                if (labels[3].charAt(0) == 'Z')
                  Z = float(numbers[3]);
                if (labels[3].charAt(0) == 'F')
                  F = float(numbers[3]);
              }
              if (labels.length > 4)
              {
                if (labels[4].charAt(0) == 'X')
                  X = float(numbers[4]);
                if (labels[4].charAt(0) == 'Y')
                  Y = float(numbers[4]);
                if (labels[4].charAt(0) == 'Z')
                  Z = float(numbers[4]);
                if (labels[4].charAt(0) == 'F')
                  F = float(numbers[4]);
              }
              speed = (int)(10000*(F/60.0));
              coordList.add(new NMcoord('C', (int)(10000*(F/60.0)), X, -Y, Z, i));
              max_speed = max(max_move_speed, max_cut_speed);
              min_speed = min(min_move_speed, min_cut_speed);
            }
            else
            {
              println("Should have been G1 l.l=" + labels.length + 
                      "  n.l=" + numbers.length + 
                      "  line=\"" + line + "\"");
              println("labels[0][0..2] = " + labels[0].charAt(0) + labels[0].charAt(1) + labels[0].charAt(2));
            }
          }
          else
          {
            //println("Other code: " + line);
          }
        }
      } catch (IOException e) 
      {
        e.printStackTrace();
        line = null;
      }
    }
    else
    {
      try 
      {
        line = reader.readLine();
        for (i = 0, line = reader.readLine(); 
             // (i < 10000000) && 
               (line != null);
             i++, line = reader.readLine())
        {
          if (line == null)
            break;
          if (line.length() < 2)
            continue;
          if ((i % 10000) == 0)
          {
            print(i); print(" -> "); println(coordList.size());
          }
          if ((line.charAt(0) != '#') &&
              (line.charAt(0) != 'P') &&
              (line.charAt(0) != 'S')
             )
          {
            String[] coords = splitTokens(line, " ");
            int speed;
            tempX = float(coords[1]) * 1.0;
            if (min_x > tempX)
              min_x = tempX;
            if (max_x < tempX)
              max_x = tempX;
            tempY = float(coords[2]) * 1.0;
            if (min_y > tempY)
              min_y = tempY;
            if (max_y < tempY)
              max_y = tempY;
            tempZ = float(coords[3]) * 1.0;
            if (min_z > tempZ)
              min_z = tempZ;
            if (max_z < tempZ)
              max_z = tempZ;
            if (coords[0].charAt(0) == 'M')
              speed = move_speed;
            else
              speed = cut_speed;
            coordList.add(new NMcoord(coords[0].charAt(0), speed, tempX, -tempY, tempZ, i));
          }
          else if ((line != null) &&
                   (line.charAt(0) != '#') &&
                   (line.charAt(0) != 'P') &&
                   (line.charAt(0) == 'S') &&
                   ((line.charAt(1) == 'C') ||
                    (line.charAt(1) == 'M')) )
          {
            String[] speed = splitTokens(line, " ");
            if (line.charAt(1) == 'C')
            {
              cut_speed = int(speed[1]);
              if (cut_speed < min_cut_speed)
                min_cut_speed = cut_speed;
              if (cut_speed > max_cut_speed)
                max_cut_speed = cut_speed;
            }
            else if (line.charAt(1) == 'M')
            {
              move_speed = int(speed[1]);
              if (move_speed < min_move_speed)
                min_move_speed = move_speed;
              if (move_speed > max_move_speed)
                max_move_speed = move_speed;
            }
            max_speed = max(max_move_speed, max_cut_speed);
            min_speed = min(min_move_speed, min_cut_speed);
          }
        }
      } catch (IOException e) 
      {
        e.printStackTrace();
        line = null;
      }
    }
    try
    {
      reader.close();
    }
    catch (IOException e)
    {
    }
  }
}

//void settings()
//{
//  size(displayWidth-100, displayHeight-100, P3D);
//}

int count = 0;
 
void setupView()
{
  float t_scale = 0.0;
  float scale_width = width;
  float scale_height = height;
  surface.setTitle(str(count++));
  surface.setResizable(true);
  colorMode(RGB, 100, 100, 100);
  print("display=["); print(scale_width); print(","); print(scale_height); println("]");
  print("canvas=["); print(width); print(","); print(height); println("]");
  setupCore();
  res_scale = scale_width/(max_x-min_x);
  t_scale = scale_height/(max_y-min_y);
  if (t_scale < res_scale)
    res_scale = t_scale;
  x_shift = -(min_x);
  x_shift = (max_x-min_x);
  x_shift = (scale_width/res_scale)/2.0-(max_x+min_x)/2.0;
  // y_shift = -(min_y+(displayHeight - (max_y-min_y))/2.0);
  //cy_shift = -(min_y);
  y_shift = (scale_height/res_scale)/2.0-(max_y+min_y)/2.0;
  z_shift = -(max_z);
  print("Display:["); print(displayWidth); print(","); print(displayHeight); print("]   Scaled:["); print(displayWidth/res_scale); print(","); print(displayHeight/res_scale); println("]");
  print("Image Range:["); print(max_x - min_x); print(","); print(max_y-min_y); println("]");
  print("Shift:["); print(x_shift); print(","); print(y_shift); print("."); print(z_shift); println("]");
}

void setup()
{
  //fullScreen(P3D, 1); 
  size(1920, 1080, P3D);
  initPlatformPaths();
  surface.setTitle(moveFile);
  surface.setResizable(true);
  colorMode(RGB, 100, 100, 100);
  f = createFont("Arial",768,true);
  setupView();
  String spath = sketchPath();
  print("SPath:");println(spath);
  String upath = System.getProperty("user.dir");
  print("UPath:");println(upath);
  Properties P = System.getProperties();
  print("Keys:"); 
  Enumeration<Object> keys = P.keys();
  while(keys.hasMoreElements())
  {
    System.out.println(keys.nextElement());
  }
}

int front_limit = 0;
int points_to_display = 50000;

int keyDown = 0;
int keySeen = 1;
int keyCodeDown = 0;
int keyActive = 0;

void folderSelected(File selection)
{
  if (selection == null)
  {
    println("Window closed or user hit cancel");
  }
  else
  {
    selectedBaseDir = selection.getAbsolutePath();
    file_number = 0;
    front_limit = 0;
    println("Selected folder: " + selectedBaseDir);
  }
  setupView();
}

void keyAction()
{
  if ((keyActive == 0) && (keySeen == 1))
    return;
  keySeen = 1;
  print("Key: "); println(key);
  switch(keyDown)
  {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      file_number = (int)key - (int)'0';
      setupCore();
      keyActive = 0;
      break;
    case '+':
    case '=':
      stepPass(1);
      setupCore();
      keyActive = 0;
      break;
    case '-':
      stepPass(-1);
      setupCore();
      keyActive = 0;
      break;
    case '[':
      goToStage(-1);
      keyActive = 0;
      break;
    case ']':
      goToStage(1);
      keyActive = 0;
      break;
    case 'O':
      use_move_files = 0;
      file_number = 0;
      setupCore();
      keyActive = 0;
      break;
    case 'o':
      use_move_files = 1;
      file_number = 0;
      setupCore();
      keyActive = 0;
      break;
    case 'd':
      view_angle -= 2.5;
      break;
    case 'u':
      view_angle += 2.5;
      break;
    case 'I':
      selectFolder("Select a design folder:", "folderSelected");
      keyActive = 0;
      break;
    case 'z':
      res_scale /= SCALE_STEP;
      break;
    case 'Z':
      res_scale *= SCALE_STEP;
      break;
    case 'w':
      points_to_display = points_to_display * 2;
      break;
    case 'n':
      points_to_display = points_to_display/2;
      if (points_to_display == 0)
        points_to_display = 1;
      break;
    case (char)12:
      setupView();
      break;
    case 'f':
      front_limit = min(front_limit + points_to_display/4,
                        coordList.size()-1);
      break;
    case 'c':
      setupView();
      view_angle = 0.0;
      front_limit=0;
      points_to_display = coordList.size();
      keyActive = 0;
      break;
    case 'b':
      front_limit -= points_to_display/4;
      if (front_limit < 0)
        front_limit = 0;
      break;
    case 'a':
      front_limit = 0;
      points_to_display = coordList.size();
      keyActive = 0;
      break;
    case 'G':
      use_ngc_file = 1;
      file_number = 0;
      setupCore();
      keyActive = 0;
      break;
    case 'g':
      use_ngc_file = 0;
      file_number = 0;
      setupCore();
      keyActive = 0;
      break;
    case 'T': 
      use_tool_file = 1;
      file_number = 0;
      setupCore();
      keyActive = 0;
      break;
    case 't':
      use_tool_file = 0;
      file_number = 0;
      setupCore();
      keyActive = 0;
      break;
    case 'm':
      colorDisplayMode = (colorDisplayMode + 1) % 2;
      keyActive = 0;
      break;
    case CODED:
      print("Coded: "); println(keyCodeDown);
      switch (keyCodeDown)
      {
        case 37:
          x_shift += 0.125*(res_scale/(displayWidth/(max_x-min_x)));
          break;
        case 39:
          x_shift -= 0.125*(res_scale/(displayWidth/(max_x-min_x)));
          break;
        case 38:
          y_shift += 0.125*(res_scale/(displayWidth/(max_x-min_x)));
          break;
        case 40:
          y_shift -= 0.125*(res_scale/(displayWidth/(max_x-min_x)));
          break;
        default:
          print("Code=");println(keyCode);
          break;
      }
      break;
      default:
        print("Key=");println(key);
  }
  print("This image (#"); print(file_number); println("):");
  if (coordList.size()==0)
    println("Is Empty");
  else
  {
    print("  Line:  "); print(((NMcoord) coordList.get(front_limit)).line_num);
    print("  Index: ");print(front_limit); print("  points_to_display:  "); println(points_to_display);
    print("  Zoom:   "); print(res_scale); 
    print(" O=(");print(x_shift);print(",");print(y_shift);print(",");print(z_shift);println(")");
    print(" ([");
    print(min_x);print(",");print(max_x);print("],[");
    print(min_y);print(",");print(max_y);print("],[");
    print(min_z);print(",");print(max_z);println("])");
  }
}

void keyPressed()
{
  print("Key: "); println(key);
  keyDown = key;
  keyCodeDown = keyCode;
  keySeen = 0;
  keyActive = 1;
}

void keyReleased()
{
  keyActive = 0;
} 


void draw()
{
  background(0);
  int i;
  float lastX = 0, lastY = 0, lastZ = 0;
  keyAction();
  // Add basic light setup
  lights(); 
//  scale(res_scale/120, res_scale/120, res_scale/120);
  push();
  {
    scale(res_scale, res_scale, res_scale);
    translate(0+x_shift, 0+y_shift, 0+z_shift);  
    rotateX(radians(view_angle));
    // Slowly rotate plate
    // rotateZ(frameCount * PI/600);
//    strokeWeight(0.01);
    strokeWeight(WEIGHT_CONSTANT/res_scale);
    strokeCap(ROUND);
    strokeJoin(ROUND);
    int first = 1;
    int item_limit = min(front_limit+points_to_display, coordList.size());
    int speed_color;
    int R, G, B;
    if (front_limit > 0)
    {
      NMcoord prevCoord = (NMcoord) coordList.get(front_limit - 1);
      lastX = prevCoord.x;
      lastY = prevCoord.y;
      lastZ = prevCoord.z;
    }
    for (i = max(0, front_limit); (i < item_limit); i++)
    {
      NMcoord coord;
      coord = (NMcoord) coordList.get(i);
      
      if ((colorDisplayMode == 0) && (coord.z > 0.0))
      {
        R = 100;
        G = 100;
        B = 100;
      }
      else if (colorDisplayMode == 1)
      {
        float deltaX = abs(coord.x - lastX);
        float deltaY = abs(coord.y - lastY);
        float deltaZ = abs(coord.z - lastZ);
        boolean sameZ = (deltaZ < COORD_EPSILON);
        boolean sameXY = (deltaX < COORD_EPSILON && deltaY < COORD_EPSILON);
        boolean zChanges = (deltaZ >= COORD_EPSILON);
        boolean xyChanges = (deltaX >= COORD_EPSILON || deltaY >= COORD_EPSILON);
        if (sameZ)
        {
          R = 0;
          G = 0;
          B = 100;
        }
        else if (sameXY)
        {
          R = 0;
          G = 100;
          B = 0;
        }
        else if (zChanges && xyChanges)
        {
          R = 100;
          G = 0;
          B = 100;
        }
        else
        {
          R = 100;
          G = 100;
          B = 100;
        }
      }
      else if (coord.style == 'C')
      {
        R = 100;
        G = 0;
        if (max_speed == min_speed)
          B = 50;
        else
          B = 100 * (coord.speed - min_speed) / (max_speed - min_speed);
      }
      else
      {
        R = 0;
        G = 100;
        B = 100 * (coord.speed - min_speed) / (max_speed - min_speed);
      }
      stroke(R, G, B);
      if (first == 0)
      { 
          line(lastX, lastY, lastZ, coord.x, coord.y, coord.z);
      }
      else
        first = 0;
      lastX = coord.x;
      lastY = coord.y;
      lastZ = coord.z;
    }
  }
  pop();
  textFont(f,16);
  fill(255,255,255);
  textAlign(LEFT);
  String stageHud;
  if (stageDirs.size() > 0 && stageIndex >= 0)
    stageHud = "Stage: " + stageLabel + " (" + (stageIndex + 1) + "/" + stageDirs.size() + ")  [ ]";
  else
    stageHud = "Stage: " + stageLabel + " (no siblings)";
  int passIdx = passListIndexOf(file_number);
  String passHud;
  if (passNumbers.size() > 0 && passIdx >= 0)
    passHud = "Pass: " + file_number + " (" + (passIdx + 1) + "/" + passNumbers.size() + ")  +/-";
  else
    passHud = "Pass: " + file_number;
  text(stageHud, 10, 25, 0);
  text(passHud, 10, 45, 0);
  text("Move file: " + moveFile, 10, 65, 0);
  text("Color: " + (colorDisplayMode == 0 ? "speed/style" : "movement-type (m to toggle)"), 10, 85, 0);
}
