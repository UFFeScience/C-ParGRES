/*
 * Created on 10/03/2005
 */
package org.pargres.util;

import java.net.Socket;

import org.pargres.commons.logger.Logger;
import org.pargres.nodequeryprocessor.NodeQueryProcessorEngine;


/**
 * @author Bernardo
 */
public class PargresNodeProcessor {
    private Logger logger = Logger.getLogger(PargresNodeProcessor.class);
    
    private int port = -1;

    private String jdbcDriver = null;

    private String jdbcUrl = null;

    private String jdbcUser = null;

    private String jdbcPwd = null;
    
    private NodeQueryProcessorEngine nqp;

    public PargresNodeProcessor(int port, String jdbcDriver, String jdbcUrl, String jdbcUser, String jdbcPwd) {
        this.port = port;
        this.jdbcDriver = jdbcDriver;
		this.jdbcUrl = jdbcUrl;
        this.jdbcUser = jdbcUser;
        this.jdbcPwd = jdbcPwd;
    }
    
    public PargresNodeProcessor(int port, int jdbcPort) {
        this.port = port;
        this.jdbcDriver = "org.hsqldb.jdbcDriver";
		this.jdbcUrl = "jdbc:hsqldb:mem:testdb"+jdbcPort+";ifexists=true";
        this.jdbcUser = "sa";
        this.jdbcPwd = "";
    }

    public void start() {               
        Socket socket = null;
        try {
            nqp = new NodeQueryProcessorEngine(
                    port, jdbcDriver, jdbcUrl, jdbcUser, jdbcPwd, false);
            socket = new Socket("127.0.0.1", port);
            //System.out.println("SmaqNodeProcessor running...");
            socket.close();
        } catch (Exception e) {
            System.err
                    .println("O SmaqNodeProcessor nao foi inicializado: " + e);
            e.printStackTrace();
        }
    }

    public void stop() {
        //NodeQueryProcessorAdmin.main(("SHUTDOWN localhost "+port).split("
        // "));
        try {
            nqp.shutdown();
            nqp = null;
        } catch (Exception e) {
            logger.error(e);
            e.printStackTrace();
        }

    }

}
