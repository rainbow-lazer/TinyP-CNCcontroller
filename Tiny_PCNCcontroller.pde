//--=-====-=---=-=-=---==-=-=---=-=-=-=-=-=-=-=--
//talk to the TinyG board thru a Processing GUI
//--=-====-=---=-=-=---==-=-=---=-=-=-=-=-=-=-=--

import controlP5.*; //controlp5 lib for gui
import processing.serial.*; //serial library for board-talkin
import javax.swing.*; //java lib for file choosing
//import org.json.*; //json parsing lib for interpreting inter-step position info

/*
//stuff for custom camera control
import processing.video.*;
Capture myCapture;
PImage camSample = createImage( 2, 2, RGB );
float prevX = 0;
float prevY = 0;
float roundedX;
float roundedY;
float idealStep = (1.0/72.0);


PImage dest = createImage( 432, 432, RGB );
int pixIndex = 0;

float roundToNearest( float unRounded, float nth ){
      //round up to the nearest nth
      float rounded = round( unRounded / nth ) * nth;
      return rounded;
}

//end stuff for camera control
*/

ControlP5 portControls; //port controls
ControlP5 conDepControls; //controls that depend on a connection

DropdownList portList;

Textarea serialOutput;
Textarea machineState;
Textfield serialInput;
Textfield filePath;

Button submit;
Button eStop;
Button loadFile;
Button runFile;
Button connect;
Button disconnect;

RadioButton unitSelect;

CNC myCNC;

void setup() {
      frameRate(200);
      size( 600, 800 );
      myCNC = new CNC(this);
      guiSetup();

/*
      //camera control stuff
       String[] cams = Capture.list();
        println( cams );
        myCapture = new Capture(this, 80, 60, cams[8], 120);
        dest.loadPixels();
*/
}

void draw() { 
      background(200);
      filePath.setFocus( false );
      
      if( myCNC.readCharacter() ){
            updateGUItext();
      }
      
      if( myCNC.runFile ) {
            myCNC.streamGCode();
      }
      
      /*      
      //camera control stuff
      image(myCapture, width/2, height/1.6, 160, 120 );
      image(dest, 5, height/1.6, 288, 288); 
      //get the position of the cam rounded up to the nearest 
      if( prevX != myCNC.xPos) {
            roundedX = roundToNearest( myCNC.xPos, idealStep );
            prevX = myCNC.xPos;            
      }
      if( prevY != myCNC.yPos ){
            roundedY = roundToNearest( myCNC.yPos, idealStep );
            prevY = myCNC.yPos;        
      }
      
      //get a 2-by-2 sample of center of the cam
      //camSample = myCapture.get( myCapture.width/2 - 1, myCapture.height/2 - 1, 2, 2 );
          
      if( myCNC.runFile ){
            
            //get the x/y pixel coordinates in the dest img
            int targetX = int( roundedX / idealStep );
            int targetY = int( roundedY / idealStep );
            
            println( "X " + myCNC.xPos + " " + roundedX + " " + targetX + " Y " + myCNC.yPos + " " + roundedY + " " + targetY );
           
            //compare the sample pixels to whats in the destination
            for( int yRep = 0; yRep < 2; yRep++ ){
                  for( int xRep = 0; xRep < 2; xRep++ ){
                        
                        int targetPix = targetY * dest.width + ( targetX + xRep % 2 );
                        //if( dest.pixels[ targetPix ] == 0 ){
                             // println( "setting dest " + ( targetX + xRep % 2 ) + "," + targetY + " to " + camSample.pixels[ yRep * camSample.width + xRep ] );
                              dest.pixels[ targetPix ] = myCapture.pixels[ myCapture.height/2 - 1 + yRep * myCapture.width + myCapture.width/2 - 1 + xRep ];    
                              dest.updatePixels();
                        //}  
                  }
                  targetY++;
            }
      } 
      //end cam control stuff
      */
} 

void captureEvent(Capture myCapture) {
  myCapture.read();
}

//get info from the board when it's available, and update it in display
void serialEvent( Serial p ) {
      
      //myCNC.readString();
      //updateGUItext();
}

//keyboard control
//recall previous commands into the text field, jog the machine
void keyPressed() {
      if (key == CODED) {
            if ( keyCode == UP ) {
                  if( serialInput.isFocus() ){
                        serialInput.setText( myCNC.lastCommand() );
                  } else {
                        println("Y+");
                        myCNC.write( "G91 F30 Y.1" );
                  }
            } 
            else if ( keyCode == DOWN ) {
                  if( serialInput.isFocus() ) {
                        serialInput.setText( myCNC.nextCommand() );
                  } else {
                        println("Y-");
                        myCNC.write( "G91 F30 Y-0.1" );
                  }
            } 
            else if ( keyCode == RIGHT ) {
                  if( !serialInput.isFocus() )  {
                        println("X+");
                        myCNC.write( "G91 F30 X0.1" );
                  }
            }
            else if ( keyCode == LEFT ) {
                  if( !serialInput.isFocus() )  {
                        println("X-");
                        myCNC.write( "G91 F30 X-0.1" );
                  }
            }
      } 
      else {
            if( key == '[' || key == '{' ) {
                  if( !serialInput.isFocus() )  {
                        println("Z-");
                        myCNC.write( "G91 F30 Z-0.1" );
                  }
            }
            else if( key == ']' || key == '}' ) {
                  if( !serialInput.isFocus() )  {
                        println("Z+");
                        myCNC.write( "G91 F30 Z0.1" );
                  }
            }
            else if( key == '-' || key == '_' ) {
                  if( !serialInput.isFocus() )  {
                        println("A-");
                  }
            }
            else if( key == '+' || key == '=' ) {
                  if( !serialInput.isFocus() )  {
                        println("A+");
                  }
            }
            else if( key == ':' || key == ';') {
                  if( !serialInput.isFocus() )  {
                        println("B-");
                  }
            }
            else if( key == '"' || key == char(39) ) {
                  if( !serialInput.isFocus() )  {
                        println("B+");
                  }
            }
            else if( key == 's' ) {
                  dest.save("output");
            }
      }
}
