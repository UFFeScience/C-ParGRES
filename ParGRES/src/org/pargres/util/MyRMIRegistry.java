/*
 * Created on 20/04/2005
 */
package org.pargres.util;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.rmi.AccessException;
import java.rmi.NotBoundException;
import java.rmi.Remote;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.RMISocketFactory;
import java.rmi.server.UnicastRemoteObject;
import java.util.ArrayList;

/**
 * @author Bernardo
 */
public class MyRMIRegistry {
	private static ArrayList<Integer> ports = new ArrayList<Integer>();
	private static MyRMISocketFactory rmiSocketFactory = new MyRMISocketFactory();
	private static String defaultHost;
	private static int defaultPort;	
	
	public static void close() {
		rmiSocketFactory.close();
		rmiSocketFactory = null;
		ports = null;
	}
	
	static {
		try {
		//	RMISocketFactory.setSocketFactory(rmiSocketFactory);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public synchronized static Remote lookup(String host, int port, String remoteAddress) throws AccessException, RemoteException, NotBoundException {		
		remoteAddress = remoteAddress.split("/")[3]; 
        Registry registry = LocateRegistry.getRegistry(host,port);
        Remote remote;
        defaultHost = host;
        defaultPort = port;
        remote = registry.lookup(remoteAddress);
        defaultHost = null;
        defaultPort = -1;
        return remote;
	}
	
	public synchronized static void bind(int port, String remoteAddress, Remote remote) {
		try {			
			remoteAddress = remoteAddress.split("/")[3];
            Registry registry;			
			if(ports.indexOf(new Integer(port)) == -1) {
				registry = LocateRegistry.createRegistry(port);
				System.out.println("New RMI registry on port "+port);
			} else
				registry = LocateRegistry.getRegistry(port);
			ports.add(new Integer(port));
            Remote stub = UnicastRemoteObject.exportObject(remote,port);
            remote = null;
            registry.rebind(remoteAddress, stub);
			stub = null;			
		} catch (Exception e) {
			//logger.error(e);
			System.err.println(e.getMessage());
			e.printStackTrace();			
		}
	}

	public synchronized static void unbind(int port, String remoteAddress,Remote remote) {
		try {
			remoteAddress = remoteAddress.split("/")[3];
			UnicastRemoteObject.unexportObject(remote,true);
			Registry registry = LocateRegistry.getRegistry(port);
			registry.unbind(remoteAddress);
			
		} catch (Exception e) {
			System.err.println(e.getMessage());
			e.printStackTrace();			
		}
	}	
	
	static public class MyRMISocketFactory extends RMISocketFactory {
		private ArrayList<ServerSocket> serverSockets = new ArrayList<ServerSocket>();
		private ArrayList<Socket> sockets = new ArrayList<Socket>();
		private boolean closed = false;

		public void close() {
			closed = true;
			try {
				for(ServerSocket serverSocket : serverSockets) {
					serverSocket.close();
					System.out.println("Server Socket port "+serverSocket.getLocalPort()+" closed");					
				}	
				
				for(Socket socket : sockets) {				
					socket.close();		
					System.out.println("Socket port "+socket.getLocalPort()+" closed");
				}					
				
			} catch (Exception e) {
				System.err.println(e.getMessage());
				e.printStackTrace();
			}
		}		

		@Override
		public ServerSocket createServerSocket(int port) throws IOException {
			if(closed)
				return null;
			ServerSocket serverSocket = new ServerSocket(port);
			serverSockets.add(serverSocket);
			System.out.println("RMI Server socket created on port "+serverSocket.getLocalPort()+"!");
	        return serverSocket;
		}

		@Override
		public Socket createSocket(String host, int port) throws IOException {
			System.out.println("Trying to create RMI Socket on "+host+":"+port+"!");
			if(closed)
				return null;
			Socket socket;
			if(host.equals("localhost") || host.equals("127.0.0.1") || (defaultPort == -1 && defaultHost == null))
				socket =  new Socket(host, port);
			else
				socket =  new Socket(defaultHost, defaultPort);
			sockets.add(socket);
			System.out.println("RMI Socket created on host "+socket.getLocalAddress()+", port "+socket.getLocalPort()+", remote Host"+socket.getRemoteSocketAddress()+", port "+socket.getPort()+"!");
			return socket;
		}

	}	
}

