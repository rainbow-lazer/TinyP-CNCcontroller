/* ########################################################################

sets a few global options for the machine and handles serial input/output
 
                         |    
                     \       /  
                       .-'-.       
                  --  /     \  --      
 `~~^~^~^~^~^~^~^~^~^-=======-~^~^~^~~^~^~^~^~^~^~^~` 
 `~^_~^~^~-~^_~^~^_~-=========- -~^~^~^-~^~^_~^~^~^~`
 `~^~-~~^~^~-^~^_~^~~ -=====- ~^~^~-~^~_~^~^~~^~-~^~`
 `~^~^~-~^~~^~-~^~~-~^~^~-~^~~^-~^~^~^-~^~^~^~^~~^~-` 
 .
######################################################################## */

class CNC {

      PApplet parent;
      Serial serial;
      String[] ports;
      int portID = 0;
      boolean connected = false;
      boolean transmit = true; //this corresponds to the xon/xoff [whether the board can take more data or not]
      
      //global machine settings
      String units = "G20"; //G20 = inches. G21 = millimeters 
      Motor[] motors = new Motor[4];
      String[] axesNames = { "X", "Y", "Z", "A", "B", "C" };
      HashMap axes = new HashMap( axesNames.length );
      String[] xyzPosString = new String[3];
      float xPos;
      float yPos;
      float zPos;
      float velocity;
      
      //serial feedback from the board
      int linebreak = 62; //where to end the serial output buffer [>]
      String output = new String(); //generic serial outupt that gets displayed as is
      char[] buffer = { char(10), char(10) }; //character buffer
      String stateInfo; //serial output for specific board state info (position, units, etc)
      boolean recordStateInfo = false;
      boolean recordLineFeed = false;
      
      // a list of the last commands sent to the board
      ArrayList lastCmds = new ArrayList(); 
      int cmdIndex = 0; 
      
      //info for running gcode files
      File fileToRun;
      boolean streaming = false;
      int fileIndex = 0;
      String[] cmdQ;


      CNC( PApplet _parent ) {
            parent = _parent;
            
            //setup the axes
            for( int a = 0; a < axesNames.length; a++ ){
                  //make a hashmap of the 6 available axes
                  //after this, you can access like: myCNC.axes.get("X")
                  axes.put( axesNames[a], new Axis( axesNames[a] ) );          
            }
            
            scanPorts();
            lastCmds.add(0, ""); //add a blank string to the command queue
      }
      
/* ########################################################################
 /\-/\    /\-/\    /\-/\    /\-/\    /\-/\    /\-/\    /\-/\    /\-/\
(=^Y^=)  (=^Y^=)  (=^Y^=)  (=^Y^=)  (=^Y^=)  (=^Y^=)  (=^Y^=)  (=^Y^=)
 (>o<)    (>o<)    (>o<)    (>o<)    (>o<)    (>o<)    (>o<)    (>o<)
       
       serial port scanning,
       connection and disconnection
       
######################################################################## */       
            
      //scan for available ports
      void scanPorts(){
           ports = Serial.list();
      }
      
      //set which port we're using
      void setPort( int prt ) {
            portID = prt;
      }

      // open the serial connection to the selected port
      boolean connect() {
            println("attempting to connect to port " + portID + ": " + ports[portID]);
            serial = new Serial(parent, Serial.list()[portID], 115200, 'N', 8, 1.0);
            //serial.bufferUntil( linebreak );
            connected = true;
            
            //there doesn't seem to be a simple way to test for an active connection, but if there were I'd call it here before returning. 
            return connected;
      }

      // close the serial connection & cleanup
      boolean disConnect() {
            println("disconnecting from port " + portID + ": " + ports[portID]);
            serial.clear();
            stateInfo = "";
            output = "";
            serial.stop();
            updateGUItext();
            connected = false;
            return !connected;
      }
      
/* ########################################################################
     /\-/\
    /o o  \                                                        _
   =\ Y  =/-~~~~~~-,______________________________________________/ )
     '^--'          _______________________________________________/
       \           /      generic reading & writing to the board
       ||  |---'\  \
      (_(__|   ((__|

######################################################################## */

