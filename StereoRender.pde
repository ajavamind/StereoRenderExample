// 3D Stereo Rendering Engine
// Anaglyph conversion algorithms derived from Stereo Photo Maker HTML5 
// stereo5.js (version 0.5) presentation script

class StereoRender
{
  // display modes
  public static final int SINGLE = 0; // 2D
  public static final int SBS = 1;  // full width side by side
  public static final int HWSBS = 2; // half width side by side (3D TV)
  public static final int AB = 3;  // full height above/below 
  public static final int HHAB = 4; // half height above/below (3D TV)
  public static final int ANAGLYPH = 5; // red/cyan anaglyph
  public static final int CANAGLYPH = 6; // Color anaglyph
  public static final int DUBOIS = 7; // Dubois anaglyph
  public static final int COLINTERLACE = 8; // column interlace (Rokit 3D phone)
  public static final int ROWINTERLACE = 9; // row interlace
  public static final int SPMANAGLYPH = 10; // SPM anaglyph
  String[] MODE = {"SINGLE 2D", "SBS", "HWSBS", "AB", "HHAB", "ANAGLYPH", "CANAGLYPH", "DUBOIS", 
    "COLINTERLACE", "ROWINTERLACE", "SPMANAGLYPH"};

  PShape[] plane = new PShape[2];
  PGraphics[] buffer = new PGraphics[2];
  PImage screen;
  int x=0;
  int y=0;
  int w; // photo width
  int h; // photo height
  int mode = SBS;
  boolean crosseye = false;
  int[] eye = { L, R };

  StereoRender() {
    initMode();
  }

  void initMode() {
    switch (mode) {
    case SBS:
    case HWSBS:
      buffer[L] = createGraphics(width/2, height, P3D);
      buffer[R] = createGraphics(width/2, height, P3D);
      break;
    case AB:
    case HHAB:
      buffer[L] = createGraphics(width, height/2, P3D);
      buffer[R] = createGraphics(width, height/2, P3D);
      break;    
    case COLINTERLACE:
    case ROWINTERLACE:
    case ANAGLYPH:
    case CANAGLYPH:
    case SPMANAGLYPH:
    case DUBOIS:
    case SINGLE:
      buffer[L] = createGraphics(width, height, P3D);
      buffer[R] = createGraphics(width, height, P3D);
      break;
    default:
      if (DEBUG) println("Internal program mode "+ mode + " error");      
      break;
    }
  }

  void setMode(int mode) {
    this.mode = mode;
    initMode();
  }

  int getMode() {
    return mode;
  }

  String getModeString() {
    return MODE[mode];
  }

  void setPhoto(PImage[] photo) {
    plane[L] = createPlane(photo[L]);
    plane[R] = createPlane(photo[R]);
  }

  void setCrosseye(boolean value) {
    crosseye = value;
    if (crosseye) {
      eye[L] = R;
      eye[R] = L;
    } else {
      eye[L] = L;
      eye[R] = R;
    }
  }

  boolean getCrosseye() {
    return crosseye;
  }

  void draw(float scale, float xdelta, float ydelta, int parallax)
  {
    fillBuffer(L, scale, xdelta, ydelta, parallax);
    fillBuffer(R, scale, xdelta, ydelta, parallax);
    if (mode == SBS || mode == HWSBS) {
      image(buffer[eye[L]], 0, 0);
      image(buffer[eye[R]], width/2, 0);
    } else if (mode == AB || mode == HHAB) {
      image(buffer[eye[L]], 0, 0);
      image(buffer[eye[R]], 0, height/2);
    } else if (mode == COLINTERLACE) {
      screen = columnInterlace(buffer[eye[L]], buffer[eye[R]]);
      image(screen, 0, 0);
    } else if (mode == ROWINTERLACE) {
      screen = rowInterlace(buffer[eye[L]], buffer[eye[R]]);
      image(screen, 0, 0);
    } else if (mode == ANAGLYPH ) {
      screen = redCyanAnaglyph(buffer[eye[L]], buffer[eye[R]]);
      image(screen, 0, 0);
    } else if (mode == CANAGLYPH) {
      screen = colorAnaglyph(buffer[eye[L]], buffer[eye[R]]);
      image(screen, 0, 0);
    } else if (mode == DUBOIS) {
      screen = duboisAnaglyph(buffer[eye[L]], buffer[eye[R]]);
      image(screen, 0, 0);
    } else if (mode == SPMANAGLYPH) {
      screen = spmAnaglyph(buffer[eye[L]], buffer[eye[R]]);
      image(screen, 0, 0);
    } else if (mode == SINGLE) {
      screen = buffer[eye[L]];
      image(screen, 0, 0);
    } else {
      if (DEBUG) println("Internal error mode "+ mode + " not implemented");
    }
  }

  private PShape createPlane(PImage photo) {
    PShape face = createShape();
    face.beginShape(QUADS);
    face.noStroke();
    face.textureMode(NORMAL);
    face.texture(photo);
    w = photo.width;
    h = photo.height;
    float ar = (float) w / (float) h;
    face.vertex(-ar, -1, 1, 0, 0);
    face.vertex( 1, -1, 1, 1, 0);
    face.vertex( 1, 1, 1, 1, 1);
    face.vertex(-ar, 1, 1, 0, 1);
    face.endShape(CLOSE);
    return face;
  }


