

String[] behaviorsLib = {
  "Angry", "Anxious", "Bored", "Disappointed", "Exhausted", "Fear", "Frustrated", "Humiliated", "Hurt", "Late", "Sad", "Shocked", "Sorry", "Surprise", "Annoyed", "Attention", "Cautious", "Confused", "Determined", "Embarrassed", "Hesitation", "Innocent", "Lonely", "Mischievous", "Puzzled", "Sneeze", "Stubborn", "Suspicious", "Amused", "Confident", "Ecstatic", "Enthusiastic", "Excited", "Happy", "Hungry", "Hysterical", "Interested", "Laugh", "Mocker", "Optimistic", "Peaceful", "Proud", "Relieved", "Shy", "Winner", "Applause", "Bow", "But", "Calm", "Caress", "Catch", "Coaxing", "Count", "Desperate", "Everything", "Explain", "Far", "Follow", "Give", "Great", "HeSays", "Hey", "Hide", "DontKnow", "Hands", "Joy", "Kisses", "Look", "Maybe", "Me", "Mime", "Next", "No", "Yes", "Evening", "Please", "Reject", "Salute", "Shoot", "Show", "Stretch", "Thinking", "This", "Wings", "Yes", "KnowWhat", "See", "AirGuitar", "AirJuggle", "BackRubs", "BandMaster", "Binoculars", "Call", "Drink", "Drive", "Fitness", "Dancer", "FunnySlide", "Birthday", "HeadBang", "Knight", "KungFu", "Monster", "Mystical", "Robot", "Scratch", "Show", "Space", "Taxi", "Wake", "Zombie"
};

String[] behaviorsLibSit = {
  "Listening", "Body", "Remember", "Angry", "Fear", "Frustrated", "Hurt", "Late", "Sad", "Surprise", "Attention", "Sneeze", "Happy", "Hungry", "Laugh", "Mocker", "Shy", "Winner", "ComeOn", "Hey", "Me", "You", "Shake", "Binoculars", "Bored", "CallSomeone", "Catch", "Cramp", "Drive", "Fitness", "Knock", "Geo", "Hand", "Music", "Mystical", "Oar", "Phone", "PlayHands", "Pong", "Puppet", "Relaxation", "Rest", "Robot", "Scratch", "Picture", "Think", "Wake", "Yawn"
};

void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().set( ddl.getName() );
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}



class NAO { 
  String name;
  float xpos, ypos;
  float angle;
  String saying; 
  String posture;
  String[] dialog;

  String[]  jointNames;
  FloatDict jointMin;
  FloatDict jointMax;
  FloatDict jointInter;
  float[]   joints;

  String ip;  
  NetAddress addr;

  // Control P5 GUI
  Button b; 
  Button load; 
  Button play; 
  Textfield txt;
  DropdownList lang;
  DropdownList lib;
  DropdownList libsit;
  DropdownList postures;
  DropdownList interactive;
  Textfield behavior;
  Textfield myposture;
  GTextArea area;

  Slider2D headCtrl;
  Slider2D[] elbowCtrl;
  Slider2D[] shoulderCtrl;
  Slider[] wristCtrl;
  Button[] openHand; 
  Button[] closeHand; 

  Slider HipYawCtrl;

  Slider2D[] hipCtrl;
  Slider2D[] ankleCtrl;
  Slider[] kneeCtrl;

  boolean bArmCtrl;
  boolean bLegCtrl;

  boolean selected;
  boolean alive;

  NAO() {
    xpos = 0.5;
    ypos = 0.1; 
    angle = PI;
    name = "audience";
    selected = false;
    alive = false;
  }

