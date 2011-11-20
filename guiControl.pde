/* ########################################################################

   ==!!!==!====!=====!=====!====!===!===!=====!===!===!====
         /`\__/`\   /`\   /`\  |~| |~|  /)=I=(\  /`"""`\
        |        | |   `"`   | | | | |  |  :  | |   :   |
        '-|    |-' '-|     |-' )/\ )/\  |  T  \ '-| : |-'
          |    |     |     |  / \// \/  (  |\  |  '---'
          '.__.'     '.___.'  \_/ \_/   |  |/  /
                                        |  /  /
                                        |  \ /
                                        '--'`
      layout for the gui controls
      functions for buttons, radios, etc     

######################################################################## */

//the overall layout gets set here
void guiSetup() {
    
      //setup the connection dependent controls
      conDepControls = new ControlP5(this);
      conDepControls.setColorBackground(0xffFFFFFF);
      conDepControls.setColorLabel(0xff000000);
      conDepControls.setColorValue(0xff000000);
      
       //setup the port controls
      portControls = new ControlP5(this);
      portControls.setColorBackground(0xffFFFFFF);
      portControls.setColorLabel(0xff000000);
      portControls.setColorValue(0xff000000);

      //output window
      serialOutput = conDepControls.addTextarea("output", "", 5, 30, width - 200, height/2 - 30 );
      serialOutput.enableColorBackground();
      serialOutput.setColorBackground(0xffFFFFFF);

      //port list
      portList = portControls.addDropdownList("portList", 5, 25, 175, 100);
      styleList( portList );

      //connect button
      connect = portControls.addButton("connect", 1, 190, 5, 80, 20 );

      //disconnect button
      disconnect = portControls.addButton("disconnect", 1, 280, 5, 80, 20 );

      //xyz window
      machineState = conDepControls.addTextarea("machine state", "", width - 180, 20, 180, height/2 );

      //estop button
      eStop = conDepControls.addButton("eStop", 1, width - 170, 245, 155, 155 );
      eStop.captionLabel().set("Emergency Stop");
      eStop.setColorActive(0xffFF0000);
      eStop.setColorBackground(0xffDD0000);

      //command input line
      serialInput = conDepControls.addTextfield("manual input", 5, height/2 + 10, 200, 20);
      //serialInput.keepFocus( true );

      //submit button
      submit = conDepControls.addButton("submit", 1, 210, height/2 + 10, 80, 20);

      //file path text (read-only)
      filePath = conDepControls.addTextfield("file path", 5, height/2 + 50, 200, 20);
      filePath.keepFocus( false );
      //file load button
      loadFile = conDepControls.addButton("loadFile", 1, 210, height/2 + 50, 80, 20);
      //file run button
      runFile = conDepControls.addButton("runFile", 1, 300, height/2 + 50, 80, 20);

      //units select
      unitSelect = conDepControls.addRadioButton("unitSelect", width - 170, 410);
      unitSelect.setColorForeground(color(120));
      unitSelect.setColorActive(color(0));
      unitSelect.setColorLabel(color(255));
      unitSelect.setItemsPerRow(2);
      unitSelect.setSpacingColumn(50);

      addToRadioButton(unitSelect, "Inch [G20]", 20);
      addToRadioButton(unitSelect, "MM [G21]", 21);

     //updateUnitSelect();
     
      controlsVisible(conDepControls,false);
}

//hide all controls in a controlP5 instance
//this is clunky, but it works
void controlsVisible(ControlP5 ctrlP5, boolean show) {
      ControllerInterface[] conList = ctrlP5.getControllerList();
      
      for( int c = 0; c < conList.length; c++ ) {
            if( show == true ) {
                  conList[c].show();
            } else if( show == false ) {
                  conList[c].hide();
            }
      }
}

//refresh the radio buttons to reflect the current unit settings
void updateUnitSelect() {
      println( "updating unit radios");
      if ( myCNC.units.equals("G20") ) 
            unitSelect.activate( 0 );
      else if ( myCNC.units.equals("G21") ) 
            unitSelect.activate( 1 );
}

//styling for the port list
void styleList(DropdownList ddl) {
      ddl.setBackgroundColor(color(190));
      ddl.setItemHeight(20);
      ddl.setBarHeight(20);
      ddl.captionLabel().set("Available Ports...");
      ddl.captionLabel().style().marginBottom = 3;
      ddl.captionLabel().style().marginTop = 3;
      ddl.captionLabel().style().marginLeft = 3;
      ddl.valueLabel().style().marginTop = 3;
      populatePortList( ddl );
      ddl.setColorBackground(color(160));
      ddl.setColorActive(color(255, 128));
}

//refresh the list of available serial ports
void populatePortList( DropdownList ddl ) {
      ddl.clear();

      //add refresh option
      ddl.addItem( "Rescan Ports...", myCNC.ports.length + 1 );

      //add the list of ports
      for ( int i = 0; i < myCNC.ports.length; i++ ) {
            //println( "adding port " + myCNC.ports[i]);
            ddl.addItem( myCNC.ports[i], i );
      }
}

//refresh the text w/ serial output
void updateGUItext() {
      machineState.setText( "X" + myCNC.xPos + char(10) + "Y" + myCNC.yPos + char(10) + "Z" + myCNC.zPos );
      serialOutput.setText( myCNC.output );
      serialOutput.scroll(1);
}

//add items to the radio button obj
void addToRadioButton(RadioButton theRadioButton, String theName, int theValue ) {
      Toggle t = theRadioButton.addItem(theName, theValue);
      t.captionLabel().setColorBackground(color(80));
      t.captionLabel().style().movePadding(2, 0, -1, 2);
      t.captionLabel().style().moveMargin(-2, 0, 0, -3);
      t.captionLabel().style().backgroundWidth = 46;
}


//send input from the text field to the board
void submit() {
      if ( !serialInput.getText().equals("") ) {
            myCNC.write( serialInput.getText() );
            //clear the text field
            serialInput.setText("");
      }
}

//control events fire when dropdowns/radios are selected, keys are pushed, etc 
void controlEvent(ControlEvent theEvent) {
      //dropdown list operations
      if (theEvent.isGroup()) {
            //for port select dropdown
            if( theEvent.group().name().equals("portList") ){
                  if( int(theEvent.group().value()) == myCNC.ports.length + 1) {
                        //rescan the ports
                        myCNC.scanPorts();
                        populatePortList( portList );
                  } else {
                        //send the port list index
                        myCNC.setPort( int(theEvent.group().value()) );
                  }
            } 
            //units radio buttons
            else if( theEvent.group().name().equals("unitSelect") ){
                  myCNC.setUnits( theEvent.group().value() );
            }
      } 
     // else if (theEvent.isController()) {
            //println(theEvent.controller().value()+" from "+theEvent.controller());
      //}
     //submit the input text when ENTER is pressed 
      else {
            submit();
      }
}

//disconnect from the board by deleting the serial object
void disconnect() {
      if( myCNC.disConnect() ){
            controlsVisible(conDepControls,false);      
      }
}

//connect to the selected port
void connect(){
     if( myCNC.connect() ){
           controlsVisible(conDepControls,true);
     }
} 

//emergency stop
void eStop() {
      myCNC.eStop();
}

//run a selected file obj
void runFile() {
      myCNC.runFile();
}


