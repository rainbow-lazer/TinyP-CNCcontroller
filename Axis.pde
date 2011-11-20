class Axis {

      String name;
      /*
       0 = Disable. All input to that axis will be ignored and the axis will not move.
       1 = Standard. Linear axes move in length units. Rotary axes move in degrees.
       2 = Inhibited. Axis values are taken into account when planning moves, but the axis will not move. Use this to perform a Z kill. 
       Rotary axes can have these additional modes.
             3 = Radius mode. In radius mode gcode values are interpreted as linear units; either inches or mm depending on the prevailing G20/G21 setting. The conversion of linear units to degrees is accomplished using the radius setting for that axis. See $aRA for details.
             4 = Slave X mode - rotary axis slaved to movement in X dimension
             5 = Slave Y mode - rotary axis slaved to movement in Y dimension
             6 = Slave Z mode - rotary axis slaved to movement in Z dimension
             7 = Slave XY mode - rotary axis slaved to movement in XY plane
             8 = Slave XZ mode - rotary axis slaved to movement in XZ plane
             9 = Slave YZ mode - rotary axis slaved to movement in YZ plane
             10 = Slave XYZ mode - rotary axis slaved to movement in XYZ space */
      int axisMode;
      boolean enabled;
      float seekRate;
      float feedRate;
      //float hardLimit;
      //float softLimit;
      float jerkMax;
      float cornerDelta;
      //float radiusVal; //only applies to axismodes above 2
      //limitMode
      //homingEnable
      //homingRate
      //homingCloseRate
      //homingOffset
      //homingBackoff
      
      Axis( String _name ){
            name = _name;
                  
            
      }
}