      //read individual characters from the board
      //I did this since we need to test for multiple characters that may be output from the board
      boolean readCharacter(){
            boolean wasRead = false;
            if( connected ){
                  while ( serial.available() > 0 ){
                        char myChar = serial.readChar();
                        //println( myChar + " " + int( myChar ) );
                        wasRead = true;
                        buffer = append( buffer, myChar );
                  
                        //send output info to the GUI in chunks
                        if( buffer.length > 4){
                              String addme = new String(buffer);
                              if( output.length() > 10000 ){ //10k character limit for board output
                                    output = output.substring( 100, output.length() );//chop off the oldest 100 chars
                              }
                              output += addme;
                              buffer = new char[0];
                        }
                        
                        //do char tests (Xon/Xoff), etx
                        if( myChar == char( 19 ) ){ //XOFF
                              transmit = false;
                              println("XOFF = stop transmitting!");
                        } else if( myChar == char( 17 ) ){ //XON 
                               transmit = true;
                              println("XON = ok to transmit!");
                        } else if( myChar == char( 123 ) ){ // "{" the next stuff may be position info 
                              recordStateInfo = true;
                        } else if( myChar == char( 125 ) ){ // "}" potential position info ends 
                              recordStateInfo = false;
                              parseStateInfo();
                              stateInfo = new String();
                        } else if( myChar == char( 62 ) ){// ">" end of line
                              recordLineFeed = true;
                        }
                        
                        if( recordStateInfo ){
                              stateInfo+=myChar;      
                        }
                  }
            }
            return wasRead;
      }

      
      //get the string output from the board. this will buffer the output until a '>' is encountered
      /*
      void readString() {
            //get output from the board
            String boardSays = serial.readString();
            
            //check for XON/XOFF
            for( int c = 0; c < boardSays.length(); c++ ){
                  char current = boardSays.charAt( c );
                  //println( current );
                   if ( current == char( 19 ) ) //XOFF
                        transmit = false;
                   else if ( current == char( 17 ) ) //XON
                        transmit = true;
                        
            }
            
            //decide whether this is terminal output or machine state info
            if ( boardSays.charAt(1) == char(63) || boardSays.charAt(0) == char(63) ) {
                  stateInfo = boardSays;
            }
            else { //it is serial output
                  output += boardSays;
                  //update the machine state info, since it will most likely be different
                  write("?");
            }
      }
      */

      //send a string to the board
      void write( String input) {
            if ( connected ) {
                  if( transmit ) {
                        
                        //start doing tests to parse gCode
                        //if( hasCommand( 'G', input ) ){
                              //println("this line '" + input + "' has a Gcommand");
                        //}
                        
                        
                        //record commands
                        lastCmds.add(1, input);
                        if ( lastCmds.size() > 20 ) {
                              lastCmds.remove( lastCmds.size() - 1 );
                        }
                      
                        serial.write( input + " " + char(13) );  //char(13) represents the carriage return
                        //checkForModals( input );
                  } else if ( connected ) { //the board is connected but XOFF has stopped transmission
                        println("the board is full! waiting for XON...");            
                  }
            } else { // the board is not connected
                  println("sorry, you should connect before sending!");
            }
      }
      
      //check the commands going to the board to see if modal commands should be updated in the CNC model
      //this applies mostly for modal commands that are set inside gcode files
      /*
      void checkForModals( String preInput ) {
            if( preInput.contains( "G20" ) || preInput.contains( "g20" ) ){
                  units = "G20";      
            } else if( preInput.contains( "G21" ) || preInput.contains( "g21" ) ){
                  units = "G21";        
            } 
            
      }*/
      
      //grab the boardstate info & parse it. this is super ghetto; the board actually outputs a JSON object
      // & could be parsed more elegantly
      void parseStateInfo(){ 
            String[] stateInfoParsed = split( stateInfo, "\"xyz\":[" ); // convert from something like: ln:34, xzy:[123.2,1.213,0.00]
            if( stateInfoParsed.length > 1 ){
                  String[] xyzInfo = split( stateInfoParsed[1], "," );     
                  xyzInfo[2] = xyzInfo[2].substring( 0, xyzInfo[2].length() - 1 );
                  
                  xPos = float( xyzInfo[0] );
                  yPos = float( xyzInfo[1] );
                  zPos = float( xyzInfo[2] );
            }
      }
      
      
/* ########################################################################

                   __
                   \ \
                    \ \
                     \ \
                      \/`\
                      |   \   _+,_
                       \   (_[____]_
                        '._|.-._.-._] /////////////////////
       ^^^^^^^^^^^^^^^^^^^^^'-' '-'^^^^^^^^^^^^^^^^^^^^^^^^^
      keep a queue of previous commands
      cycle back and forth on key presses, and return

######################################################################## */
      
