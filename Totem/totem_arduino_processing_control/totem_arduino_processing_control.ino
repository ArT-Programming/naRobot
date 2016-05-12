#include <Servo.h>

class MotorDriver
{
    int enablePin, forwardsPin, backwardsPin;
  public:
    MotorDriver(int _enable, int _forwards, int _backwards) {
      enablePin = _enable;
      forwardsPin = _forwards;
      backwardsPin = _backwards;
      pinMode(enablePin, OUTPUT);
      pinMode(forwardsPin, OUTPUT);
      pinMode(backwardsPin, OUTPUT);
    }

    void goForwards(int Speed) {
      digitalWrite(forwardsPin, HIGH);
      digitalWrite(backwardsPin, LOW);
      analogWrite(enablePin, Speed);
    }

    void goBackwards(int Speed) {
      digitalWrite(forwardsPin, LOW);
      digitalWrite(backwardsPin, HIGH);
      analogWrite(enablePin, Speed);
    }

    void STOP() {
      digitalWrite(forwardsPin, LOW);
      digitalWrite(backwardsPin, LOW);
      analogWrite(enablePin, 0);
    }
};

static const int n = 3; //number of servo motors
Servo servo[n];  // create servo object to control a servo

MotorDriver arm(5, 6, 7);
MotorDriver body(11, 12, 13);

void setup()
{
  servo[0].attach(3); // pan
  servo[1].attach(9); // tilt 1
  servo[2].attach(10); // tilt 2, mirrored


  servo[0].write(70);
  servo[1].write(90);
  servo[2].write(mirrorServo(90));
  delay(1000);

  Serial.begin(115200);
}

void loop()
{
  // Totem head control
  int value[n];
  digitalWrite(13, LOW);
  if (Serial.available()) {
    if (Serial.find("x")) {
      digitalWrite(13, HIGH);
      for (int i = 0; i < n - 1; i++) {
        value[i] = Serial.parseInt();
      }
      servo[0].write(value[0]);
      servo[1].write(value[1]);
      servo[2].write(mirrorServo(value[1]));
    }

    //Totem body control here
    else if (Serial.find("a")) { // Move arm!
      int moveDir = 0;
      moveDir = Serial.parseInt();

      if (moveDir == 0) {
        arm.STOP();
      }
      else if (moveDir > 0) {
        arm.goForwards(moveDir);
      }
      else if (moveDir < 0) {
        arm.goBackwards(moveDir);
      }
    }

    else if (Serial.find("p")) { // Move body!
      int moveDir = 0;
      moveDir = Serial.parseInt();

      if (moveDir == 0) {
        body.STOP();
      }
      else if (moveDir > 0) {
        body.goForwards(moveDir);
      }
      else if (moveDir < 0) {
        body.goBackwards(moveDir);
      }
    }
  }
}

int mirrorServo(int servoVal) {
  int mirroredServoVal = 180;
  mirroredServoVal -= servoVal;
  return mirroredServoVal;
}


