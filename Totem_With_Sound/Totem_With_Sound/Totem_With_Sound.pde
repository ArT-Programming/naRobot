import processing.serial.*;
import ddf.minim.*;

Minim minim;
static final int tracks = 4;
AudioPlayer player[] = new AudioPlayer[tracks];
boolean audioOn[] = new boolean[tracks];

//********************** Objects and Variales ****************

Serial myPort;  // Create object from Serial class
static final int servos = 2;
int val[] = new int[servos + 2];
color c[] = new color[servos];
int editColumn = -1;
int prevColumn = 0;
int prevVal = 0;
int speed = 100;

int body = 0;
int arm = 0;

//********************** Setup *******************************

void setup() 
{
  val[0] = 70;
  val[1] = 90;
  arm = 0;
  body = 0;


  rectMode(CORNERS); 
  size(1000, 720, P3D);



  minim = new Minim(this);
  for (int i = 0; i < tracks; i++ ) {
    audioOn[i] = false;
  }
  // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  player[0] = minim.loadFile("WarOfWorlds.mp3");
  player[1] = minim.loadFile("jazz1.mp3");
  player[2] = minim.loadFile("jazz2.mp3");
  player[3] = minim.loadFile("jazz3.mp3");

  for (int i = 0; i < servos; i++) {
    c[i] = rndClr();
  }
  //*
  String portName = Serial.list()[6];
  myPort = new Serial(this, portName, 115200);
  printArray(Serial.list());
  //*/
  sendData();
}

//********************** Draw ********************************

void draw() {
  UpdateVal();

  // Draw interface
  background(230);
  stroke(100);
  for (int i = 0; i < servos; i++) {
    fill(c[i]);
    line(width/float(servos)*i, 0, width/float(servos)*i, height);
    rect(i*(width/float(servos)), height-(val[i]*4), (i+1)*(width/float(servos)), height);
  }
  sendData();
}

//********************** 1st frame after mouse pressed *******

void mousePressed() {
  editColumn = mouseOnColumn(true);
  if (editColumn != -1) {
    prevColumn = editColumn;
    prevVal = (height - mouseY) / 4;
  }
}

//********************** 1st frame after mouse released ******
void keyReleased() {
  if (key == 'w') arm = 0; //moveArm(100);
  else if (key == 's') arm = 0; //moveArm(100);
  else if (key == 'a') body = 0; //moveBody(100);
  else if (key == 'd') body = 0; // moveBody(100);
}

void keyPressed() {
  if (key == '0') audioOn[0] = !audioOn[0]; 
  else if (key == '1') audioOn[1] = !audioOn[1]; 
  else if (key == '2') audioOn[2] = !audioOn[2]; 
  else if (key == '3') audioOn[3] = !audioOn[3]; 
  else if (key == ' ') {
    for (int i = 0; i < tracks; i++) {
      player[i].rewind();
    }
  }
  /* else if (key == '4') audioOn[4] = !audioOn[4]; 
   else if (key == '5') audioOn[5] = !audioOn[5]; 
   else if (key == '6') audioOn[6] = !audioOn[6]; 
   else if (key == '7') audioOn[7] = !audioOn[7]; 
   else if (key == '8') audioOn[8] = !audioOn[8]; */

  for (int i = 0; i < tracks; i++) {
    if (audioOn[i]) player[i].play();
    else player[i].pause();
  }
}

void mouseReleased() {
  editColumn = -1;
}

//********************** find which column mouse is on *******

int mouseOnColumn(boolean includeOutsideBounds) {
  for (int i = 1; i <= servos; i++) {
    if (mouseX < i * width/float(servos) && mouseX >= 0) {
      return i-1;
    }
  }
  if (includeOutsideBounds) {
    if (mouseX < 0) return 0;
    else if (mouseX > width) return servos-1;
  }
  return -1;
}

//********************** update val[] array ******************

void UpdateVal() {
  if (keyPressed) {
    // continous update column
    if (key == 'c') {

      int currColumn = mouseOnColumn(false);
      if (currColumn != -1) {
        int currVal = (height - mouseY) / 4;

        if (currColumn > prevColumn) {
          int columnSpan = currColumn - prevColumn;
          for (int i = 0; i <= columnSpan; i++) {
            val[i+prevColumn] = int((i/float(columnSpan))*currVal + (1-i/float(columnSpan))*prevVal);
          }
        } else if (currColumn < prevColumn) {
          int columnSpan = prevColumn - currColumn;
          for (int i = columnSpan; i >= 0; i--) {
            val[i+currColumn] = int((i/float(columnSpan)) * prevVal + (1-i/float(columnSpan))*currVal);
          }
        } else {
          val[currColumn] = (height - mouseY) / 4;
        }

        prevVal = currVal;
        editColumn = currColumn;
        prevColumn = currColumn;
      }
    }

    // edit all columns
    else if (key == 'x') {
      for (int i = 0; i < servos; i++) {
        val[i] = (height - mouseY) / 4;
      }
      editColumn = mouseOnColumn(true);
    } else if (key == 'w') arm = 255; // moveArm(speed + 100);
    else if (key == 's') arm = -100;// moveArm(speed - 100);
    else if (key== 'a') body = 100; //moveBody(speed + 100);
    else if (key == 'd') body = -100;//moveBody(speed - 100);
  }

  // edit one column
  else {
    for (int i = 0; i < servos; i++) {
      if (editColumn == i) val[i] = (height - mouseY) / 4;
    }
  }

  for (int i = 0; i < servos; i++) {
    val[i] = clipValue(val[i], 0, 180);
  }
}

//********************** clip int values *********************

int clipValue(int value, int min, int max) {
  if (value < min) return min;
  else if (value > max) return max;
  return value;
}

//********************** get a random color ******************


color rndClr() {
  return color(random(255), random(255), random(255));
}

// send zero when program exits
void exit() {

  // back to position 
  val[0] = 70;
  val[1] = 90;
  body = 0;
  arm = 0;
  sendData();
  super.exit();
}

void sendData() {
  val[2] = arm; 
  val[3] = body;

  String values = "x" + join(nfc(val), ",");
  myPort.write(values);
}