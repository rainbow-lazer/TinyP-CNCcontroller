This is a basic Processing GUI for driving the TinyG CNC controller. 

It's very buggy at the moment, but it still beats pure command line controls. 

Jogging for all axes is implemented using key commands (see the source for mappings). 

Command-line GCodes work great, files can be loaded and streamed; The software tries to listen for XON/XOFF to properly stream. 


nov-20-2011
#############
fixed some memory-bogging issues that caused longer geode files to send incorrectly

tweaked the geode streaming function to work better

jan-11-2012
#############
tweaked the jog rates to favor inches, added one standard jog function in the CNC object model w/ forced return to absolute distance mode, made text input a little more sane

TO DO:
-make the G90 commands in the jog function not get logged in the memory.