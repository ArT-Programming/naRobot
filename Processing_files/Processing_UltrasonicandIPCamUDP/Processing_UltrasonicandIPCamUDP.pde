import hypermedia.net.*; //UDP library by Stephane Cousot
import gab.opencv.*;
import ipcapture.*;
import java.awt.Rectangle;

IPCapture cam;
UDP udp;  // define the UDP object
OpenCV opencv;

String remoteIP = "192.168.0.199"; //Hardcoded FTW!
int remotePort = 8080;
boolean remoteFound = true; // only send to remote if we know where to send it to

int listenPort = 8080;

byte val[] = new byte[2]; // values to send
int timeBetweenSends = 10; // send every 10 ms (draw() is probably not that fast anyway, so just as often as we can)
long lastSend = 0; // last time send
long lastRecieved = 0;
boolean doSpin = false;
long startSpinTime = 0;
boolean doRampage = false;
int spinDirection = 1;
long lastDirectionTime = 0;

int medianDistance[] = new int[3];
int distanceArray[][] = new int[3][3];
int distanceThreshold = 100;
int currentReading = 0;

void setup() {
  // create window and setup a simple coordinate system
  size(500, 500);
  
  cam = new IPCapture(this, "http://192.168.0.151:8080/video", "", "");
  cam.start();
  
  opencv = new OpenCV(this, 320,240);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  
  // create a new datagram connection on port 6000
  // and wait for incomming message
  println("Setting up UDP listener on Port ", listenPort);
  println("Sending to ", remoteIP, ":", remotePort);
  udp = new UDP( this, listenPort );
  udp.listen( true );

  //println("Waiting for incomming UPD package...");
}

void draw() {
  background(150);
  if (cam.isAvailable()) {
    cam.read();
  }
  opencv.loadImage(cam);
  Rectangle[] faces = opencv.detect();
  
  image(cam,0,0);
  stroke(255);
  strokeWeight(3);
  for (int i = 0; i < faces.length; i++) {
    rectMode(CORNER);
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  
  drawSensorValues();
  drawCoordinateSystem();
  
  if (remoteFound) {
    if(doRampage && (faces.length > 0 || doSpin)){
      doSpin = spin();
    }
    else if (doRampage) {
      rampage();
    } 
    else if (mousePressed) {
      calculateXY();
    } 
    else {
      val[0] = 0;
      val[1] = 0;
    }

    if (millis() > lastSend + timeBetweenSends) {
      sendData();
    }
  }
}

// send zero when program exits
void exit() {
  val[0] = 0;
  val[1] = 0;
  sendData();
  super.exit();
}

// reset to zero when mouse button release
void mouseReleased() {
  val[0] = 0;
  val[1] = 0;
}

void keyPressed() {
  doRampage = !doRampage;
}

// map mouse values between -100 and 100
void calculateXY() {
  if (mouseX >= 0 && mouseX <= width)
    val[1] = byte(((mouseX - width/2.)/width)*200);
  if (mouseY >= 0 && mouseY <= height)
    val[0] = byte(((mouseY - height/2.)/height)*200);
}

boolean spin(){
  if(!doSpin){
    randomDirection();
    startSpinTime = millis();
    
  }
  if(millis() < startSpinTime + 5000){
    val[1] = byte(50 * spinDirection);
    val[0] = 0;
    return true;
  }
  return false; //continue
}

void randomDirection(){
    spinDirection = int(random(2));
    if(spinDirection == 0) spinDirection = -1;
    lastDirectionTime = millis();
}

void rampage() {
  val[0] = -70;
  val[1] = 0;
  for (int i = 0; i < medianDistance.length; i++) {
    if (medianDistance[i] != 0 && medianDistance[i] < distanceThreshold) {
      if(millis() > lastDirectionTime + 5000) randomDirection();
      val[0] = 0;
      val[1] = 60;
    }
  }
}

void drawSensorValues(){
  // draw threshold in red
  noStroke();
  fill(255,0,0,100);
  rectMode(CORNERS);
  rect(0, height-2*distanceThreshold, width, height);
  
  // draw sensor values in blue
  stroke(0,200,255,150);
  strokeWeight(50);
  strokeCap(SQUARE);
  int xOffset = width / (2*medianDistance.length);
  for(int i = 0; i < medianDistance.length; i++){
    int x = (i * width / medianDistance.length) + xOffset;
    int y = 0;
    if(medianDistance[i] != 0)
      y = height - 2*medianDistance[i];
    line(x, height, x, y);
  }
}

void drawCoordinateSystem(){
  stroke(0);
  strokeWeight(3);;
  line(0, height/2, width, height/2);
  line(width/2, 0, width/2, height);
}

// send values as byte array via udp to the remote ip and port
void sendData() {
  lastSend = millis();
  udp.send( val, remoteIP, remotePort );
}

// this port recieved data from ip with port
void receive( byte[] data, String ip, int port ) {	// <-- extended handler ... void receive( byte[] data ) is the default
  // we now know the remote ip and port to send to
  if (!remoteFound) {
    println("Remote found on ", ip, ":", port);
    remoteFound = true;
    remoteIP = ip;
    remotePort = port;
  }
  if(data.length == medianDistance.length){
    for (int i = 0; i < medianDistance.length; i++) {
      distanceArray[i][currentReading] = data[i] & 0xFF;
      medianDistance[i] = getMedian(distanceArray[i]);
    }
  }
  currentReading++;
  currentReading = currentReading % 3;

  lastRecieved = millis();
}

int getMedian(int[] array) {
  IntList values = new IntList();
  for (int i = 0; i < array.length; i++) {
    values.append(array[i]);
  }
  values.sort();
  return values.get(array.length/2);
}