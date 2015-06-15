/***** VARIABLES TO CHANGE ****************************/
final String MY_IP_ADDRESS = "192.168.0.8";
String naoNames[] = { "dani" };
String ips[] = { "192.168.0.3" };
boolean bAllDone[] = { true };
/**********************************************/

import oscP5.*;
import netP5.*;
import controlP5.*;
import g4p_controls.*;
import java.util.Date;
import java.util.Calendar;
import java.io.PrintWriter;
import java.io.*;

ControlP5 cp5;
OscP5 oscP5;


NAO naos[];
NAO audience;

boolean bNextStep = false;

int xini = 15;
int xsup = 500;
int yini = 20;

int findRobotId(String sRobot) {
  String s = sRobot.toLowerCase();
  int iRobot = -1;
  if (s.equals(audience.name)) return naos.length;
  for (int i=0; i<naos.length; i++) {
    if (s.equals(naoNames[i])) iRobot = i;
    if (iRobot >= 0) break;
  }
  return iRobot;
}


void play(int iRobot) {
  String[] lines = naos[iRobot].dialog;
  for (int i=0; i<lines.length; i++) {
    sendOSC(iRobot, "/say", lines[i]);
    println(lines[i]);
  }
}

void setup() {
  size(1300, 600);
  frameRate(25);
     
  cp5 = new ControlP5(this);
  oscP5 = new OscP5(this, 3333);
  audience = new NAO();
         
  naos = new NAO[naoNames.length];
  for (int i=0; i<naoNames.length; i++) {
    naos[i] = new NAO(this, i);
  }

  for (int i=0; i<naoNames.length; i++) {
    sendOSC(i,"/addclient", MY_IP_ADDRESS);
    delay(500);
    sendOSC(i, "/isalive"); 
    delay(200);
    sendOSC(i, "/sendJoints");
  }
}

boolean robotsDone() {
  boolean bDone = true;
  for (int i = 0; i < ips.length; i++) {
    if (naos[i].alive) bDone = bDone && bAllDone[i];
    else bAllDone[i] = true;
  }
  return bDone;
}



void draw() {  
  background(0, 0, 0);  
  stroke(0, 20, 50);
  noFill();
  strokeWeight(3);
  rect(1, 1, width-3, height-3);
  strokeWeight(1);
    
  for (int i = 0; i < ips.length; i++) {
    int w = naos[i].b.getWidth();
    int h = naos[i].b.getHeight();
    int x = (int)naos[i].b.getPosition().x + w + 10;
    int y = (int)naos[i].b.getPosition().y;  

    if (bAllDone[i]) fill(10, 200, 100);
    else             fill(205, 20, 50);
    rect(x, y, w, h);

    textSize(13);
    if (naos[i].saying != "") {            
      fill(10, 160, 150);
      text(naoNames[i], x + w + 20, y + 10);
      fill(10, 250, 200);
      text(naos[i].saying, x + w + 40 + textWidth(naoNames[i]), y + 10);
    }
    if (naos[i].posture != "") {
      fill(130, 40, 150);
      text("posture: ", x + w + 20, y + 25);
      fill(150, 40, 200);
      text(naos[i].posture, x + w + 40 + textWidth("posture: "), y + 25);
    }
  }  
}


int iAccRate = 0;

void mouseReleased() 
{
  audience.selected = false;
  for (int i=0; i<naos.length; i++) {
    naos[i].selected = false;
  }
}



void keyPressed() {
  for (int i=0; i<naos.length; i++) {
    naos[i].keypressed();
  }


  if (key == ENTER) {
    for (int i=0; i<naos.length; i++) {
      if (naos[i].area.hasSelection()) {
        String str = naos[i].area.getSelectedText();
        sendOSC(i, "/say", str);
        println("Send say: ", str);
      }
    }
  }

  /*if (key == ' ') {
   iscript = 0;
   print("bAllDone ");
   for (int i = 0; i < ips.length; i++) {
   print(bAllDone[0] + " ");
   sendOSC(i, "/start");
   }
   println("");     
   bNextStep = true;
   }*/
}


int lastArmSlider = millis();

