#include <Servo.h>
static const int n = 3; //number of servo motors
Servo servo[n];  // create servo object to control a servo

int mirrorServo(int servoVal) {
  int mirroredServoVal = 180;
  mirroredServoVal -= servoVal;
  return mirroredServoVal;
}

void setup()
{
  servo[0].attach(3); // pan
  servo[1].attach(5); // tilt 1
  servo[2].attach(7); // tilt 2, mirrored


  servo[0].write(90);
  servo[1].write(40);
  servo[2].write(mirrorServo(40));
  delay(1000);

  Serial.begin(115200);
}

void loop()
{
  // Totem head control
  int value[n];
  if (Serial.find("x")) {
    for (int i = 0; i < n-1; i++) {
      value[i] = Serial.parseInt();
    }
    servo[0].write(value[0]);
    servo[1].write(value[1]);
    servo[2].write(mirrorServo(value[2]));
  }
  
  //Totem body control here
}



