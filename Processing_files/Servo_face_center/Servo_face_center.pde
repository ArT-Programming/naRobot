import gab.opencv.*;
import ipcapture.*;
import java.awt.Rectangle;
import processing.serial.*;

IPCapture cam;
OpenCV opencv;
Serial myPort;  // Create object from Serial class
static final int servos = 2;
int val[] = new int[servos];
int threshold = 30;
int speed = 2;

color red = color(255, 0, 0, 100);
color green = color(0, 255, 0, 100);

void setup() {
  val[0] = 90;
  val[1] = 40;

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 115200);
  printArray(Serial.list());

  size(640, 480);

  cam = new IPCapture(this, "http://192.168.0.151:8080/video", "", "");
  cam.start();

  opencv = new OpenCV(this, 320, 240);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
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

  scale(2);
  image(cam, 0, 0);
  stroke(255);
  strokeWeight(3);
  for (int i = 0; i < faces.length; i++) {
    rectMode(CORNER);
    if (i == smallIndex) {
      fill(green);
      //println(distVector[i]);
      calcServoValues(distVector[i]);
      sendServoValues();
    } else {
      fill(red);
    }
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
}

void calcServoValues(PVector distVector) {
  if(distVector.x < -threshold){
    val[0] += speed;
  }else if(distVector.x > threshold){
    val[0] -= speed;
  }
  val[0] = clipValue(val[0],30,150);
  
  if(distVector.y < -threshold){
    val[1] += speed;
  }else if(distVector.y > threshold){
    val[1] -= speed;
  }
  val[1] = clipValue(val[1],10,90);
}

int clipValue(int val, int min, int max){
  if(val < min) return min;
  if(val > max) return max;
  return val;
}

void sendServoValues() {
  String values = "x" + join(nfc(val), ",");
  //println(values);
  myPort.write(values);
}