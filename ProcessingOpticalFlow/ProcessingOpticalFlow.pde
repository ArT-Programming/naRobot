import processing.video.*;
import gab.opencv.*;

Capture cam;
OpenCV opencv;

//TODO: How can the robot detect its own position?

PVector[][] flow = new PVector[16][12];
PVector robotPos;
PVector maxFlowPos;
float speed = 5;
float minFlowMagThreshold = 0.002;
int ROI = 40;


void setup(){
  size(640,480);
  opencv = new OpenCV(this, 640,480);
  
  String logiCam = "name=Logitech HD Webcam C310,size=640x480,fps=30";
  cam = new Capture(this , 640 , 480 , logiCam);
  //cam = new Capture(this, 640,480);
  cam.start();
  robotPos = new PVector(width/2, height/2);
  maxFlowPos = robotPos;
  rectMode(CENTER);
}

void draw(){
  background(0);
  opencv.loadImage(cam);
  image(cam, 0, 0);
  
  if(millis() > 8000){ //Sleep the first few seconds to avoid noise when the camera starts
    opencv.calculateOpticalFlow();
    
    getFlows();
    maxFlowPos = findMaxFlowPosition();
    calculateDirection();
  }
}

void getFlows(){
  stroke(255,0,0);
  strokeWeight(5);
  int flowScale = 200;
  for(int y = 0; y < height; y += ROI){
    for(int x = 0; x < width; x += ROI){
      flow[x/ROI][y/ROI] = opencv.getAverageFlowInRegion(x , y , ROI , ROI);
      line(x + ROI/2 , y + ROI/2 , x + ROI/2 + flow[x/ROI][y/ROI].x * flowScale , y + ROI/2 + flow[x/ROI][y/ROI].y * flowScale);
    }
  }
}

PVector findMaxFlowPosition(){
  float max = 0;
  PVector maxPos = new PVector(0,0);
  boolean foundMagAboveThreshold = false;
  for(int y = 0; y < height; y += ROI){
    for(int x = 0; x < width; x += ROI){
      float magnitude = flow[x/ROI][y/ROI].magSq();
      if(magnitude > max && magnitude > minFlowMagThreshold){
        max = magnitude;
        maxPos.x = x + ROI/2;
        maxPos.y = y + ROI/2;
        foundMagAboveThreshold = true;
      }
    }
  }
  
  if(foundMagAboveThreshold){
    //Draw an ellipse where the largest flow was detected
    strokeWeight(1);
    stroke(0);
    fill(255);
    ellipse(maxPos.x , maxPos.y , 20 , 20);
    return maxPos;
  }else{
    return maxFlowPos;
  }
}

void calculateDirection(){
  PVector direction  = new PVector(0,0,0);
  direction.x += maxFlowPos.x - robotPos.x;
  direction.y += maxFlowPos.y - robotPos.y;
  if(abs(direction.x) > ROI/10 || abs(direction.y) > ROI/10){
    direction = direction.normalize();
  }else{
    direction = new PVector(0,0,0);
  }
  
  robotPos.x += direction.x * speed;
  robotPos.y += direction.y * speed;
  
  // Draw a rect to simulate robot movement;
  stroke(0,0,255);
  strokeWeight(1);
  fill(100,200);
  rect(robotPos.x , robotPos.y , 40 , 40);
}

void captureEvent(Capture c){
  c.read();
}