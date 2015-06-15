
void oscEvent(OscMessage msg) {
  
  if (msg.checkAddrPattern("/wii/1/accel/pry")==true) {    
    iAccRate++;
    if (iAccRate % 2 != 0) return;
    float p = msg.get(0).floatValue();
    float r = msg.get(1).floatValue();
    float y = msg.get(2).floatValue();
    float a = msg.get(3).floatValue();

    float[] va = { 
      (1-r)*100, (1-p)*100
    };
    //naos[0].armCtrl.setArrayValue(va);
    //println(p+" "+r+" "+y+" "+a);
    return;
  }

  print("> Received ");

  if (msg.checkAddrPattern("/wii/1/button/Plus")==true) { 
    Object o = msg.arguments()[0];
    if((Float)o == 1.0) {
      for(int i=0; i<bAllDone.length; i++) { 
        if(!bAllDone[i]) {
            bAllDone[i] = true;   
            naos[i].posture = "";
            naos[i].saying = "";
        }      
      }
      if (robotsDone()) bNextStep = true;
    }
    return;
  }
  
  if (msg.checkAddrPattern("/done")==true) { 
    String sRobot = msg.get(0).stringValue();
    int iRobot = findRobotId(sRobot);    
    println("     Robot " + iRobot);
    
    if(!bAllDone[iRobot]) {
      bAllDone[iRobot] = true;   
      naos[iRobot].posture = "";
      naos[iRobot].saying = "";
      if (robotsDone()) bNextStep = true;
    }
    return;
  } 

  if (msg.checkAddrPattern("/alive")==true) { 
    String sRobot = msg.get(0).stringValue();
    int iRobot = findRobotId(sRobot);
    println("Alive " + sRobot + " : robot " + iRobot);
    if (iRobot >= 0) { 
      naos[iRobot].b.setColorBackground( color(14, 222, 0) ); 
      naos[iRobot].alive = true;
    } else println("Robot ", sRobot, " not recognized");  
    return;
  }

  if (msg.checkAddrPattern("/jointNames")==true) { 
    print("jointNames: ");
    String sRobot = msg.get(0).stringValue();
    int iRobot = findRobotId(sRobot);    
    Object[] objMsg = msg.arguments(); 
    naos[iRobot].jointNames = new String[objMsg.length];
    for (int i=1; i<objMsg.length; i++) {
      naos[iRobot].jointNames[i-1] = msg.get(i).stringValue();
      print(naos[iRobot].jointNames[i-1] + " ");
    }
    println(""); 
  }

  if (msg.checkAddrPattern("/jointLimits")==true) { 
    println("jointLimits");
    String sRobot = msg.get(0).stringValue();
    int iRobot = findRobotId(sRobot);    
    Object[] objMsg = msg.arguments(); 
    for (int i=1; i<objMsg.length/2; i++) {
      float min = msg.get(1+2*(i-1)).floatValue();
      float max = msg.get(1+2*(i-1)+1).floatValue();
      String name = naos[iRobot].jointNames[i-1];
      naos[iRobot].jointMin.set(name, min);
      naos[iRobot].jointMax.set(name, max);
      naos[iRobot].jointInter.set(name, max - min);
    }    
    return;
  }

  if (msg.checkAddrPattern("/joints")==true) { 
    print("joints: ");
    String sRobot = msg.get(0).stringValue();
    int iRobot = findRobotId(sRobot);    
    Object[] objMsg = msg.arguments(); 
    naos[iRobot].joints = new float[objMsg.length];
    for (int i=1; i<objMsg.length; i++) {
      naos[iRobot].joints[i-1] = msg.get(i).floatValue();
      print(naos[iRobot].joints[i-1] + " ");
    } 
    println(" now updating joints...");
    naos[iRobot].updateJoints();
    println(" done updating joints");
    return;
  }


  if (msg.checkAddrPattern("/nao")==true) { 
    String sRobot = msg.get(0).stringValue();
    int iRobot = findRobotId(sRobot);
    if (iRobot < 0) return;

    float x = msg.get(1).floatValue();
    float y = msg.get(2).floatValue();
    float a = msg.get(3).floatValue();
    naos[iRobot].xpos = x;
    naos[iRobot].ypos = y;
    naos[iRobot].angle = a;  
    return;
  }
}


void sendOSC(int i, String  pattern) {
  OscMessage myMessage = new OscMessage(pattern);
  oscP5.send(myMessage, naos[i].addr);
}

void sendOSC(int i, String  pattern, String Content) {
  OscMessage myMessage = new OscMessage(pattern);
  myMessage.add(Content); 
  oscP5.send(myMessage, naos[i].addr);
}

void sendOSC(int i, String  pattern, String Content, int num) {
  OscMessage myMessage = new OscMessage(pattern);
  myMessage.add(Content); 
  myMessage.add(num); 
  oscP5.send(myMessage, naos[i].addr);
}

void sendOSC(int i, String  pattern, int Content) {
  OscMessage myMessage = new OscMessage(pattern);
  myMessage.add(Content); 
  oscP5.send(myMessage, naos[i].addr);
}

void sendOSC(int i, String  pattern, float Content) {
  OscMessage myMessage = new OscMessage(pattern);
  myMessage.add(Content); 
  oscP5.send(myMessage, naos[i].addr);
}

void sendOSC(int i, String  pattern, float p1, float p2) {
  OscMessage myMessage = new OscMessage(pattern);
  myMessage.add(p1); 
  myMessage.add(p2); 
  oscP5.send(myMessage, naos[i].addr);
}

void sendOSC(int i, String  pattern, int j, float p1, float p2) {
  OscMessage myMessage = new OscMessage(pattern);
  myMessage.add(j); 
  myMessage.add(p1); 
  myMessage.add(p2); 
  oscP5.send(myMessage, naos[i].addr);
}

void sendOSC(int i, String  pattern, String[] args) {
  OscMessage myMessage = new OscMessage(pattern);
  for(int j=0; j<args.length; j++) myMessage.add( args[j] ); 
  oscP5.send(myMessage, naos[i].addr);
}

