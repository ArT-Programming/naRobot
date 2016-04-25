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
int distance[] = new int[3];
boolean doRampage = false;

int distanceArray[][] = new int[3][3];
int currentReading = 0;


void setup() {
  // create window and setup a simple coordinate system
  size(500, 500);
  background(100);
  stroke(0);
  strokeWeight(3);
  line(0, height/2, width, height/2);
  line(width/2, 0, width/2, height);

  // create a new datagram connection on port 6000
  // and wait for incomming message
  println("Setting up UDP listener on Port ", listenPort);
  udp = new UDP( this, listenPort );
  udp.listen( true );

  println("Waiting for incomming UPD package...");
}

void draw() {
  background(100);
  if (remoteFound) {

    if (doRampage) {
      //calculateXY();
      rampage();
    }
    else if (mousePressed){
      calculateXY();
    }
    else{
      val[0] = 0;
      val[1] = 0;
    }

    for (int i = 0; i < distance.length; i++) {
      if (distance[i] != 0 && distance[i] < 100) {
        val[0] = 0;
       // val[1] = 0;
      }
    }

    if (remoteFound && millis() > lastSend + timeBetweenSends) {
      sendData();
    }
  }
}

void keyPressed(){
  doRampage = !doRampage;
}

void exit(){
  val[0] = 0;
  val[1] = 0;
  sendData();
  super.exit();
}
  

// map mouse values between -100 and 100
void calculateXY() {
  if (mouseX >= 0 && mouseX <= width)
    val[1] = byte(((mouseX - width/2.)/width)*200);
  if (mouseY >= 0 && mouseY <= height)
    val[0] = byte(((mouseY - height/2.)/height)*200);
}

void calcMidValue(){
  for(int i = 0; i < 3; i++){
    int mid = sortArray(3, distanceArray[i]);
    distance[i] = mid;
    println(i, ": ", mid);
    
  }
}

int sortArray(int size, int x[]){
  int y[] = new int[size];
  for(int i = 0; i < size; i++){
    int element = 0;
    for(int j = 0; j < size; j++){
      if(x[i] > x[j]) element++;
      if(x[i] == x[j]) element++;
    }
    y[element] = x[i];
  }
  return y[size/2];
}

void rampage(){
  val[0] = -70;
  val[1] = 0;
  calcMidValue();
  for (int i = 0; i < distance.length; i++) {
      if (distance[i] != 0 && distance[i] < 100) {
        val[0] = 0;
        val[1] = 60;
      }
  }
}

// reset to zero when mouse button release
void mouseReleased() {
  val[0] = 0;
  val[1] = 0;
}

// send values as byte array via udp to the remote ip and port
void sendData() {
  lastSend = millis();
  udp.send( val, remoteIP, remotePort );
}

// this port recieved data from ip with port
void receive( byte[] data, String ip, int port ) {	// <-- extended handler ... void receive( byte[] data ) is the default
  // we now know the remote ip and port to send to
  if (!remoteFound) {
    println("Remote found on ", ip, ":", port);
    remoteFound = true;
    remoteIP = ip;
    remotePort = port;
  }

  for (int i = 0; i < data.length; i++) {
    distanceArray[i][currentReading] = data[i] & 0xFF;
  }
  currentReading++;
  currentReading = currentReading % 3;

  lastRecieved = millis();
}