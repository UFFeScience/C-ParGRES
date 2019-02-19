/*
 * Created on 10/03/2005
 */
package org.pargres.util;

import java.net.Socket;

import org.pargres.cqp.connection.ConnectionManagerImpl;

/**
 * @author Bernardo
 */
public class PargresClusterProcessor {
    private int port = - 1;
    private String configFile = null;
    //private Process server;
    private boolean started;
    private ConnectionManagerImpl cm;
    
    public PargresClusterProcessor(int port, String configFile) {
        this.port = port;
        this.configFile = configFile;
    }
    
		    public void start() {
			/*	Thread node3 = new Thread(new Runnable() {
					public void run() {*/
					    try {
					    	cm = new ConnectionManagerImpl(port,configFile);//ClusterQueryProcessorEngine(port,configFile);
					    	cm.toString();
							started = true;
					    } catch (Exception e) {
					        System.err.println("Erro: "+e);
					        e.printStackTrace();
					    }
/*					}
				});
				node3.start();*/	
				Socket socket = null;
				try {
					while(!started) {
					    Thread.sleep(100);
					}
					socket = new Socket("127.0.0.1", port);
					//System.out.println("SmaqClusterProcessor running...");
					socket.close();
				} catch (Exception e) {
					System.err.println("O SmaqClusterProcessor nao foi inicializado: " + e);
				}		
		    }
    
    public void stop() {
        try {
          //  cqp.shutdown();
          //  cqp = null;
        	cm.destroy();
        	cm = null;
	    } catch (Exception e) {
	        System.err.println("Erro: "+e);
	        e.printStackTrace();	        
	    }
		/*if (server != null) {
			server.destroy();
			server = null;
		}*/                       
    }
}
