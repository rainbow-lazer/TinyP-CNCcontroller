/*
float roundToNearest( float unRounded, float nth ) {
      //round up to the nearest nth
      float rounded = round( unRounded / nth ) * nth;
      return rounded;
}

void camSetup(){
      //setup camera connection
      String[] cams = Capture.list();
      println( cams );
      myCapture = new Capture(this, 640, 480, cams[8], 60);
      //initialize the buffer for axonometric view
      dest.loadPixels();
      //initialize values for pixel distance comparison
      for( int p = 0; p < pixelDists.length; p++ ){
            pixelDists[p] = idealStep * 5;      
      }
}

void camUpdate(){
      //draw the camera view
      image(myCapture, width/2, height/1.6, 320, 240 );
      //and indicate where centerframe is
      stroke( 255, 0, 0, 50 );
      fill( 255, 50 );
      rect( width/2 + 160 - (camSample.width/2), height/1.6 + 120 - camSample.height/2, camSample.width, camSample.height );
      //rect( width/2 + (myCapture.width/2) - (camSample.width/2), height/1.6 + myCapture.height/2 - camSample.height/2, camSample.width, camSample.height );

      //get the position of the cam rounded up to the nearest physical pixel dimension 
      if( prevX != myCNC.xPos) {
            currentX = myCNC.xPos;
            roundedX = roundToNearest( currentX, idealStep );
            prevX = currentX;            
      }
      if( prevY != myCNC.yPos ){
            currentY = myCNC.yPos;
            roundedY = roundToNearest( currentY, idealStep );
            prevY = currentY;        
      }
      
      //draw the calculated axonometric view
      image(dest, 5, height/1.6, 288, 288); 
      //and indicate where in the scan we are
      rectMode(CENTER);
      int pixelX = int( roundedX / idealStep );
      int pixelY = int( roundedY / idealStep );
      rect( map(pixelX + 5, 5, dest.width, 5, 293 ), map(pixelY + height/1.6, height/1.6, dest.height + height/1.6, height/1.6, height/1.6 + 288), camSample.width, camSample.height );
            
      //get a sample from center of the cam
      camSample = myCapture.get( myCapture.width/2 - (camSample.width/2), myCapture.height/2 - (camSample.height/2), camSample.width, camSample.height );
      camSample.loadPixels(); 
      
      if( myCNC.streaming  ){

            /*
            float xOffset = pixelX - camSample.width/2;
            float yOffset = pixelY - camSample.height/2;
            
            //map each pixel from the camera sample to the correct part of the destination axonometric image
            for( int p = 0; p < camSample.pixels.length; p++ ){
                  float destX = p % camSample.width + xOffset;
                  float destY = floor( p / camSample.height ) + yOffset;
                  
                  if( destX >= 0 && destY >= 0 && destX <= dest.width && destY <= dest.height ){ 
                        
                       int destIndex = int(destY) * dest.width + int(destX); //pixels[y*width+x]  
                       dest.pixels[ destIndex ] = camSample.pixels[p]; 
                       println( "mapping " + hex(camSample.pixels[p]) + " from " + p + " (" + destX + "," + destY + ") to" + destIndex );
                       dest.updatePixels(); 
                  }         
                  
            }*/
            
            
            
             /* 
             ##############################################
            //get the x/y pixel coordinates in the dest img   idealStep * camSample.height/2
            int targetX = int( roundedX / idealStep );
            int targetY = int( roundedY / idealStep );
            
            println( "X " + myCNC.xPos + " " + roundedX + " " + targetX + " Y " + myCNC.yPos + " " + roundedY + " " + targetY );
           
            dest.set( targetX - camSample.width/2, targetY - camSample.height/2, camSample );
             ############################################## 
             */
  
            /*
            //##############################################
            //look at each pixel in the camera sample
            for( float h = 0; h < camSample.height; h++ ){
                  for( float w = 0; w < camSample.width; w++ ){
                        //get the actual position of each pixel in the camera sample
                        float realLocalX = currentX - float(camSample.width)/2.0 + w;
                        float realLocalY = currentY - float(camSample.height)/2.0 + h;
                        
                        //get the closest rounded pixel position (as it would be in the destination image)
                        int roundedLocalX = int( roundedX - camSample.width/2 + w );
                        int roundedLocalY = int( roundedY - camSample.height/2 + h );
                        
                        print( "(w" + w + ", h" + h + ") RLX " +  roundedLocalX + " RLY " + roundedLocalY );
                        
                        if( roundedLocalX >= 0 && roundedLocalY >= 0 ){
                              //get the distance between the actual & ideal pixel locations
                              float distance = dist( realLocalX, realLocalY, roundedLocalX, roundedLocalY );
                              
                              //see if the distance is closer than what was previously recorded
                              int pixIndex = int( roundedLocalY * dest.width + roundedLocalX );
                              
                              //if( distance < pixelDists[ pixIndex ] ){
                                    //println( realLocalX + " " + realLocalY + " " + roundedLocalX + " " + roundedLocalY + " " + distance + " " + pixIndex );

                                    //if it's closer, save that pixel to the dest buffer
                                    dest.pixels[ pixIndex ] = camSample.pixels[ int(h) * camSample.width + int(w) ];
                                    print( "mapping px " + (int(h) * camSample.width + int(w)) + " from camsample to " + pixIndex + " of dest " );
                                    pixelDists[ pixIndex ] = distance;
                                     dest.updatePixels();     
                              //}
                        } 
                        
                        println("");
                        
                  }
            } 
            
            //############################################## 
            */
            
            
            /*
             //##############################################
            //get the x/y pixel coordinates in the dest img
            int targetX = int( roundedX / idealStep );
            int targetY = int( roundedY / idealStep );
            
            println( "X " + myCNC.xPos + " " + roundedX + " " + targetX + " Y " + myCNC.yPos + " " + roundedY + " " + targetY );
           
            dest.set( targetX, targetY, camSample );
           //############################################## 
           */
           
           
           /* ##############################################
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
            ############################################## */
  //    } 
//}


