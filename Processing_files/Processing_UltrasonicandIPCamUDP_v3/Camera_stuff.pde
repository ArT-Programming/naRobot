// All camera stuff and image processing goes here
import gab.opencv.*;
import ipcapture.*;
import java.awt.Rectangle;

class CameraFrame extends PApplet {

  IPCapture mobCam;
  OpenCV opencv;
  int w, h;
  PApplet parent;
  long lastFaceTime = 0;
  boolean iSeeFace = false; 

  color red = color(255, 0, 0, 100);
  color green = color(0, 255, 0, 100);

  public CameraFrame(PApplet _parent, int _w, int _h, String _name) {
    super();   
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h);
  }

  public void setup() {
    surface.setLocation(700, 200);
    mobCam = new IPCapture(this, "http://192.168.0.151:8080/video", "", "");
    mobCam.start();

    opencv = new OpenCV(this, 320, 240);
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
    frameRate(60);
    
  }

  public boolean faceDetected() {

    opencv.loadImage(mobCam);
    Rectangle[] faces = opencv.detect();

    if (faces.length > 0) {
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
    }
    return faces.length > 0;
  } 

  public void draw() {
    if (mobCam.isAvailable()) {
      mobCam.read();
    }
    image(mobCam, 0, 0);
    iSeeFace = faceDetected();
  }
}