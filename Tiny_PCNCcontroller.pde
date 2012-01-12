//--=-====-=---=-=-=---==-=-=---=-=-=-=-=-=-=-=--
//talk to the TinyG board thru a Processing GUI
//--=-====-=---=-=-=---==-=-=---=-=-=-=-=-=-=-=--

import controlP5.*; //controlp5 lib for gui
import processing.serial.*; //serial library for board-talkin
import javax.swing.*; //java lib for file choosing
//import org.json.*; //json parsing lib for interpreting inter-step position info
import java.awt.datatransfer.*; //libs for clipboard access
import java.awt.Toolkit;       //ditto

import unlekker.util.*;            //modelbuilder libs for 3D viewing
import unlekker.modelbuilder.*;      //ditto

/*
///stuff for custom camera control
import processing.video.*;
Capture myCapture;
PImage camSample = createImage( 2, 2, RGB );
float prevX = 0;
float prevY = 0;
float currentX = 0;
float currentY = 0;
float roundedX;
float roundedY;
float idealStep = (1.0/72.0);
PImage dest = createImage( 1296, 1296, RGB );
int pixIndex = 0;
float[] pixelDists = new float[dest.width*dest.height];
//end stuff for camera control
*/


ControlP5 portControls; //port controls
ControlP5 conDepControls; //controls that depend on a connection

ClipHelper clipBoard = new ClipHelper();

DropdownList portList;

Textarea serialOutput;
Textarea machineState;
Textfield serialInput;
Textfield filePath;

Button submit;
Button paste;
Button eStop;
Button loadFile;
Button runFile;
Button connect;
Button disconnect;

RadioButton unitSelect;

//gcode viewer stuff
MouseNav3D nav;
UVertexList model = new UVertexList();

int renderX = 5;
int renderY = 520;
int renderWd = 400;
int renderHt = 300;
PGraphics renderWindow;
float[] gCodePos = { 0.0, 0.0, 0.0, 0.0 }; //0,1,2,3 corresponds to x,y,z, Gmode (G1, G0, etc)
int lineNum = 0;

CNC myCNC;

void setup() {
      frameRate(200);
      size( 768, 840 );
      myCNC = new CNC(this);
      guiSetup();
      
      //3D gcode preview setup
      nav=new MouseNav3D(this);
      nav.trans.set(width/2, height/2, 0);
      
      //offscreen buffer we'll render the gCode to; this makes it easy to place onscreen w/ other gui stuff
      renderWindow = createGraphics(renderWd, renderHt, P3D);
      addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
            public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
                  mouseWheel(evt.getWheelRotation());
            }
      }); 
      

      //camera control stuff
     // camSetup();

}

void draw() { 
      background(200);
      filePath.setFocus( false );
      
      if( myCNC.readCharacter() ){
            updateGUItext();
      }
      
      if( myCNC.streaming ) {
            myCNC.streamGCode();
      }
      
      renderPreview();
       
      //camera control stuff
      //camUpdate(); 

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
      //see if this is a jog key; if not, focus on the input box for text typing
      if (key == CODED && ( keyCode == UP || keyCode == DOWN || keyCode == RIGHT || keyCode == LEFT ) ) {
            //println("keyCode " + keyCode);
            if ( keyCode == UP ) {
                  if( serialInput.isFocus() ){
                        serialInput.setText( myCNC.lastCommand() );
                  } else {
                        println("Y+");
                        myCNC.jog( "Y", 1, 0.1 );
                  }
            } 
            else if ( keyCode == DOWN ) {
                  if( serialInput.isFocus() ) {
                        serialInput.setText( myCNC.nextCommand() );
                  } else {
                        println("Y-");
                        myCNC.jog( "Y", -1, 0.1 );
                  }
            } 
            else if ( keyCode == RIGHT ) {
                  if( !serialInput.isFocus() )  {
                        println("X+");
                        myCNC.jog( "X", 1, 0.1 );
                  }
            }
            else if ( keyCode == LEFT ) {
                  if( !serialInput.isFocus() )  {
                        println("X-");
                       myCNC.jog( "X", -1, 0.1 );
                  }
            }
      } 
      else if( key == '[' || key == '{' || key == ']' || key == '}' || key == '-' || key == '_' || key == '+' || key == '=' || key == ':' || key == ';' || key == '"' || key == char(39) ) {
            //println("key " + key);      
            if( key == '[' || key == '{' ) {
                  if( !serialInput.isFocus() )  {
                        println("Z-");
                        myCNC.jog( "Z", -1, 0.01 );
                  }
            }
            else if( key == ']' || key == '}' ) {
                  if( !serialInput.isFocus() )  {
                        println("Z+");
                        myCNC.jog( "Z", 1, 0.01 );
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
                 //dest.save("output.jpg");
            }
      } else { //text input is coming; automatically put it in the input line
            serialInput.setFocus( true );
      }
}