  NAO(PApplet setupThis, int i) {
    char arm;
    xpos = 0.3 + i*0.2;
    ypos = 0.8; 
    angle = 0;
    selected = false;
    alive = false;
    bLegCtrl = false;
    bArmCtrl = true;
  
    setJointLimits();
    
    name = naoNames[i];
    saying = "";
    posture = "";
    alive = false;
    dialog = loadStrings("dialog-" + i + ".txt");

    int h = 190;

    int xini2 = 30;
    int legIni = 160;
    int sw = 100; 
    int sh = 140;
    
    int xi = xsup - 250; 
    int yi = 130;
   
    if(bArmCtrl) {
      headCtrl = cp5.addSlider2D("headCtrl-" + i)
        .setPosition(xini+xini2+sw-10, yini + i*h + sh/2)
        .setSize(sw, sw)
        .setArrayValue(new float[] { 50, 50 } );

      shoulderCtrl = new Slider2D[2];
      for (int j=0; j<2; j++) {
        if (j==0) arm = 'R'; 
        else arm = 'L';
        shoulderCtrl[j] = cp5.addSlider2D(arm + "shoulderCtrl-" + i)
          .setPosition(xini + (20+sw)*j*2, yini + i*h + sh)
            .setSize(sw, sw)
            .setArrayValue(new float[] {
              50, 50
            }
        );
      }

      elbowCtrl = new Slider2D[2];
      for (int j=0; j<2; j++) {
        if (j==0) arm = 'R'; 
        else arm = 'L';
        elbowCtrl[j] = cp5.addSlider2D(arm + "elbowCtrl-" + i)
          .setPosition(xini + (20+sw)*j*2, yini + i*h +sh + sh)
            .setSize(sw, sw)
            .setArrayValue(new float[] {
              50, 50
            }
        );
      }
  
      wristCtrl = new Slider[2];
      for (int j=0; j<2; j++) {
        if (j==0) arm = 'R'; 
        else arm = 'L';
        wristCtrl[j] = cp5.addSlider(arm + "wristCtrl-" + i)
          .setPosition(xini + (20+sw)*j*2, yini + i*h + 3*sh)
            .setSize(sw, 15)
              .setRange(0, 100)
                .setValue(50);
      }
  
      openHand = new Button[2];
      for (int j=0; j<2; j++) {
        if (j==0) arm = 'R'; 
        else arm = 'L';
        openHand[j] =  cp5.addButton(arm + "open-"+i)
          .setPosition(xini + (20+sw)*j*2, yini + i*h + 3*sh + 30)
            .setSize(45, 45)
              .setColorBackground( color(204, 102, 0) );
      }
  
      closeHand = new Button[2];
      for (int j=0; j<2; j++) {
        if (j==0) arm = 'R'; 
        else arm = 'L';
        closeHand[j] =  cp5.addButton(arm + "close-"+i)
          .setPosition(xini + (20+sw)*j*2 + 60, yini + i*h + 3*sh + 30)
            .setSize(45, 45)
              .setColorBackground( color(204, 102, 0) );
      }
    }


    if(bLegCtrl) {
      hipCtrl = new Slider2D[2];
      for (int j=0; j<2; j++) {
        if (j==0) arm = 'R'; 
        else arm = 'L';
        hipCtrl[j] = cp5.addSlider2D(arm + "hipCtrl-" + i)
          .setPosition(xini+xini2 + 2*(sw+20) + legIni + j*(sw+40), yini + i*h + sh)
            .setSize(sw, sw);
      }
    
      ankleCtrl = new Slider2D[2];
      for (int j=0; j<2; j++) {
        if (j==0) arm = 'R'; 
        else arm = 'L';
        ankleCtrl[j] = cp5.addSlider2D(arm + "ankleCtrl-" + i)
          .setPosition(xini+xini2 + 2*(sw+20) + legIni+ j*(sw+40), yini + i*h + 3*sh-30)
            .setSize(sw, sw);
      }

      kneeCtrl = new Slider[2];
      for (int j=0; j<2; j++) {
        if (j==0) arm = 'R'; 
        else arm = 'L';
        kneeCtrl[j] = cp5.addSlider(arm + "kneeCtrl-" + i)
          .setPosition(xini+xini2 + 2*(sw+20) + legIni + 40 + j*sw+j*sw/2, yini + i*h + 2*sh - 20)
            .setSize(15, sh-40)
              .setRange(0, 100);
      }

      HipYawCtrl = cp5.addSlider("HYCtrl-" + i)
        .setPosition(xini+xini2 + 3*(sw+20) + 150, yini + i*h + sh + sh/2)
          .setSize(15, sh-20)
            .setRange(0, 100)
              .setValue(40);
    }

    b =  cp5.addButton(naoNames[i])
      .setPosition(xini, yini + i*h)
        .setSize(50, 50)
          .setColorBackground( color(204, 102, 0) );

    play =  cp5.addButton("Play-"+i)
      .setPosition(xini + 150+xsup, yini + i*h + 20)
        .setSize(50, 20)
          .setColorBackground( color(204, 102, 0) );

    load =  cp5.addButton("Load-"+i)
      .setPosition(xini + 150+xsup, yini + i*h + 45)
        .setSize(50, 20)
          .setColorBackground( color(204, 102, 0) );

    lang = cp5.addDropdownList("Languaje-"+i)
      .setPosition(xini + 150+xsup, yini + i*h + 15)
        .setSize(50, 100);

    postures = cp5.addDropdownList("Postures-"+i)
      .setPosition(xini+130+xsup, yini + i*h + 90)
        .setSize(70, 140);


    // ***************
    lib = cp5.addDropdownList("Library-"+i)
      .setPosition(xini + 460+xi, yini + i*h + 60 + yi)
        .setSize(70, 140);

    libsit = cp5.addDropdownList("LibSit-"+i)
      .setPosition(xini + 460+xi+80, yini + i*h + 60+yi)
        .setSize(70, 140);

    behavior = cp5.addTextfield("behavior-" + i)
      .setPosition(xini + 460+xi, yini + i*h+yi)
        .setSize(100, 20)
          .setFont(createFont("arial", 12))
            .setAutoClear(false);

    myposture = cp5.addTextfield("myposture-" + i)
      .setPosition(xini + 600+xi, yini + i*h+yi)
        .setSize(100, 20)
          .setFont(createFont("arial", 12))
            .setAutoClear(false);


    interactive = cp5.addDropdownList("Interactive-"+i)
       .setPosition(xini + 460+xi+160, yini + i*h + 60+yi)
        .setSize(90, 140);

    customize(lang);
    customize(lib);
    customize(libsit);
    customize(postures);
    customize(interactive);

    lang.addItem("Spanish", 0);
    lang.addItem("English", 1);
    lang.setIndex(0);

    interactive.addItem("SearchBall",0);
    interactive.addItem("BallInHand",1);

    for (int j=0; j<behaviorsLib.length; j++) lib.addItem(behaviorsLib[j], j);
    for (int j=0; j<behaviorsLibSit.length; j++) libsit.addItem(behaviorsLibSit[j], j);

    postures.addItem("Sit", 0);
    postures.addItem("SitRelax", 1);
    postures.addItem("Stand", 2);
    postures.addItem("Crouch", 3);
    postures.addItem("LyingBelly", 4);
    postures.addItem("LyingBack", 5);

    area = new GTextArea(setupThis, xini + 210+xsup, yini + i*h, 240, 120, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    area.tag = "area-"+i;
    area.setText(dialog);
    area.setTextEditEnabled(true); 

    addr = new NetAddress(ips[i], 1234);
  }

  float getAngle() {
    int sign = 1;
    if (angle < 0) sign = -1;
    float a = sign*angle - sign * PI/2.0;
    return a;
  }

  float getDirX() { 
    return cos(getAngle());
  }
  float getDirY() { 
    return sin(getAngle());
  }


  void keypressed() {
    if (key == CODED) {
      Slider2D selected2D = null;
      
      if(bArmCtrl)
      for (int j=0; j<2; j++) {
        if (naos[0].elbowCtrl[j].isMouseOver()) selected2D = naos[0].elbowCtrl[j];
        if (naos[0].shoulderCtrl[j].isMouseOver()) selected2D = naos[0].shoulderCtrl[j];
        
        if(naos[0].bLegCtrl) {
          if (naos[0].hipCtrl[j].isMouseOver()) selected2D = naos[0].hipCtrl[j];
          if (naos[0].ankleCtrl[j].isMouseOver()) selected2D = naos[0].ankleCtrl[j];
        }
      }
      if (selected2D != null) {
        float[] va = selected2D.getArrayValue();     
        if (keyCode == RIGHT) va[0] += 1;
        if (keyCode == LEFT) va[0] -= 1;
        if (keyCode == UP) va[1] -= 1;
        if (keyCode == DOWN) va[1] += 1;
        selected2D.setArrayValue(va);
      }

      int s = 1;
      Slider selected = null;
      if(bArmCtrl)
      for (int j=0; j<2; j++) {
        if (naos[0].wristCtrl[j].isMouseOver()) { selected = naos[0].wristCtrl[j]; }
        
        if(naos[0].bLegCtrl) {
          if (naos[0].kneeCtrl[j].isMouseOver()) { selected = naos[0].kneeCtrl[j]; s = -1; }
          if (naos[0].HipYawCtrl.isMouseOver()) { selected = naos[0].HipYawCtrl; s = -1; }
        }
      }
      if (selected != null) {
        float va = selected.getValue();     
        if (keyCode == RIGHT) va += s*1;
        if (keyCode == LEFT) va -= s*1;
        if (keyCode == UP) va -= s*1;
        if (keyCode == DOWN) va += s*1;
        selected.setValue(va);
      }
    }
  }
 
  void setJointLimits() {
    jointMin = new FloatDict();
    jointMax = new FloatDict();
    jointInter = new FloatDict();
  }
  
  
  void updateJoints() {
    if(!bArmCtrl) return;

    String jx = jointNames[0];
    String jy = jointNames[1];    
    float sx = 100 * (joints[0] - jointMin.get(jx)) / jointInter.get(jx);
    float sy = 100 * (joints[1] - jointMin.get(jy)) / jointInter.get(jy);
    headCtrl.setArrayValue(new float[] {sx,sy});



    for(int i=0;i<2;i++) {
      jx = jointNames[3+18*i];
      jy = jointNames[2+18*i];    
      sx = 100 * (joints[3+18*i] - jointMin.get(jx)) / jointInter.get(jx);
      sy = 100 * (joints[2+18*i] - jointMin.get(jy)) / jointInter.get(jy);
      shoulderCtrl[1-i].setArrayValue(new float[] {sx,sy});
    }
    
    for(int i=0;i<2;i++) {
      jx = jointNames[4+18*i];
      jy = jointNames[5+18*i];  
      sx = 100 - 100 * (joints[4+18*i] - jointMin.get(jx)) / jointInter.get(jx);

      if(i==1) sy = 100 - 100 * (joints[5+18*i] - jointMin.get(jy)) / jointInter.get(jy);
      else     sy = 100 * (joints[5+18*i] - jointMin.get(jy)) / jointInter.get(jy);

      elbowCtrl[1-i].setArrayValue(new float[] {sx,sy});
    }

    for(int i=0;i<2;i++) {
      jx = jointNames[6+18*i];
      sx = 100-100 * (joints[6+18*i] - jointMin.get(jx)) / jointInter.get(jx);
      wristCtrl[1-i].setValue(sx);
    }

    // *********** LEGS
  
    if(!bLegCtrl) return;
    
    jx = jointNames[8];
    sx = 100 * (joints[8] - jointMin.get(jx)) / jointInter.get(jx);
    HipYawCtrl.setValue(sx);

    for(int i=0;i<2;i++) {
      jx = jointNames[9+6*i];
      jy = jointNames[10+6*i];    
      sx = 100 * (joints[9+6*i] - jointMin.get(jx)) / jointInter.get(jx);
      sy = 100 * (joints[10+6*i] - jointMin.get(jy)) / jointInter.get(jy);
      hipCtrl[1-i].setArrayValue(new float[] {sx,sy});
    }
    
    for(int i=0;i<2;i++) {
      jx = jointNames[13+6*i];
      jy = jointNames[12+6*i];    
      sx = 100 * (joints[13+6*i] - jointMin.get(jx)) / jointInter.get(jx);
      sy = 100 * (joints[12+6*i] - jointMin.get(jy)) / jointInter.get(jy);
      ankleCtrl[1-i].setArrayValue(new float[] {sx,sy});
    }

    for(int i=0;i<2;i++) {
      jx = jointNames[11+6*i];
      sx = 100 - 100 * (joints[11+6*i] - jointMin.get(jx)) / jointInter.get(jx);
      kneeCtrl[1-i].setValue(sx);
    }
  }
} 