      //retrieve the last serial command
      String lastCommand() {
            cmdIndex++;
            if ( cmdIndex >= lastCmds.size() )
                  cmdIndex = 0;
            return returnCommand( cmdIndex );
      }

      //retrieve the next serial command
      String nextCommand() {
            cmdIndex--;
            if ( cmdIndex < 0 )
                  cmdIndex = lastCmds.size() - 1;
            return returnCommand( cmdIndex );
      }

      //ouput a command from the memory queue
      String returnCommand( int index ) {
            String theCmd = (String)lastCmds.get( index );
            return theCmd;
      }

/* ########################################################################
                                      _    ~
                    __    .-----, '
     .-------------(__)--'     / \  .  -   "
    /  ========         :     |.-|  _       _
    \                   :     |'-|      ~
     '-------------------.     \ /  '  -   .
                          '-----' .   
                                      ~   _
      set specific machine settings

######################################################################## */
      
      //jog the thang
      void jog( String axis, int dir, float step ){
            
            if( axis.equals( "X" ) ){
                  write( "G91 X" + ( step * dir ) );
            } else if( axis.equals( "Y" ) ){
                  write( "G91 Y" + ( step * dir ) );      
            } else if( axis.equals( "Z" ) ){ 
                  write( "G91 Z" + ( step * dir ) );  
            }   
            
            //switch back to absolute distance mode
            write( "G90" );
      }
      
      //initial settings when first connecting to the board
      void init(){
           println("init");
           write("!");
           delay( 500 );
           setConfigs();
           delay( 500 );
           write( "?" );
           delay( 500 );
           write( "G0" );
             
      }
      
      //send config settings to the board
      void setConfigs(){ 
          println( "writing :" + units ); 
          write( units );
          xPos = 0;
          yPos = 0;
          zPos = 0;
                
      }
      
      //stop immediately
      void eStop(){
            if( streaming && transmit ) { //if a file is being streamed, add it to the top of the command queue
                  String[] stop = { "!" };
                  cmdQ = concat( stop, cmdQ );            
            }
            else {
                  write("!");
            }
            setConfigs(); //try to reset modal stuff like units
      }

      //toggle the units
      void setUnits() {
            if ( units.equals("G20") ) {
                  units = "G21";
            } else if ( units.equals("G21") ) {
                  units = "G20";
            }
            write( units );
      }
      
      //set the units
      void setUnits( float sel ) {
            if ( int( sel ) == 21 ) {
                  units = "G21";
            } else if ( int( sel ) == 20 ) {
                  units = "G20";
            }
            write( units );
      }

/* ########################################################################
                      _
                    _(_)_                          wWWWw   _
        @@@@       (_)@(_)   vVVVv     _     @@@@  (___) _(_)_
       @@()@@ wWWWw  (_)\    (___)   _(_)_  @@()@@   Y  (_)@(_)
        @@@@  (___)     `|/    Y    (_)@(_)  @@@@   \|/   (_)\
         /      Y       \|    \|/    /(_)    \|      |/      |
      \ |     \ |/       | / \ | /  \|/       |/    \|      \|/
      \\|//   \\|///  \\\|//\\\|/// \|///  \\\|//  \\|//  \\\|// 
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      get gCode files to run
      send them to the board

######################################################################## */
      
      //record the file we might run
      void setFileToRun( File potentialFile ) {
            fileToRun = potentialFile;
            cmdQ = loadStrings(fileToRun);
            //buildPreview( cmdQ );
      } 

      //run a file 
      void runFile() {
            fileIndex = 0;
            println("trying to send " + fileToRun.getName() );
            write( "G90" ); //switch to absolute coordinates
            streaming = true;
      }
      
      //send the next line of a gcode file, using6 XON/XOFF to control data flow
     void streamGCode() {
            if( streaming ){
                  if ( transmit ) { 
                        if (fileIndex < cmdQ.length) {
                              String cmd = cmdQ[fileIndex];
                              if( cmd.length() > 0 ){
                                    if ( cmd.charAt(0) != char(59)) {
                                          //println(cmd);
                                          write( cmd );
                                    }
                              }
                              else {
                                    write( " " );
                              }
                              fileIndex++;
                        } 
                        else {
                              streaming = false;
                              fileIndex = 0;
                        }
                  } //else
                      //  println( "Waiting for XON..." );
            } 
      }
}

