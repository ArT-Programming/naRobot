import hypermedia.net.*; //UDP library by Stephane Cousot
import gab.opencv.*;
import ipcapture.*;
import java.awt.Rectangle;

IPCapture cam;
UDP udp;  // define the UDP object
OpenCV opencv;

String remoteIP = "192.168.0.199"; //Hardcoded FTW!
int remotePort = 8080;
boolean remoteFound = false; // only send to remote if we know where to send it to

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

static final int medianCount = 3;
static final int sensorCount = 5;
int medianDistance[] = new int[sensorCount];
int distanceArray[][] = new int[sensorCount][medianCount];
int distanceThreshold = 120;
int currentReading = 0;
long lastFaceTime = 0;

static final int servos = 2;
int servoVal[] = new int[servos];
int threshold = 30;
int speed = 1;
color red = color(255, 0, 0, 100);
color green = color(0, 255, 0, 100);

byte rampageSpeed = -70;

void setup() {
  servoVal[0] = 90;
  servoVal[1] = 40;
  
  // create window and setup a simple coordinate system
  size(500, 500);
  
  cam = new IPCapture(this, "http://192.168.0.151:8080/video", "", "");
  cam.start();
  
  opencv = new OpenCV(this, 320, 240);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  
  // create a new datagram connection on port 6000
  // and wait for incomming message
  println("Setting up UDP listener on Port ", listenPort);
  //println("Sending to ", remoteIP, ":", remotePort);
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
  
  float faceDist[] = new float[faces.length];
  PVector distVector[] = new PVector[faces.length];
  for (int i = 0; i < faces.length; i++) {
    PVector faceCenter = new PVector(faces[i].x+(faces[i].width/2), faces[i].y+(faces[i].height/2));
    distVector[i] = new PVector(faceCenter.x - 320/2, faceCenter.y - 240/2);
    faceDist[i] = distVector[i].magSq();
  }

  int smallIndex = 0;
  for (int i = 0; i < faces.length; i++) {
    if (faceDist[i] < faceDist[smallIndex]) {
      smallIndex = i;
    }
  }
  
  image(cam,0,0);
  stroke(255);
  strokeWeight(3);
  for (int i = 0; i < faces.length; i++) {
    rectMode(CORNER);
    if (i == smallIndex) {
      fill(green);
      //println(distVector[i]);
      calcServoValues(distVector[i]);
      //sendServoValues();
    } else {
      fill(red);
    }
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  
  drawSensorValues();
  drawCoordinateSystem();
  
  if (remoteFound) {
    if(doRampage && (faces.length > 0 || doSpin)){
      //doSpin = spin();
      lastFaceTime = millis();
      val[0] = 0;
      val[1] = 0;
    }
    else if (doRampage) {
      if(millis() > lastFaceTime + 1000){
        servoGoTo(90,40);
      }
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

void servoGoTo(int x, int y){
  if(servoVal[0] < x){
    servoVal[0] += speed;
  }else if(servoVal[0] > x){
    servoVal[0] -= speed;
  }
  servoVal[0] = clipValue(servoVal[0],30,150);
  
  if(servoVal[1] < y){
    servoVal[1] += speed;
  }else if(servoVal[1] > y){
    servoVal[1] -= speed;
  }
  servoVal[1] = clipValue(servoVal[1],10,90);
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

void calcServoValues(PVector distVector) {
  if(distVector.x < -threshold){
    servoVal[0] += speed;
  }else if(distVector.x > threshold){
    servoVal[0] -= speed;
  }
  servoVal[0] = clipValue(servoVal[0],30,150);
  
  if(distVector.y < -threshold){
    servoVal[1] += speed;
  }else if(distVector.y > threshold){
    servoVal[1] -= speed;
  }
  servoVal[1] = clipValue(servoVal[1],10,90);
}

int clipValue(int input, int min, int max){
  if(input < min) return min;
  if(input > max) return max;
  return input;
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
  val[0] = rampageSpeed;
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
  byte[] b = {val[0], val[1], byte(servoVal[0]), byte(servoVal[1])};
  //println("Chair:" ,b[0],b[1], "\t\tServo:",b[2],b[3]);
  udp.send( b, remoteIP, remotePort );
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
  currentReading = currentReading % medianCount;

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