  private void fillBuffer(int i, float scale, float xdelta, float ydelta, int parallax)
  {
    int offset = parallax;
    if (i == R) {
      offset = -parallax;
    }
    buffer[i].beginDraw();
    buffer[i].background(0);
    pushMatrix();
    buffer[i].translate(buffer[i].width/2 + xdelta + offset, buffer[i].height/2+ydelta, 0);
    buffer[i].scale(scale);
    if (mode == HWSBS) {
      buffer[i].shape(plane[i], x, y, plane[i].width/2, plane[i].height);
    } else if (mode == HHAB) {
      buffer[i].shape(plane[i], x, y, plane[i].width, plane[i].height/2);
    } else {
      buffer[i].shape(plane[i], x, y);
    }
    popMatrix();
    buffer[i].endDraw();
  }

  private PGraphics columnInterlace(PGraphics bufL, PGraphics bufR) {
    // column interlace merge left and right images
    // reuse left image for faster performance
    bufL.loadPixels();
    bufR.loadPixels();
    int len = bufL.pixels.length;
    int i = 0;
    while (i < len) {
      i++;
      bufL.pixels[i] = bufR.pixels[i];
      i++;
    }
    bufL.updatePixels();
    return bufL;
  }

  private PGraphics rowInterlace(PGraphics bufL, PGraphics bufR) {
    // row interlace merge left and right images
    // reuse left image for faster performance
    bufL.loadPixels();
    bufR.loadPixels();
    int len = bufL.pixels.length;
    int i = 0;
    while (i < len) {
      i += bufL.width; // skip row
      int k = i + bufL.width;
      while (i < k) {
        bufL.pixels[i] = bufR.pixels[i];
        i++;
      }
    }
    bufL.updatePixels();
    return bufL;
  }

  private PGraphics spmAnaglyph(PGraphics bufL, PGraphics bufR) {
    // anaglyph interlace merge left and right images
    // reuse left image for faster performance
    bufL.loadPixels();
    bufR.loadPixels();

    color cl = 0;
    color cr = 0;
    float r = 0;
    float g = 0;
    float b = 0;
    float rl = 0;
    float gl = 0;
    float bl = 0;
    float rr = 0;
    float gr = 0;
    float br = 0;

    int len = bufL.pixels.length;
    int i = 0;
    while (i < len) {
      cl = bufL.pixels[i];
      cr = bufR.pixels[i];
      rl = red(cl);
      gl = green(cl);
      bl = blue(cl);
      rr = red(cr);
      gr = green(cr);
      br = blue(cr);
      r=floor(0.606100*rl + 0.400484*gl + 0.126381 * bl - 0.0434706*rr - 0.0879388*gr - 0.00155529*br);
      g=floor(-0.0400822*rl - 0.0378246*gl - 0.0157589*bl + 0.078476*rr + 1.03364*gr - 0.0184503*br);
      b=floor(-0.0152161*rl - 0.0205971*gl - 0.00546856*bl - 0.0721527*rr - 0.112961*gr + 1.2264*br);
      bufL.pixels[i] = color(r, g, b);
      i++;
    }
    bufL.updatePixels();
    return bufL;
  }

  private PGraphics colorAnaglyph(PGraphics bufL, PGraphics bufR) {
    // color anaglyph merge left and right images
    // reuse left image for faster performance
    bufL.loadPixels();
    bufR.loadPixels();
    color cl = 0;
    color cr = 0;
    float r = 0;
    float g = 0;
    float b = 0;
    int len = bufL.pixels.length;
    int i = 0;
    while (i < len) {
      cl = bufL.pixels[i];
      cr = bufR.pixels[i];
      bufL.pixels[i] = color(red(cl), green(cr), blue(cr));
      i++;
    }
    bufL.updatePixels();
    return bufL;
  }

  private PGraphics redCyanAnaglyph(PGraphics bufL, PGraphics bufR) {
    // color anaglyph merge left and right images
    // reuse left image for faster performance
    bufL.loadPixels();
    bufR.loadPixels();
    color cl = 0;
    color cr = 0;
    float r = 0;
    float g = 0;
    float b = 0;

    int len = bufL.pixels.length;
    int i = 0;
    while (i < len) {
      cl = bufL.pixels[i];
      cr = bufR.pixels[i];
      r=floor(0.29900*red(cl) + 0.58700*green(cl) + 0.11400*blue(cl));
      g=floor(0.29900*red(cr) + 0.58700*green(cr) + 0.11400*blue(cr));
      b=g;
      bufL.pixels[i] = color(r, g, b);
      i++;
    }
    bufL.updatePixels();
    return bufL;
  }

  private PGraphics duboisAnaglyph(PGraphics bufL, PGraphics bufR) {
    // dubois anaglyph merge left and right images
    // reuse left image for faster performance
    bufL.loadPixels();
    bufR.loadPixels();

    color cl = 0;
    color cr = 0;
    float r = 0;
    float g = 0;
    float b = 0;
    float rl = 0;
    float gl = 0;
    float bl = 0;
    float rr = 0;
    float gr = 0;
    float br = 0;

    int len = bufL.pixels.length;
    int i = 0;
    while (i < len) {
      cl = bufL.pixels[i];
      cr = bufR.pixels[i];
      rl = red(cl);
      gl = green(cl);
      bl = blue(cl);
      rr = red(cr);
      gr = green(cr);
      br = blue(cr);
      r=floor(0.456100*rl + 0.500484*gl + 0.176381 * bl - 0.0434706*rr - 0.0879388*gr - 0.00155529*br);
      g=floor(-0.0400822*rl - 0.0378246*gl - 0.0157589*bl + 0.378476*rr + 0.73364*gr - 0.0184503*br);
      b=floor(-0.0152161*rl - 0.0205971*gl - 0.00546856*bl - 0.0721527*rr - 0.112961*gr + 1.2264*br);
      bufL.pixels[i] = color(r, g, b);
      i++;
    }
    bufL.updatePixels();
    return bufL;
  }
}
