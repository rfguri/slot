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
import javax.swing.SwingUtilities;

import org.p2f1.controllers.MainWindowController;

public class MainWindowView  extends JFrame{

	private static final long serialVersionUID = 8459978615692456891L;
	
	public static final String BTN_UART = "BTN_UART";
	public static final String BTN_INFRAROJOS = "BTN_INFRAROJOS";
	
	private static final int SCREEN_WIDTH = (int) Toolkit.getDefaultToolkit().getScreenSize().getWidth();
	private static final int SCREEN_HEIGHT = (int) Toolkit.getDefaultToolkit().getScreenSize().getHeight();
	
	private static final int WINDOW_WIDTH = 800;
	private static final int WINDOW_HEIGHT = 600;
	
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
	
	private JFileChooser fileChooser = new JFileChooser();
	
	public MainWindowView(){
		configureWindow();
		configureTopPanel();
		configureCenterPanel();
		configureBottomPanel();
		
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
	
	private void configureWindow(){
		setTitle("[SDM] Pràctica 2 - Màquina escurabutxaques");
		setSize(new Dimension(WINDOW_WIDTH,WINDOW_HEIGHT));
		setLocation(SCREEN_WIDTH / 2 - WINDOW_WIDTH / 2, SCREEN_HEIGHT / 2 - WINDOW_HEIGHT / 2);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setLayout(new BorderLayout());
	}
	
	private void configureTopPanel(){
		
		topPanel = new JPanel();
		infoPanel = new JPanel();
		portPanel = new JPanel();
		topPanel.setLayout(new BorderLayout());
		topPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
		infoPanel.setLayout(new BoxLayout(infoPanel,BoxLayout.Y_AXIS));
		portPanel.setLayout(new FlowLayout());
		
		lblJugades = new JLabel("Numero Jugades: X");
		lblPremis = new JLabel("Total Premis : Y");
		lblBaudRate = new JLabel("BaudRate: ");
		lblPort = new JLabel("Port: ");
		
		infoPanel.add(lblJugades);
		infoPanel.add(lblPremis);
		
		portPanel.add(lblBaudRate);
		portPanel.add(comboBaud);
		portPanel.add(lblPort);
		portPanel.add(comboPort);
		
		topPanel.add(infoPanel,BorderLayout.WEST);
		topPanel.add(portPanel,BorderLayout.EAST);

		add(topPanel,BorderLayout.NORTH);
		
	}
	
	private void configureCenterPanel(){
		
		centerPanel = new JPanel();
		filePanel = new JPanel();
		centerPanel.setLayout(new BoxLayout(centerPanel,BoxLayout.Y_AXIS));
		filePanel.setLayout(new FlowLayout());
		filePanel.setMaximumSize(new Dimension(1000,50));
		
		txtPath = new JTextField();
		txtPath.setPreferredSize(new Dimension(500,30));
		
		lblPath = new JLabel("Path: ");
		
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
		
		filePanel.add(lblPath);
		filePanel.add(txtPath);
		filePanel.add(btnPath);
		
		centerPanel.add(Box.createVerticalGlue());
		centerPanel.add(filePanel);
		centerPanel.add(Box.createRigidArea(new Dimension(100,50)));
		centerPanel.add(btnUART);
		centerPanel.add(Box.createRigidArea(new Dimension(100,50)));
		centerPanel.add(btnInfraRojos);
		centerPanel.add(Box.createVerticalGlue());
		
		add(centerPanel,BorderLayout.CENTER);
	}
	
	private void configureBottomPanel(){
		
		bottomPanel = new JPanel();
		bottomPanel.setLayout(new BorderLayout());
		
		progressBar = new JProgressBar();
		progressBar.setMinimum(0);
		progressBar.setMaximum(100);
		progressBar.setValue(0);
		progressBar.setStringPainted(true);
		
		bottomPanel.add(progressBar,BorderLayout.CENTER);
		
		add(bottomPanel,BorderLayout.SOUTH);
		
	}

	public void associateController(MainWindowController controller){
		
		btnUART.setName(BTN_UART);
		btnInfraRojos.setName(BTN_INFRAROJOS);
		
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
	
	public Integer getBaudrate(){
		return (Integer) comboBaud.getSelectedItem();
	}
	
	public String getPort(){
		return comboPort.getSelectedItem().toString();
	}
	
	public void setProgressBarValue(int i){
		
	}
	
	public void updateProgressBar(int i) {
		Thread t = new Thread(new Runnable() {
	        public void run() {
	            progressBar.setValue(i);
	        }
	    });
	    t.start();
    }
	
}
