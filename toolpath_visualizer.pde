import processing.net.*;


import processing.opengl.*;
import java.util.*;

int file_number = 0;

float SCALE_STEP = 1.05;

String move_file_suffix = "/moves/moves-";
String opt_file_suffix = "/tmp/opt-moves-";

//String move_file_prefix = design + "/moves/moves-";
//String opt_file_prefix =  design + "/tmp/opt-moves-";

int use_move_files = 1;


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


BufferedReader reader;
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

void setupCore()
{
  int i;
  float tempX = 0, tempY = 0, tempZ = 0;
  //cmd_line = "";
  //if (args != null) 
  //{
  //  println(args.length);
  //  for (i = 0; i < args.length; i++) 
  //  {
  //    cmd_line = cmd_line + " " + args[i];
  //    println(args[i]);
  //  }
  //} else 
  //{
  //  cmd_line = "Null";
  //  println("args == null");
  //}  
  
  if (selectedBaseDir == "")
  {
    if (args != null)
    {
      baseDir = args[0];
    }
    else
    {     
      baseDir = "e:/carvings-stuff/Kristin/target";
    }
  }
  else
  {
    baseDir = selectedBaseDir;
  }

  coordList = new ArrayList();
  if (use_move_files == 1)
    moveFile = baseDir + move_file_suffix + nf(file_number,0) + ".txt";
  else
    moveFile = baseDir + opt_file_suffix  + nf(file_number,0) + ".txt";
  
  surface.setTitle(moveFile);
  print("File: ");println(moveFile);
  reader = createReader(moveFile);  
  if (reader != null)  
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
    println("Selected folder: " + selectedBaseDir);
  }
  setupCore();
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
      file_number ++;
      setupCore();
      keyActive = 0;
      break;
    case '-':
      if (file_number > 0)
        file_number --;
      setupCore();
      keyActive = 0;
      break;
    case 'O':
      use_move_files = 0;
      setupCore();
      keyActive = 0;
      break;
    case 'o':
      use_move_files = 1;
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
    strokeWeight(0.01);
    int first = 1;
    int item_limit = min(front_limit+points_to_display, coordList.size());
    int speed_color;
    int R, G, B;
    for (i = max(0, front_limit); (i < item_limit); i++)
    {
      NMcoord coord;
      coord = (NMcoord) coordList.get(i);
      
//      if (coord.style == 'C')
//      {
//        if (coord.speed == 10000)
//            stroke(100, 100, 0);
//        else if (coord.speed == min_cut_speed)
//            stroke(0, 0, 100);
//        else
//            stroke(100, 0, 0);
//      }
//      else if ((coord.style == 'M') && (coord.z > -0.01))
//        stroke(0, 100, 0);
//      else 
//        stroke(100, 100, 100);
      if (coord.z > 0.0)
      {
        R = 100;
        G = 100;
        B = 100;
      }
      else if (coord.style == 'C')
      {
        R = 100;
        G = 0;
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
  text("Move file: " + moveFile, 10, 25, 0);
}
