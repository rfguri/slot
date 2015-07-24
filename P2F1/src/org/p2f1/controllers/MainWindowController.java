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

import org.p2f1.models.MainWindowModel;
import org.p2f1.views.MainWindowView;

import com.SerialPort.SerialPort;

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
					//TODO Afegir el codi per enviar per IR
					JOptionPane.showMessageDialog(null, "M'has de programar!", "Missatge",JOptionPane.INFORMATION_MESSAGE);
					break;
				case MainWindowView.BTN_UART:
					//TODO Afegir el codi per enviar per UART
					if(model.checkInputFile(view.getFile())){
						JOptionPane.showMessageDialog(null, "M'has de programar!", "Missatge",JOptionPane.INFORMATION_MESSAGE);
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
	
}
