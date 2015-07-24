package org.p2f1.views;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JTextField;

import org.p2f1.controllers.MainWindowController;

public class MainWindowView  extends JFrame{

	private static final long serialVersionUID = 8459978615692456891L;
	
	public static final String BTN_UART = "BTN_UART";
	public static final String BTN_INFRAROJOS = "BTN_INFRAROJOS";
	
	//Constants que contenen la mida de la pantalla de l'usuari
	private static final int SCREEN_WIDTH = (int) Toolkit.getDefaultToolkit().getScreenSize().getWidth();
	private static final int SCREEN_HEIGHT = (int) Toolkit.getDefaultToolkit().getScreenSize().getHeight();
	
	//Constants que indiquen la mida de la finestra per defecte
	private static final int WINDOW_WIDTH = 800;
	private static final int WINDOW_HEIGHT = 600;
	
	//Declarem les variables dels elements de la finestra gràfica
	private JPanel topPanel = null;
	private JPanel centerPanel = null;
	private JPanel bottomPanel = null;
	private JPanel infoPanel = null;
	private JPanel portPanel = null;
	private JPanel filePanel = null;
	private JProgressBar progressBar = null;
	private JLabel lblJugades = null;
	private JLabel lblPremis = null;
	private JLabel lblPort = null;
	private JLabel lblBaudRate = null;
	private JLabel lblPath = null;
	private JTextField txtPath = null;
	private JButton btnPath = null;
	private JButton btnInfraRojos = null;
	private JButton btnUART = null;
	private JComboBox<Integer> comboBaud = new JComboBox<Integer>();
	private JComboBox<String> comboPort = new JComboBox<String>();
	
	//Variable pel JFileChooser
	private JFileChooser fileChooser = new JFileChooser();
	
	//Constructor de la classe MainWindowView (finestra gràfica)
	public MainWindowView(){
		configureWindow();
		configureTopPanel();
		configureCenterPanel();
		configureBottomPanel();
		
		//Controlador del botó de selecció de fitxer
		btnPath.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent e) {
				
				int nReturn = fileChooser.showOpenDialog(MainWindowView.this);
				
				if(nReturn == JFileChooser.APPROVE_OPTION){
					txtPath.setText(fileChooser.getSelectedFile().toString());
				}else{
					txtPath.setText("");
				}
				
			}
		});
		
	}
	
	//Configurem els paràmetres de la finestra
	private void configureWindow(){
		setTitle("[SDM] Pràctica 2 - Màquina escurabutxaques");
		setSize(new Dimension(WINDOW_WIDTH,WINDOW_HEIGHT));
		setLocation(SCREEN_WIDTH / 2 - WINDOW_WIDTH / 2, SCREEN_HEIGHT / 2 - WINDOW_HEIGHT / 2);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setLayout(new BorderLayout());
	}
	
	//Configura el panell superior i els seus components
	private void configureTopPanel(){
		
		//Configurem els JPanels
		topPanel = new JPanel();
		infoPanel = new JPanel();
		portPanel = new JPanel();
		topPanel.setLayout(new BorderLayout());
		topPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
		infoPanel.setLayout(new BoxLayout(infoPanel,BoxLayout.Y_AXIS));
		portPanel.setLayout(new FlowLayout());
		
		//Configurem les labels
		lblJugades = new JLabel("Numero Jugades: X");
		lblPremis = new JLabel("Total Premis : Y");
		lblBaudRate = new JLabel("BaudRate: ");
		lblPort = new JLabel("Port: ");
		
		//Afegim les labels al infoPanel
		infoPanel.add(lblJugades);
		infoPanel.add(lblPremis);
		
		
		//Afegim els components al port Panel
		portPanel.add(lblBaudRate);
		portPanel.add(comboBaud);
		portPanel.add(lblPort);
		portPanel.add(comboPort);
		
		//Afegim l'infoPanel al topPanel (alineat a l'esquerra)
		topPanel.add(infoPanel,BorderLayout.WEST);
		topPanel.add(portPanel,BorderLayout.EAST);

		
		//Afegim el topPanel a la finestra
		add(topPanel,BorderLayout.NORTH);
		
	}
	
	//Configura el panell central i els seus components
	private void configureCenterPanel(){
		
		//Creem els panells
		centerPanel = new JPanel();
		filePanel = new JPanel();
		centerPanel.setLayout(new BoxLayout(centerPanel,BoxLayout.Y_AXIS));
		filePanel.setLayout(new FlowLayout());
		filePanel.setMaximumSize(new Dimension(1000,50));
		
		//Creem els TextFields
		txtPath = new JTextField();
		txtPath.setPreferredSize(new Dimension(500,30));
		
		//Creem les labels
		lblPath = new JLabel("Path: ");
		
		//Creem els botons
		btnPath = new JButton("...");
		btnUART = new JButton("Carrega Fitxer");
		btnInfraRojos = new JButton("EnviaIR");
		btnUART.setAlignmentX(Component.CENTER_ALIGNMENT);
		btnInfraRojos.setAlignmentX(Component.CENTER_ALIGNMENT);
		btnUART.setMaximumSize(new Dimension(200,50));
		btnInfraRojos.setMaximumSize(new Dimension(200,50));
		btnInfraRojos.setMinimumSize(new Dimension(200,50));
		btnUART.setMinimumSize(new Dimension(200,50));
		btnInfraRojos.setPreferredSize(new Dimension(200,50));
		btnUART.setPreferredSize(new Dimension(200,50));
		
		//Agefim els controls al panell del fitxer
		filePanel.add(lblPath);
		filePanel.add(txtPath);
		filePanel.add(btnPath);
		
		//Afegim els controls al panell central
		centerPanel.add(Box.createVerticalGlue());
		centerPanel.add(filePanel);
		centerPanel.add(Box.createRigidArea(new Dimension(100,50)));
		centerPanel.add(btnUART);
		centerPanel.add(Box.createRigidArea(new Dimension(100,50)));
		centerPanel.add(btnInfraRojos);
		centerPanel.add(Box.createVerticalGlue());
		
		//Afegim el panell central a la finestra
		add(centerPanel,BorderLayout.CENTER);
	}
	
	//Configura el panell inferior i els seus components
	//Configura el panell inferior i els seus components
	private void configureBottomPanel(){
		
		//Configurem el panell del footer
		bottomPanel = new JPanel();
		bottomPanel.setLayout(new BorderLayout());
		
		//Configurem la progressbar
		progressBar = new JProgressBar();
		progressBar.setValue(0);
		progressBar.setStringPainted(true);
		
		bottomPanel.add(progressBar,BorderLayout.CENTER);
		
		add(bottomPanel,BorderLayout.SOUTH);
		
	}

	public void associateController(MainWindowController controller){
		
		//Assignem el nom per distingir els botons
		btnUART.setName(BTN_UART);
		btnInfraRojos.setName(BTN_INFRAROJOS);
		
		//Assignem el controlador dels botons
		btnInfraRojos.addActionListener(controller);
		btnUART.addActionListener(controller);
		
	}

	public void setPortsList(String [] lPorts){
		comboPort.removeAllItems();
		for(String item : lPorts){
			comboPort.addItem(item);
		}
	}
	
	public void setBaudRateList(int [] lBaudRates){
		comboBaud.removeAllItems();
		for(int item : lBaudRates){
			comboBaud.addItem(item);
		}
	}
	
	public String getFile(){
		return txtPath.getText();
	}
	
}
