// USB keyboard input

public void keyPressed() {
  if (DEBUG) println("key="+key+" keyCode="+keyCode);
  lastKey = key;
  lastKeyCode = keyCode;
}

// Process key from main loop not in keyPressed()
void keyUpdate() {
  if (lastKey==0) return;

  // Move photo with arrow keys  
  if (lastKeyCode == RIGHT ) {
  } else if (lastKeyCode == DOWN ) {
  } else if (lastKeyCode == LEFT ) {
  } else if (lastKeyCode == UP ) {
  } else if (lastKey == ENTER || lastKey == RETURN ||  lastKeyCode == 66) {  // Enter reset center photo
  } else if (lastKey == '+' || lastKey == '=' || lastKeyCode == 139 ) { // zoom in
    if (scale < MAX_SCALE) {
      scale += SHIFT;
    }
    if (DEBUG) println("scale="+scale);
  } else if (lastKey == '-' || lastKeyCode == 45 || lastKeyCode == 140  ) { // zoom out
    if (scale > MIN_SCALE) {
      scale -= SHIFT;
    }
    if (DEBUG) println("scale="+scale);
  } else if (lastKey == 'l' || lastKey =='L') {
  } else if (lastKey == 'r' || lastKey == 'R') {  // R Reset
    parallax = 0;
    xdelta = 0;
    ydelta = 0;
    scale = SCALE;
  } else if (lastKey == 'd' || lastKey == 'D') {  // D for DEBUG
    // DEBUG output
    println("xdelta="+xdelta + " ydelta="+ydelta);
    println("scale="+scale + " parallax="+parallax);
    println(render.getModeString() +" mode="+render.getMode());
  } else if (lastKey == 'x' || lastKey =='X') {  // X  swap left and right
    render.setCrosseye(!render.getCrosseye());
  } else if ( lastKeyCode == 67 || lastKeyCode == 111 ) {  // backspace
  } else if (lastKey == ' ' || lastKeyCode == 61 /* tab */  /*|| lastKeyCode == 24  volume up */) {  // space or tab,
  } else if (/*lastKeyCode == 25 volume down  ||*/ lastKey == 'z' || lastKey == 'Z') {  // vol down lastKey
  } else if (lastKeyCode == 122 || lastKeyCode == 135 || lastKeyCode == 148 || lastKeyCode == 2) {  // HOME, show first photo
    if (DEBUG) println("first photo");
  } else if (lastKeyCode == 123 || lastKeyCode == 129 || lastKeyCode == 3) {  // END, show last photo
    if (DEBUG) println("last photo");
  } else if (lastKey == 's' || lastKey =='S' || lastKeyCode == 85) {  // S  slideshow toggle start/stop
  } else if (lastKeyCode == 86) {  // Slideshow stop
  } else if (lastKey == 'e' || lastKey =='E') {  // increase window depth
    parallax += 2;  // too much change can cause eyestrain
    if (DEBUG) println("scale="+scale + " parallax="+parallax);
  } else if (lastKey == 'w' || lastKey =='W') {  // decrease window depth
    parallax -= 2;  // too much change can cause eyestrain
    if (DEBUG) println("scale="+scale + " parallax="+parallax);
  } else if (lastKey == 'i' || lastKey =='I') {  // information about photo
  } else if (lastKey == 't' || lastKey =='T') {  // Title introduction screen
  } else if (lastKey >= '0' && lastKey <= '9' ) {
    render.setMode(lastKey-'0');
    if (DEBUG) println(render.getModeString() +" mode="+render.getMode());
  } else if (lastKey == 'a' || lastKey == 'A' ) {
    render.setMode(10);
    if (DEBUG) println(render.getModeString() +" mode="+render.getMode());
  } else {
    // show legend or menu bar etc.
  }
  //KEYCODE_CHANNEL_UP      = 166
  //KEYCODE_CHANNEL_DOWN    = 167;
  lastKey = 0;
  lastKeyCode = 0;
}
