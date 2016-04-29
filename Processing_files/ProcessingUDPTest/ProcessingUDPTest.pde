import hypermedia.net.*; //UDP library by Stephane Cousot

UDP udp;  // define the UDP object

String remoteIP = "192.168.0.199"; //Hardcoded FTW!
int remotePort = 8080;
boolean remoteFound = true; // only send to remote if we know where to send it to

int listenPort = 8080;

byte val[] = new byte[2]; // values to send
int timeBetweenSends = 10; // send every 10 ms
long lastSend = 0; // last time send
long lastRecieved = 0;
int timeout = 10000; //timeout after 10 seconds. Look for reciever again

void setup() {
  // create window and setup a simple coordinate system
  size(500,500);
  background(100);
  stroke(0);
  strokeWeight(3);
  line(0 , height/2 , width , height/2);
  line(width/2 , 0 , width/2 , height);
  
  // create a new datagram connection on port 6000
  // and wait for incomming message
  println("Setting up UDP listener on Port ", listenPort);
  udp = new UDP( this, listenPort );
  udp.listen( true );
  
  println("Waiting for incomming UPD package...");
}

void draw() {
  if(remoteFound){
    
   /* if(millis() > lastRecieved + timeout){
      println("connection timed out");
      println("Waiting for incomming UPD package...");
      remoteFound = false;
    }
    else{*/
      if(mousePressed){
        calculateXY();
      }
      
      if(remoteFound && millis() > lastSend + timeBetweenSends){
        sendData();
      }
    //}
  }
}

// map mouse values between -100 and 100
void calculateXY() {
  if(mouseX >= 0 && mouseX <= width)
    val[1] = byte(((mouseX - width/2.)/width)*200);
  if(mouseY >= 0 && mouseY <= height)
    val[0] = byte(((mouseY - height/2.)/height)*200);
}

// reset to zero when mouse button release
void mouseReleased() {
  val[0] = 0;
  val[1] = 0;
}

// send values as byte array via udp to the remote ip and port
void sendData(){
  lastSend = millis();
  udp.send( val, remoteIP, remotePort );
}

// this port recieved data from ip with port
void receive( byte[] data, String ip, int port ) {	// <-- extended handler ... void receive( byte[] data ) is the default
  // we now know the remote ip and port to send to
  if(!remoteFound){
    println("Remote found on ", ip, ":", port);
    remoteFound = true;
    remoteIP = ip;
    remotePort = port;
  }
  
  lastRecieved = millis();
  printByteArray(data);
  
  // parse the data and write it out in the console
  //data = subset(data, 0, data.length);
  //String message = new String( data );
  //println( "receive: \""+message+"\" from "+ip+" on port "+port );
}

void printByteArray(byte[] data){
  for(int i = 0; i < data.length; i++){
    if(data[i] < 100){
      print(' ');
      if(data[i] < 10){
        print(' ');
      }
    }
    print(data[i]);
    if(i == data.length-1){
      println();
    }else{
      print(" , ");
    }
  }
}