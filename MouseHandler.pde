// Mouse input

public void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  float s = e * SHIFT;
  if ((scale-s) < MAX_SCALE && (scale-s) > MIN_SCALE) {
    scale -= s;
  } 
  if (DEBUG) println("scale = "+scale);
}

public void mouseDragged() {
  float deltaY = mouseY-pmouseY;
  float deltaX = mouseX-pmouseX;
  float DELTA = 1.0/1.58;
  xdelta += DELTA * deltaX;
  ydelta += DELTA * deltaY;
  if (DEBUG) println("xdelta "+xdelta + " "+ydelta);
}


public void mousePressed() {
  if (DEBUG) println("mousePressed()");
}

public void mouseReleased() {
  if (DEBUG) println("mouseReleased()");
}

public void mouseClicked() {
  if (DEBUG) println("mouseClicked()");
}
