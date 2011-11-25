//Arduino Ethernet Shield Code
//Framework borrowed from scienceproge.com
//Additional modifications and refinement for servo use by sklemp@gmail.com
//Email sklemp@gmail.com if you have any issues or questions
#include <SPI.h>
#include <Client.h>
#include <Ethernet.h>
#include <Server.h>
#include <Udp.h>
#include <Servo.h>
Servo tilt;
Servo pan;
int panpos = 90;
int tiltpos = 90;
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED }; //physical mac address
byte ip[] = { 10, 0, 0, 9 };           // ip in lan
byte gateway[] = { 192, 168, 0, 1 };            // internet access via router
byte subnet[] = { 255, 255, 255, 0 };                   //subnet mask
Server server(80);                                      //server port
String readString = String(30); //string for fetching data from address
void setup(){
  Ethernet.begin(mac, ip, gateway, subnet);
  Serial.begin(9600);
  tilt.attach(3);
  pan.attach(9);
  tilt.write(90);
  pan.write(90);
}
void loop(){
// Create a client connection
Client client = server.available();
  if (client) {
    while (client.connected()) {
   if (client.available()) {
    char c = client.read();
     //read char by char HTTP request
    if (readString.length() < 100)
      {
        //store characters to string
        readString += c;
      }
        Serial.print(c);
        if (c == '\n') {
          if (readString.indexOf("?") <0)
          {
            //do nothing
          }
          else
          {           
             if(readString.indexOf("UP=UP") >0)
               {
                 movetiltupstep();
               }
             else if(readString.indexOf("DN=DN") >0)
               {
                 movetiltdownstep();
               }
             else if(readString.indexOf("LT=LT") >0)
               {
                 movepanleftstep();
               }
             else if(readString.indexOf("RT=RT") >0)
               {
                 movepanrightstep();
               }
             else if(readString.indexOf("CN=CN") >0)
               {
                 center();
               }
          }
          // now output HTML data starting with standard header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();
          //set background to green
          client.print("<body style=background-color:green>");
          client.println("<hr />");
          client.println("<center>");
          client.println("<h1>Camera control</h1>");
          client.println("<form method=get name=SERVO>");
          client.println("<input type=submit value=UP name=UP style=\"width:100px\"><br>");
          client.println("<input type=submit value=LT name=LT style=\"width:100px\"><input type=submit value=CN name=CN style=\"width:100px\"><input type=submit value=RT name=RT style=\"width:100px\"><br>");
          client.println("<input type=submit value=DN name=DN style=\"width:100px\">");
          client.println("</form>");
          client.println("</center>");
          client.println("</body></html>");
          //clearing string for next read
          readString="";
          //stopping client
          client.stop();
            }
          }
        }
      }
}
void movetiltupstep(){
  tiltpos = tilt.read();
  Serial.println(tiltpos);
  if (tiltpos >= 66)
  {
  tilt.write(tiltpos - 2);
  }
}
void movetiltdownstep(){
  tiltpos = tilt.read();
  Serial.println(tiltpos);
  if (tiltpos <= 116)
  {
  tilt.write(tiltpos + 2);
  }
}
void movepanleftstep(){
  panpos = pan.read();
  Serial.println(panpos);
  if (panpos >= 4)
  {
  pan.write(panpos - 4);
  }
}
void movepanrightstep(){
  panpos = pan.read();
  Serial.println(panpos);
  if (panpos <= 176)
  {
  pan.write(panpos + 4);
  }
}
void center(){
  panpos = pan.read();
  tiltpos = tilt.read();
  Serial.println(panpos);
  if (panpos < 90)
  {
    for(int i = panpos; i <= 90; i++) {
      pan.write(i);
    }
  }
  else if (panpos > 90)
  {
    for(int i = panpos; i >= 90; i--) {
      pan.write(i);
    }
  }
  if (tiltpos < 90)
  {
    for(int i = tiltpos; i <= 90; i++) {
      tilt.write(i);
    }
  }
  else if (tiltpos > 90)
  {
    for(int i = tiltpos; i >= 90; i--) {
      tilt.write(i);
    }
  }
}
