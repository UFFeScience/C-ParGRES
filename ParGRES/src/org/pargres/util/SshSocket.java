package org.pargres.util;

import java.io.IOException;
import java.net.Socket;

public class SshSocket extends Socket {
	private Process p1;
	@Override
	public synchronized void close() throws IOException {
		p1.destroy();
	}

	public SshSocket(String host, int port) throws IOException {
		super(host,port);
		p1 = Runtime
		.getRuntime()
		.exec(
				"install\\portforward\\plink.exe -ssh mercury -l bmiranda -pw !bmiranda -L "+port+":node9:"+port);		
	}
}
