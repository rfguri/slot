package org.p2f1.controllers;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.Charset;

import javax.swing.JButton;
import javax.swing.JOptionPane;
import javax.swing.JProgressBar;

import org.p2f1.models.MainWindowModel;
import org.p2f1.views.MainWindowView;

import com.SerialPort.SerialPort;

// TODO File path /Users/Roger/Documents/eclipse/P2F1/src/org/p2f1/assets/data.txt

public class MainWindowController implements ActionListener{

	private MainWindowView view = null;
	private MainWindowModel model = null;
	private SerialPort sp = null;
	
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
					JOptionPane.showMessageDialog(null, "M'has de programar!", "Missatge",JOptionPane.INFORMATION_MESSAGE);
					break;
				case MainWindowView.BTN_UART:
					//TODO TX/RX protocol 
					if(model.checkInputFile(view.getFile())){
						try{
							setupUART();
							sendBytes();
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
	
	private void setupUART() throws Exception{
		String sPort = view.getPort();
		int baudrate = view.getBaudrate();
		System.out.printf("Opening port %s @%d..\n", sPort, baudrate);
		sp.openPort(sPort, baudrate);
	}
	
	private void sendBytes() throws Exception{
		File file = new File(view.getFile());
		int size = (int)file.length();
		InputStream in = new FileInputStream(file);
		Reader reader = new InputStreamReader(in, Charset.defaultCharset()); 
		Reader buffer = new BufferedReader(reader);
		Thread t = new Thread(new Runnable(){
	        public void run(){
	        	try{
					handleCharacters(buffer, size);
				}catch (Exception e) {
					e.printStackTrace();
				}
	        }
	    });
	    t.start();
		
	}
	
	private void handleCharacters(Reader reader, int size) throws Exception{
        int b, i = 0, step = 100/size;
        i += step;
        while ((b = reader.read()) != -1){
        	Thread.sleep(100);
        	i += step;
        	view.updateProgressBar(i);
        	sp.writeByte((byte) b);
        	System.out.printf("rcv: %s\n",(char) sp.readByte());
        }
        sp.closePort();
        view.updateProgressBar(100);
    }
	
}
