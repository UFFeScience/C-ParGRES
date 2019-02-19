package main;

import enumeration.OperationType;
import environment.AmazonProvider;
import environment.EnvironmentType;

//http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
/**
 *
 * @author Marcello
 */
public class PGStarter {

    private static String absolutePath;
    private static AmazonProvider provider;
    private static XMLReader configurationFile = null;

    private static OperationType getOperation(String operation, String[] args) {
        if (args.length == 2) {
            switch (operation) {
                case "create_cluster":
                    return OperationType.CREATE_CLUSTER;
                case "delete_cluster":
                    return OperationType.DELETE_CLUSTER;
                case "start_pargres":
                    return OperationType.START_PARGRES;
                case "d":
                    return OperationType.DEBUG;
                case "help":
                    return OperationType.HELP;
            }
        }

        return OperationType.UNKNOWN;
    }
    
    public static void printHelp(){
        String help = "PGStarter command line: {operation} {configuration_file}" + SCUtils.nextLine + SCUtils.nextLine
                + "Operation types:" + SCUtils.nextLine
                + "-create_cluster --> to create a cluster" + SCUtils.nextLine
                + "-delete_cluster --> to delete a cluster" + SCUtils.nextLine
                + "-start_pargres  --> to start Pargres service" + SCUtils.nextLine;
        SCUtils.printFirstLevel(help);
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws Exception {
        SCUtils.printInitialMessage();
        
        args = new String[2];
        args[0] = 
                "-create_cluster";
//                "-delete_cluster";
//                "-start_pargres";
        args[1] = "Pargres.xml";

        if (args.length == 2) {
            String operation = args[0].replaceAll("-", "");
            OperationType operationType = getOperation(operation, args);

            if (operationType != OperationType.UNKNOWN) {
                absolutePath = System.getProperty("user.dir");
                configurationFile = new XMLReader(args[1]);

                if (configurationFile.environmentType == EnvironmentType.CLOUD_AMAZON) {
                    provider = new AmazonProvider(configurationFile.awsAccessKeyId, configurationFile.awsSecretAccessKey);
                }
            }

            if (operationType == OperationType.CREATE_CLUSTER && configurationFile.environmentType == EnvironmentType.CLOUD_AMAZON) {
                SCUtils.printOperation("Create Cluster");
                AmazonProvider amazon = (AmazonProvider) provider;
                amazon.createCluster(configurationFile, absolutePath);
                
            } else if (operationType == OperationType.DELETE_CLUSTER && configurationFile.environmentType == EnvironmentType.CLOUD_AMAZON) {
                SCUtils.printOperation("Delete Cluster");
                AmazonProvider amazon = (AmazonProvider) provider;
                amazon.deleteCluster(configurationFile);

            } else if (operationType == OperationType.START_PARGRES && configurationFile.environmentType == EnvironmentType.CLOUD_AMAZON) {
                SCUtils.printOperation("Start Pargres");
                AmazonProvider amazon = (AmazonProvider) provider;
                amazon.startPargresService();

            }else if (operationType == OperationType.HELP) {
                printHelp();
                
            } else {
                System.out.println("You did not specify operation or configuration file correctly!");
            }

            if (provider != null && configurationFile.environmentType == EnvironmentType.CLOUD_AMAZON) {
                AmazonProvider amazon = (AmazonProvider) provider;
                amazon.shutDownProvider();
            }
        } else {
            System.out.println("You did not specify arguments correctly! (operation + configuration file)");
        }
    }
}
