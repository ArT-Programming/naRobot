static final int servos = 2;
int servoVal[] = new int[servos];
int speed = 1;
int threshold = 30;

void resetServos(){
  servoVal[0] = 90;
  servoVal[1] = 45;
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