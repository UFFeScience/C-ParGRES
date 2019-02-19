/*
 * QueryProcessorAdmin.java
 *
 * Created on 4 decembre 2003, 16:27
 */

package org.pargres.cqp;

import java.rmi.Naming;

import org.pargres.util.MyRMIRegistry;



/**
 * 
 * @author lima
 */
public class ClusterQueryProcessorAdmin {

    /** Creates a new instance of DBGatewayAdmin */
    public ClusterQueryProcessorAdmin() {
    }

    /**
     * @param args
     *            the command line arguments args[0] - operation args[1] -
     *            server name args[2] - port number
     */
    public static void main(String[] args) {

        if (args.length < 3) {
            System.out
                    .println("usage: java ClusterQueryProcessorAdmin ServerName PortNumber op ");
            System.out.println("op = SHUTDOWN | SET_CLUSTER_SIZE size");
            return;
        }

        try {
            if (args[2].toUpperCase().equals("SHUTDOWN")) {
                shutdown(args[0].trim(), (new Integer(args[1].trim()))
                        .intValue());
            } else if (args[2].toUpperCase().equals("SET_CLUSTER_SIZE")) {
                if (args.length < 4)
                    System.out.println("New size not specified");
                setClusterSize(args[0].trim(), args[1].trim(), Integer
                        .parseInt(args[3].trim()));
            } else {
                System.out.println("Invalid operation: " + args[0]);
            }
        } catch (Exception e) {
            System.err.println("Exception: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void shutdown(String serverName, int portNumber)
            throws Exception {
        ClusterQueryProcessor qp;

        System.out.println("Shuting down...");
        qp = (ClusterQueryProcessor) MyRMIRegistry.lookup(serverName,portNumber,"//" + serverName + ":"
                + portNumber + "/ClusterQueryProcessor");
        qp.shutdown();
        System.out.println("Done!");
    }

    public static void setClusterSize(String serverName, String portNumber,
            int size) throws Exception {
        ClusterQueryProcessor cqp;

        System.out.println("Setting cluster size to " + size);
        cqp = (ClusterQueryProcessor) Naming.lookup("//" + serverName + ":"
                + portNumber + "/ClusterQueryProcessor");
        cqp.setClusterSize(size);
        System.out.println("Cluster now acts as if it had "
                + cqp.getClusterSize() + " nodes.");
    }
}
