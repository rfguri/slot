package org.p2f1.models;

public class MainWindowModel {

	public boolean checkInputFile(String sFile){
		if(sFile.length() > 0){
			return true;
		}	
		return false;
	}
	
}
