package org.p2f1.controllers;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

import javax.swing.JButton;
import javax.swing.JOptionPane;

import org.p2f1.models.MainWindowModel;
import org.p2f1.views.MainWindowView;

import com.SerialPort.SerialPort;

// TODO File path /Users/Roger/Documents/eclipse/P2F1/src/org/p2f1/assets/data.txt

public class MainWindowController implements ActionListener{

	private MainWindowView view = null;
	private MainWindowModel model = null;
	private SerialPort sp = null;
	private int c = 0;
	private float stepp = 0, k = 0;
	private static final byte UART = '0', PB = '1', START = '2', END = '3', IR = '4';
	private static final boolean DEBUG = true;
	private static final int TIME = 50;
	
	public MainWindowController(MainWindowView view, MainWindowModel model){
		try{
			this.sp = new SerialPort();	
			this.view = view;
			this.model = model;
			this.view.associateController(this);
			this.view.setBaudRateList(sp.getAvailableBaudRates());
			this.view.setPortsList(sp.getPortList());
		}catch(Exception e){
			System.out.println(e.getMessage());
		}
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		if(e.getSource() instanceof JButton){
			JButton btn = (JButton) e.getSource();
			switch(btn.getName()){
				case MainWindowView.BTN_INFRAROJOS:
					//TODO TX/RX IR
					try {
						setupUART();
						sendBytes(IR);
					} catch (Exception e2) {
						// TODO Auto-generated catch block
						e2.printStackTrace();
					}
					break;
				case MainWindowView.BTN_UART:
					//TODO TX/RX protocol 
					if(model.checkInputFile(view.getFile())){
						try{
							setupUART();
							sendBytes(UART);
						}catch (Exception e1){
							e1.printStackTrace();
						}
					}else{
						JOptionPane.showMessageDialog(null, "Has de seleccionar un fitxer de text!", "Missatge",JOptionPane.ERROR_MESSAGE);
					}
					break;
			}
		}
	}
	
	public void showView(){
		view.setVisible(true);
	}
	
	private void sendPB() throws Exception {
		System.out.println();
		if (stepp < 1) {
			if (k <= 1) k += stepp;
			else {
				if (DEBUG) Thread.sleep(TIME);
				if (DEBUG) System.out.println("Sending: " + (char) PB + "...");
				sp.writeByte((byte) PB);
				System.out.println("Recieved: " + (char) sp.readByte());
				k = stepp;
				c++;
			}
		} else for (int l = 0; l < (int)stepp; l++) {
			if (DEBUG) Thread.sleep(TIME);
			if (DEBUG) System.out.println("Sending: " + (char) PB + "...");
			sp.writeByte((byte) PB);
			System.out.println("Recieved: " + (char) sp.readByte());
			c++;
		}
	}
	
	private void setupUART() throws Exception{
		String sPort = view.getPort();
		int baudrate = view.getBaudrate();
		System.out.printf("Opening port %s @%d..\n", sPort, baudrate);
		sp.openPort(sPort, baudrate);
	}
	
	private void sendBytes(byte id) throws Exception{
		if (id == UART) sendUART();
		else sendIR();
	}
	
	private String readFile() throws IOException{
	    BufferedReader reader = new BufferedReader(new FileReader(view.getFile()));
	    String line = null;
	    StringBuilder stringBuilder = new StringBuilder();
	    String ls = System.getProperty("line.separator");
	    while((line = reader.readLine()) != null){
	        stringBuilder.append(line);
	        stringBuilder.append(ls);
	    }
	    reader.close();
	    return stringBuilder.toString();
	}
	
	private void sendIR() throws FileNotFoundException{
		Thread t = new Thread(new Runnable(){
	        public void run(){
	        	try{
	        		if (DEBUG) Thread.sleep(5000);
	        		if (DEBUG) System.out.println("Sending: " + (char) IR + "...");
	        		sp.writeByte(IR);
	        		System.out.println("Recieved: " + (char) sp.readByte());
	        		sp.closePort();
				}catch (Exception e) {
					e.printStackTrace();
				}
	        }
	    });
	    t.start();
	}
	
	private void sendUART() throws FileNotFoundException{
		Thread t = new Thread(new Runnable(){
	        public void run(){
	        	try{
	        		String content = readFile();
	        		sendCharacters(content);
				}catch (Exception e) {
					e.printStackTrace();
				}
	        }
	    });
	    t.start();
	}
	
	private void sendCharacters(String content) throws Exception {
		view.setProgressBarValue(0);
		String[] games = content.split("\n");
		char[] bytes = new char[4];
		int price = 0, total = 0, size = games.length;
		float pb = 0, step = (float) (100.0/(content.length() - size));
		stepp = (float) (8.0 / games.length);
		System.out.println(stepp);
		System.out.println(step);
		System.out.println();
		if (DEBUG) Thread.sleep(TIME);
		if (DEBUG) System.out.println("Sending: " + (char) START + "...");
		sp.writeByte(START);
		System.out.println("Recieved: " + (char) sp.readByte());
		for (int i = 0; i < games.length; i++) {
			System.out.println();
			if (DEBUG) Thread.sleep(TIME);
			if (DEBUG) System.out.println("Sending: " + (char) UART + "...");
			sp.writeByte(UART);
			System.out.println("Recieved: " + (char) sp.readByte());
			System.out.println();
			for (int j = 0; j < games[i].length(); j++) {
				char b = games[i].charAt(j);
				if (j >= 3 && j <= 6) bytes[j-3] = (char)b;
				pb += step;
				view.setProgressBarValue((int) (Math.ceil(pb)/1.5));
				if (DEBUG) Thread.sleep(TIME);
				if (DEBUG) System.out.println("Sending: " + (char) (char)b + "...");
				sp.writeByte((byte) b);
				System.out.println("Recieved: " + (char) (char) sp.readByte());
			}
			price = Integer.parseInt(new String(bytes));
    		total += price;
			sendPB();
		}
		System.out.println();
		for (int i = 0; i <= 8 - c; i++) {
			if (DEBUG) Thread.sleep(TIME);
			if (DEBUG) System.out.println("Sending: " + (char) PB + "...");
			sp.writeByte((byte) PB);
			System.out.println("Recieved: " + (char) sp.readByte());
			pb += step;
			view.setProgressBarValue((int) (Math.ceil(pb)/1.5));
		}
		System.out.println();
		if (DEBUG) Thread.sleep(TIME);
		if (DEBUG) System.out.println("Sending: " + (char) END + "...");
		sp.writeByte((byte) END);
		System.out.println("Recieved: " + (char) sp.readByte());
		sp.closePort();
        view.setProgressBarValue(100);
        view.setPrice(total);
        view.setGames(size);
	}
	
}
