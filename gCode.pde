//parse gCode

//some of this code adapted from:
// Arduino G-code Interpreter
// v1.0 by Mike Ellery - initial software (mellery@gmail.com)
// v1.1 by Zach Hoeken - cleaned up and did lots of tweaks (hoeken@gmail.com)
// v1.2 by Chris Meighan - cleanup / G2&G3 support (cmeighan@gmail.com)
// v1.3 by Zach Hoeken - added thermocouple support and multi-sample temp readings. (hoeken@gmail.com)


//look for the command if it exists.
boolean hasCommand(char key, String codeLine) {

      for ( int i = 0; i < codeLine.length(); i++ ) {	
            if ( codeLine.charAt(i) == int( key ) ) {
                  return true;
            }
      }

      return false;
}

//look for the number that appears after the char key and return it
// eg, "G1 Y0.027777778 F20" would return 0.027777778 for the key 'Y'
float searchString(char key, String gCodeLine ) {

      String coords = new String();

      //look thru each char in the gcode line
      for ( int c = 0; c < gCodeLine.length(); c++ ) {
            //get all digits and decimal points after key, until the next space or character
            if ( gCodeLine.charAt( c ) == int( key ) ) {
                  c++;
                  while ( c < gCodeLine.length () ) {
                        int currentChar = int(gCodeLine.charAt(c));
                        //only keep recording if the character is a . or 0-9      
                        if ( !( currentChar == 46 || ( currentChar <= 57 && currentChar >= 48 )))
                              break;

                        coords += gCodeLine.charAt(c);
                        c++;
                  }
                  return float( coords );
            }
      }

      return float( coords );
}


//parse a line of Gcode to get the end coordinates in XYZ
float[] getCoords( String gCodeLine, float[] currentPos ) {

      float[] newPos = currentPos;

      //the character / means delete block... used for comments and stuff.
      //Partkam seems to use ( for comments
      if ( gCodeLine.charAt( 0 ) == int( '/' ) || gCodeLine.charAt( 0 ) == int( '(' ) ) {
            println("Comment: " + gCodeLine);
            return currentPos;
      }

      //is there a modal change in this line?
      if ( hasCommand('G', gCodeLine) ) {
            newPos[3] = searchString('G', gCodeLine );
      }

      int gMode = int(newPos[3]);
      
      //did we get a gcode?
      if ( hasCommand('X', gCodeLine) ) {
            newPos[0] = searchString('X', gCodeLine );
      }

      if ( hasCommand('Y', gCodeLine) ) {
            newPos[1] = searchString('Y', gCodeLine );
      }

      if ( hasCommand('Z', gCodeLine) ) {
            newPos[2] = searchString('Z', gCodeLine );
      }

      //linear interpolation: fast or slow
      if ( gMode == 0 || gMode == 1 ) { 
            
      }
     //clockwise/counterclockwise circular interpolation 
      else if ( gMode == 2 || gMode == 3 ) { 
            
            
            
            /*
            float[] cent; //centerpoint in x/y/z

            // Centre coordinates are always relative
            cent[0] = searchString('I', gCodeLine) + newPos[0];
            cent[1] = searchString('J', gCodeLine) + newPos[1];
            float angleA, angleB, angle, radius, length, aX, aY, bX, bY;

            aX = (newPos[0] - cent[0]);
            aY = (newPos[1] - cent[1]);
            bX = (fp.x - cent.x);
            bY = (fp.y - cent.y);

            if (code == 2) { // Clockwise
                  angleA = atan2(bY, bX);
                  angleB = atan2(aY, aX);
            } 
            else { // Counterclockwise
                  angleA = atan2(aY, aX);
                  angleB = atan2(bY, bX);
            }

            // Make sure angleB is always greater than angleA
            // and if not add 2PI so that it is (this also takes
            // care of the special case of angleA == angleB,
            // ie we want a complete circle)
            if (angleB <= angleA) angleB += 2 * M_PI;
            angle = angleB - angleA;

            radius = sqrt(aX * aX + aY * aY);
            length = radius * angle;
            int steps, s, step;
            steps = (int) ceil(length / curve_section);

            FloatPoint newPoint;
            for (s = 1; s <= steps; s++) {
                  step = (code == 3) ? s : steps - s; // Work backwards for CW
                  newPoint.x = cent.x + radius * cos(angleA + angle * ((float) step / steps));
                  newPoint.y = cent.y + radius * sin(angleA + angle * ((float) step / steps));
                  set_target(newPoint.x, newPoint.y, fp.z);

                  // Need to calculate rate for each section of curve
                  if (feedrate > 0)
                        feedrate_micros = calculate_feedrate_delay(feedrate);
                  else
                        feedrate_micros = getMaxSpeed();

                  // Make step
                  dda_move(feedrate_micros);
            }
            */
            
      } 

      return newPos;
} 


void buildPreview( String[] gCode ) {

      model = new UVertexList();
      int lineNum = 0;

      for ( int i = 0; i < gCode.length; i++ ) {
            //parse each line. if there's a new x, y, or z value, update it
            //otherwise carry over the previously set value
            gCodePos = getCoords( gCode[ lineNum ], gCodePos );
            lineNum++;

            model.add( gCodePos[0], gCodePos[1], gCodePos[2] );
      }

      //move the render so it's centered on the origin
      model.calcBounds();
      model.center();
}

void renderPreview() {
      if ( model.n > 0) {
            //generate the gcode view offscreen
            pushMatrix();
            model.setDimensions(renderWd);
            //nav.doTransforms();
            renderWindow.beginDraw();
            renderWindow.translate( renderWd/2, renderHt/2, nav.trans.z );
            renderWindow.rotateX( nav.rot.x );
            renderWindow.rotateY( nav.rot.y );
            renderWindow.rotateZ( nav.rot.z );
            renderWindow.background(255);
            renderWindow.beginShape(LINES);
            for ( int i = 1; i < model.n; i++ ) {
                  //make sure x and y are w/in the render bounds
                  renderWindow.vertex( model.v[i-1].x, model.v[i-1].y, model.v[i-1].z ); 
                  renderWindow.vertex( model.v[i].x, model.v[i].y, model.v[i].z );
            }
            renderWindow.endShape();
            renderWindow.endDraw();
            popMatrix();
            //put the gcode view on screen
      } 
      image(renderWindow, renderX, renderY );
}

public void mouseDragged() {
      //if the the mouse is over the render window
      if (  mouseX > renderX && 
            mouseX < renderX + renderWd &&
            mouseY > renderY &&
            mouseY < renderY + renderHt ) {
            nav.mouseDragged();
      }
}

void mouseWheel(int delta) {
      if (  mouseX > renderX && 
            mouseX < renderX + renderWd &&
            mouseY > renderY &&
            mouseY < renderY + renderHt ) {      
            nav.trans.z -= delta;
      }
}

