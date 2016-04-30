#include <Servo.h>
static const int n = 2; //number of servo motors
Servo servo[n];  // create servo object to control a servo

void setup()
{
  servo[0].attach(3);
  servo[1].attach(5);
  
  servo[0].write(90);
  servo[1].write(40);
  delay(1000);
  
  Serial.begin(115200);
}

void loop(){
  int value[n];
  
  if (Serial.available()) {
    if(Serial.read() == 0xFF){
    for(int i = 0; i < n; i++){
      value[i] = Serial.read();
      servo[i].write(value[i]);
      }
    }
  }
}



