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
	private FileReader file = null;
	public int c = 0;
	private float stepp = 0, k = 0;
	private static final byte UART = '0';
	private static final byte IR = '1';
	private static final byte PB = '2';
	
	public MainWindowController(MainWindowView view, MainWindowModel model){
		try{
			this.sp = new SerialPort();	
			this.view = view;
			this.model = model;
			this.view.associateController(this);
			this.view.setBaudRateList(sp.getAvailableBaudRates());
			this.view.setPortsList(sp.getPortList());
			this.file = new FileReader(view.getFile());
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
						sendBytes(IR);
					} catch (Exception e2) {
						// TODO Auto-generated catch block
						e2.printStackTrace();
					}
					JOptionPane.showMessageDialog(null, "M'has de programar!", "Missatge",JOptionPane.INFORMATION_MESSAGE);
					break;
				case MainWindowView.BTN_UART:
					//TODO TX/RX protocol 
					if(model.checkInputFile(view.getFile())){
						try{
							setupUART();
							sendBytes(UART);
							//sendBytes(PB);
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
		if (stepp < 1) {
			if (k <= 1) k += stepp;
			else {
				sp.writeByte((byte) PB);
				k = stepp;
				c++;
			}
		} else for (int l = 0; l < Math.ceil(stepp); l++) {
			sp.writeByte((byte) PB);
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
		sp.writeByte(id);
		if (id == UART) sendUART();
	}
	
	private String readFile() throws IOException{
	    BufferedReader reader = new BufferedReader(file);
	    String line = null;
	    StringBuilder stringBuilder = new StringBuilder();
	    String ls = System.getProperty("line.separator");
	    while((line = reader.readLine()) != null){
	        stringBuilder.append(line);
	        stringBuilder.append(ls);
	    }
	    return stringBuilder.toString();
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
		String[] games = content.split("\n");
		char[] bytes = new char[4];
		int price = 0, total = 0, size = games.length;
		float pb = 0, step = (float) (100.0/(content.length() - size));
		stepp = (float) (8.0 / games.length);
		System.out.println(stepp);
		System.out.println(step);
		for (int i = 0; i < games.length; i++) {
			for (int j = 0; j < games[i].length(); j++) {
				Thread.sleep(100);
				char b = games[i].charAt(j);
				System.out.println(b);
				if (j >= 3 && j <= 6) bytes[j-3] = (char)b;
				pb += step;
				System.out.printf("PB --> %f", pb);
				view.setProgressBarValue((int) Math.ceil(pb));
			}
			price = Integer.parseInt(new String(bytes));
    		total += price;
			System.out.println();
			sendPB();
		}
		for (int i = 0; i <= 8 - c; i++) sp.writeByte((byte) PB);
		view.setProgressBarValue(100);
		sp.closePort();
        view.setProgressBarValue(100);
        view.setPrice(total);
        view.setGames(size);
	}
	
}
