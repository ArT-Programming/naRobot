// All camera stuff and image processing goes here
import gab.opencv.*;
import ipcapture.*;
import java.awt.Rectangle;

IPCapture cam;
OpenCV opencv;

long lastFaceTime = 0;
color red = color(255, 0, 0, 100);
color green = color(0, 255, 0, 100);

void startCamera(String ip){
  cam = new IPCapture(this, ip, "", "");
  cam.start();
  
  opencv = new OpenCV(this, 320, 240);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
}

void drawCamera(){
  if (cam.isAvailable()) {
    cam.read();
  }
  image(cam,0,0);
}

boolean findFaces(){
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
  return faces.length > 0;
}