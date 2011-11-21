/*
float roundToNearest( float unRounded, float nth ) {
      //round up to the nearest nth
      float rounded = round( unRounded / nth ) * nth;
      return rounded;
}

void camSetup(){

      String[] cams = Capture.list();
      println( cams );
      myCapture = new Capture(this, 80, 60, cams[8], 120);
      dest.loadPixels();
}

void camUpdate(){
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
}
*/