void controlEvent(ControlEvent theEvent) {
  String[] who;
  String w = theEvent.getName();
  int iRobot = 0;
  
  if(theEvent.getName().contains("-")) {
    who = split(theEvent.getName(), '-');
    w = who[0];
    iRobot = int(who[1]);
  } 
  else {
    who = new String[2];
    who[0] = theEvent.getName();
  }
  
  int k = -1;
  float j1 = 0, j2 = 0;    
  NAO n = naos[iRobot];

  if (n == null) return; 
  if (n.jointMin == null) return; 

  if (theEvent.isAssignableFrom(Textfield.class)) {
    String str = theEvent.getStringValue();    
    if (w.equals("behavior")) sendOSC(iRobot, "/behavior", str);  
    if (w.equals("myposture")) {
      if(str.contains(" ")) {
        String[] args = split(str, ' ');
        int npos = parseInt(args[1]);
        sendOSC(iRobot, "/animation", args[0], npos);
      }
      else sendOSC(iRobot, "/posture", str);
    }
    return;
  }
  
  //if (keyPressed == true) return;


  if (theEvent.isGroup()) {
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
    String name = "" + theEvent.getGroup();
    if (w.equals("Library")) {
      int index = int(theEvent.getGroup().getValue());
      String lstr = "" + naos[iRobot].lib.getItem(index).getName();
      naos[iRobot].behavior.setValue(lstr);
      sendOSC(iRobot, "/behavior", lstr);
    }
    if (who[0].equals("LibSit")) {
      int index = int(theEvent.getGroup().getValue());
      String lstr = "" + naos[iRobot].libsit.getItem(index).getName();
      naos[iRobot].behavior.setValue(lstr);
      sendOSC(iRobot, "/behavior", lstr);
    }
    if (who[0].equals("Postures")) {
      int index = int(theEvent.getGroup().getValue());
      String lstr = "" + naos[iRobot].postures.getItem(index).getName();
      sendOSC(iRobot, "/posture", lstr);
    }
    if (who[0].equals("Interactive")) {
      int index = int(theEvent.getGroup().getValue());
      String lstr = "" + naos[iRobot].interactive.getItem(index).getName();
      sendOSC(iRobot, "/interactive", lstr);
    }
    return;
  } 

  if (theEvent.isAssignableFrom(Button.class)) {
    if(w.equals("ReSend")) {
         bNextStep = true;    
         for (int i = 0; i < ips.length; i++) {
           bAllDone[i] = true;
         }  
    }

    if (w.startsWith( naoNames[0] )) {
         sendOSC(0, "/isalive");   
         delay(200);
         sendOSC(0, "/sendJoints");
         sendOSC(0, "/sendSensors");
    }
    
    if (w.startsWith("Lopen")) sendOSC(iRobot, "/jointCtrl", 3, j1, j2);
    if (w.startsWith("Lclose")) sendOSC(iRobot, "/jointCtrl", 4, j1, j2);
    if (w.startsWith("Ropen")) sendOSC(iRobot, "/jointCtrl", 8, j1, j2);
    if (w.startsWith("Rclose")) sendOSC(iRobot, "/jointCtrl", 9, j1, j2);
    if (w.equals("Play")) play(iRobot);
  }  

  if (theEvent.isAssignableFrom(Slider2D.class)) {
    float v1 = theEvent.controller().arrayValue()[0];
    float v2 = theEvent.controller().arrayValue()[1];

    if (w.startsWith("Lshoulder")) {  
      k=0;  
      j1 = map(v1, 0, 100, n.jointMin.get("LShoulderRoll"), n.jointMax.get("LShoulderRoll"));  
      j2 = map(v2, 0, 100, n.jointMin.get("LShoulderPitch"), n.jointMax.get("LShoulderPitch"));
    }
    if (w.startsWith("Rshoulder")) { 
      k=5;  
      j1 = map(v1, 0, 100, n.jointMin.get("RShoulderRoll"), n.jointMax.get("RShoulderRoll"));  
      j2 = map(v2, 0, 100, n.jointMin.get("RShoulderPitch"), n.jointMax.get("RShoulderPitch"));
    }   
    if (w.startsWith("Lelbow")) { 
      k=1; 
      j1 = map(v1, 100, 0, n.jointMin.get("LElbowYaw"), n.jointMax.get("LElbowYaw"));  
      j2 = map(v2, 0, 100, n.jointMin.get("LElbowRoll"), n.jointMax.get("LElbowRoll"));
    }
    if (w.startsWith("Relbow")) { 
      k=6; 
      j1 = map(v1, 100, 0, n.jointMin.get("RElbowYaw"), n.jointMax.get("RElbowYaw"));  
      j2 = map(v2, 100, 0, n.jointMin.get("RElbowRoll"), n.jointMax.get("RElbowRoll"));
    }

    if (w.startsWith("Lhip")) { 
      k=11; 
      j1 = map(v1, 0, 100, n.jointMin.get("LHipRoll"), n.jointMax.get("LHipRoll"));  
      j2 = map(v2, 0, 100, n.jointMin.get("LHipPitch"), n.jointMax.get("LHipPitch"));
    }
    if (w.startsWith("Rhip")) { 
      k=15; 
      j1 = map(v1, 0, 100, n.jointMin.get("RHipRoll"), n.jointMax.get("RHipRoll"));  
      j2 = map(v2, 0, 100, n.jointMin.get("RHipPitch"), n.jointMax.get("RHipPitch"));
    }

    if (w.startsWith("Lankle")) { 
      k=12; 
      j1 = map(v1, 0, 100, n.jointMin.get("LAnkleRoll"), n.jointMax.get("LAnkleRoll"));  
      j2 = map(v2, 0, 100, n.jointMin.get("LAnklePitch"), n.jointMax.get("LAnklePitch"));
    }
    if (w.startsWith("Rankle")) { 
      k=16; 
      j1 = map(v1, 0, 100, n.jointMin.get("RAnkleRoll"), n.jointMax.get("RAnkleRoll"));  
      j2 = map(v2, 0, 100, n.jointMin.get("RAnklePitch"), n.jointMax.get("RAnklePitch"));
    }

    if (w.startsWith("headCtrl")) { 
      k=18; 
      j1 = map(v1, 0, 100, n.jointMin.get("HeadYaw"), n.jointMax.get("HeadYaw"));  
      j2 = map(v2, 0, 100, n.jointMin.get("HeadPitch"), n.jointMax.get("HeadPitch"));
    }

    if (k >= 0 && millis() > 4000) {
      if (millis() - lastArmSlider > 300) {
        sendOSC(iRobot, "/jointCtrl", k, j1, j2);
        lastArmSlider = millis();
      }
    }
  }

  if (theEvent.isAssignableFrom(Slider.class)) {
    float v1 = theEvent.controller().getValue();
    if (w.startsWith("Lwrist")) { k=2; j1 = map(v1, 100, 0, n.jointMin.get("LWristYaw"), n.jointMax.get("LWristYaw")); }
    if (w.startsWith("Rwrist")) { k=7; j1 = map(v1, 100, 0, n.jointMin.get("RWristYaw"), n.jointMax.get("RWristYaw")); }
    if (w.startsWith("Lknee")) { k=13; j1 = map(v1, 100, 0, n.jointMin.get("LKneePitch"), n.jointMax.get("LKneePitch")); }
    if (w.startsWith("Rknee")) { k=17; j1 = map(v1, 100, 0, n.jointMin.get("RKneePitch"), n.jointMax.get("RKneePitch")); }
    if (w.startsWith("HY")) { k=10; j1 = map(v1, 0, 100, n.jointMin.get("LHipYawPitch"), n.jointMax.get("LHipYawPitch")); }
    
    if (k >= 0 && millis() > 4000) {
      if (millis() - lastArmSlider > 300) {
        sendOSC(iRobot, "/jointCtrl", k, j1, j2);
        lastArmSlider = millis();
      }
    }
  }
}


public void handleTextEvents(GEditableTextControl textControl, GEvent event) { 
  /*String[] who = split(textControl.tag, '-');
   int iRobot = int(who[1]);
   if (event == GEvent.SELECTION_CHANGED) {
   //println(textControl.getSelectedText());
   }*/
}

