// All key and mouse inputs go here

// reset to zero when mouse button release
void mouseReleased() {
  val[0] = 0;
  val[1] = 0;
}

// map mouse values between -100 and 100
void calculateXY() {
  if (mouseX >= 0 && mouseX <= width)
    val[1] = byte(((mouseX - width/2.)/width)*200);
  if (mouseY >= 0 && mouseY <= height)
    val[0] = byte(((mouseY - height/2.)/height)*200);
}

void keyPressed() {
  switch(key) {
  case ' ': 
    doRampage = !doRampage;
    break;
    // for changing speed values
  case CODED:
    if (keyCode == UP) {
      command = 4;
      break;
    } else if (keyCode == DOWN) {
      command = 2;
      break;
    }
    break;
  }
}