void loadFile() {
      File ourFile = getFile();
      //get the file path
      String fullPath = ourFile.getPath();
      String fileName = ourFile.getName();
      
      if ( !fileName.equals("data") ) { 
            filePath.setText( fileName );
            myCNC.setFileToRun( ourFile );
      }   
}

File getFile() {
     File selectedFile = new File(dataPath("gCode-72.0ppi-6.0x6.0.nc"));
      
      try { 
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
      } 
      catch (Exception e) { 
            e.printStackTrace();
      } 

      // create a file chooser 
      final JFileChooser fc = new JFileChooser(); 

      // in response to a button click: 
      int returnVal = fc.showOpenDialog(this); 

      if (returnVal == JFileChooser.APPROVE_OPTION) { 
            selectedFile = fc.getSelectedFile();
      }
      
      return selectedFile;  
}




