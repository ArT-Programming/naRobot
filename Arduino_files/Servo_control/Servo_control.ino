#include <Servo.h>
//#include <SoftwareSerial.h>
static const int n = 2; //number of servo motors
Servo servo[n];  // create servo object to control a servo
//SoftwareSerial servoData(10,11);
void setup()
{
  servo[0].attach(3);
  servo[1].attach(5);
  
  servo[0].write(90);
  servo[1].write(40);
  delay(1000);
  
  Serial.begin(9600);
 // servoData.begin(9600);
}

void loop(){
  int value[n];
  
  if (Serial.available()) {
    if(Serial.read() == 0xFF){
      delay(10);
      
      value[0] = Serial.read();
      value[1] = Serial.read();

    
      servo[0].write(value[0]);
      servo[1].write(value[1]);

      //delay(200);
      
      Serial.flush();   
    }
  }  
}

/*void debug(){
  Serial.print("servo value 0: ");
     // Serial.print(i);
      //Serial.print("  ");
      Serial.println(value[0]);
      
       Serial.print("servo value 1: ");
     // Serial.print(i);
     // Serial.print("  ");
      Serial.println(value[1]);
      //Serial.print(i);
      
}*/


