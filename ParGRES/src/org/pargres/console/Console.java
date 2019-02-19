package org.pargres.console;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.Properties;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.pargres.commons.interfaces.ConnectionManager;
import org.pargres.cqp.connection.ServerConnectionImpl;


public class Console {
	
    Connection con;
	
	public Console(String host, int port) throws Exception {		
	    Class.forName("org.pargres.jdbc.Driver");
	    con = DriverManager.getConnection("jdbc:pargres://"+host+":"+port,"user","");		
	}


	public void execute(String sql, int lines) throws Exception {
		sql = sql.trim();

		long start = System.currentTimeMillis();

		if(sql.toUpperCase().startsWith("UPDATE") || sql.toUpperCase().startsWith("INSERT") || sql.toUpperCase().startsWith("DELETE") || sql.toUpperCase().startsWith("CREATE") || sql.startsWith("DROP")) {
			int i = con.createStatement().executeUpdate(sql);
			System.out.println("#### RESULTS ####");
			System.out.println("Rows modified: "+i);
		} else if(sql.toUpperCase().startsWith("SELECT")) {
			ResultSet rs = con.createStatement().executeQuery(sql);			
			ResultSetPrinter.print(rs,lines);
		} else 
			throw new Exception("SQL não pode ser executado: "+sql);
		long total = System.currentTimeMillis() - start;
		System.out.println("Total elapsed time: "+total+" miliseconds.");
	}
	
    public static Properties arrayToProperties(String[] arg) {

		Properties props = new Properties();		

        for (int i = 0; i < arg.length; i++) {
            String p = arg[i].trim();

            if ((!p.equals("")) && (p.charAt(0) == '-')) {
                props.setProperty(p, arg[i + 1]);

                i++;
            }
        }

        return props;
    }
    
    public static void printHelp(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp(100,"./console.sh",":: Pargres Database Cluster",options,"",true);    	
    }
    
    public static boolean commander(String[] args) throws Exception {
		CommandLineParser parser = new GnuParser();
		Options options = createOptions();
        CommandLine line = parser.parse( options, args);
        
        if(line.hasOption("v")) {
        	System.out.println("Pargres 0.1 Beta");
        	return true;
        }
        
        if(line.getOptions().length == 0) {
        	System.out.println("No parameter found!");
        	printHelp(options);
			return false;
		} else if(line.hasOption("help")) {		
            printHelp(options);
            return true;
		}
        String host;
        if(line.hasOption("h"))
        	host = line.getOptionValue("h");
        else
        	host = "localhost";
        
        int port;
        if(line.hasOption("p"))
        	port = Integer.parseInt(line.getOptionValue("p"));
        else
        	port = ConnectionManager.DEFAULT_PORT;	       
        
		/*int n; 
		if(line.hasOption("n"))
			n = Integer.parseInt(line.getOptionValue("n"));
		else
			n = 1; */
		
        int lines;			
        if(line.hasOption("r"))
                lines = Integer.parseInt(line.getOptionValue("r"));
        else
                lines = 10;

        Console console = new Console(host,port);
		
        String sql;
        if(line.hasOption("e")) {
        	sql = line.getOptionValue("e");
        	System.out.println("Executing sql: "+sql);
        	console.execute(sql,lines);
        } else if(line.hasOption("execfile")) {
        	sql = getSql(line.getOptionValue("execfile"));
        	console.execute(sql,lines);
        } else if(line.hasOption("addnode")) {
        	String entry = line.getOptionValue("addnode");
        	String nodeHost = entry.split(":")[0];
        	int nodePort = Integer.parseInt(entry.split(":")[1]);
        	console.addNode(nodeHost,nodePort);
        } else if(line.hasOption("dropnode")) {
        	int nodeNumber = Integer.parseInt(line.getOptionValue("dropnode"));
        	console.dropNode(nodeNumber);
        } else if(line.hasOption("listnodes")) {
        	console.listNodes();
        } else if(line.hasOption("addvp")) {
        	String entry = line.getOptionValue("addvp");
        	String[] values = entry.split(":");
        	console.addVirtualPartition(values[0],values[1]);
        } else if(line.hasOption("dropvp")) {
        	String tableName = line.getOptionValue("dropvp");
        	console.dropVirtualPartition(tableName);
        } else if(line.hasOption("listvp")) {
        	console.listVirtualPartition();        	
        } else {
        	System.out.println("Invalid parameter!");
        	printHelp(options);
            return false;
        }
        return true;        	
    }
	
	public static void main(String[] args) {
		try {
			commander(args);
		} catch( ParseException exp ) {			
	        System.err.println( "Unexpected exception:" + exp.getMessage() );
	 	} catch ( Exception e ) {      		
	 		System.err.println( e.getMessage() );
	 		e.printStackTrace();
	 	}
	}
	
	public void dropNode(int nodeNumber) throws Exception {		
		try {
			con.createStatement().executeUpdate(ServerConnectionImpl.DROP_NODE+" "+nodeNumber);
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			throw e;
		}
	}

	public void addNode(String nodeHost, int nodePort) throws Exception  {
		try {
			con.createStatement().executeUpdate(ServerConnectionImpl.ADD_NODE+" "+nodeHost+" "+nodePort);
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			throw e;			
		}		
	}

	public void listNodes() throws Exception  {
		try {
			ResultSet rs = con.createStatement().executeQuery(ServerConnectionImpl.GET_NODE_LIST);
			System.out.println(":: Node Query Processors listing");
			while(rs.next()) {
				String[] nodeInfo = rs.getString(1).split(":");
				System.out.println(nodeInfo[0]+" - "+nodeInfo[1]+":"+nodeInfo[2]);
			}
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			throw e;			
		}	
	}
	
	/*public void forceNewPartitionLimits(String table, String field, long first, long last) throws Exception {
		try {
			if(!connectionManager.forceNewPartitionLimits(table,field,first,last))
				throw new Exception("Partition limits not changed!");
			
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			throw e;			
		}			
	}*/
	
	public void dropVirtualPartition(String table) throws Exception  {		
		try {
			con.createStatement().executeUpdate(ServerConnectionImpl.DROP_VP+" "+table);
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			throw e;			
		}
	}

	public void addVirtualPartition(String table, String field) throws Exception  {
		try {
			con.createStatement().executeUpdate(ServerConnectionImpl.ADD_VP+" "+table+" "+field);
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			throw e;			
		}		
	}

	public void listVirtualPartition() throws Exception  {
		try {
			System.out.println(":: Virtual Partitioned Tables listing");
			ResultSet rs = con.createStatement().executeQuery(ServerConnectionImpl.GET_VP_LIST);
			while(rs.next()) {
				System.out.println(rs.getString(1));
			}
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			throw e;			
		}	
	}	

	@SuppressWarnings("static-access")
	private static Options createOptions() {
		//("[usage] java org.pargres.jdbc.Console -h host -p port -n numberOfThreads -r numberOfResultLines [-q sql] || [-f fileName]");
		Options options = new Options();
		options.addOption(OptionBuilder.withArgName("host").hasArg().withDescription("cluster query processor host name").create("h"));
		options.addOption(OptionBuilder.withArgName("port").hasArg().withDescription("cluster query processor port number").create("p"));
		options.addOption(OptionBuilder.withArgName("execute").hasArg().withDescription("execute SQL query").create("e"));
		options.addOption(OptionBuilder.withArgName("executeWithFileName").hasArg().withDescription("execute query using this file").create("execfile"));
		options.addOption(OptionBuilder.withArgName("resultLines").hasArg().withDescription("number of result lines").create("r"));
		//options.addOption(OptionBuilder.withArgName("numberOfThreads").hasArg().withDescription("executes same query concurrently in n threads").create("r"));
		// NQPs
		options.addOption(OptionBuilder.withArgName("host:port").hasArg().withDescription("add node query processor identified by host:port").create("addnode"));
		options.addOption(OptionBuilder.withArgName("nodeId").hasArg().withDescription("disconnect node query processor identified by number").create("dropnode"));
		options.addOption(OptionBuilder.withDescription("lists node query processors").create("listnodes"));
		// VPs
		options.addOption(OptionBuilder.withArgName("table:field").hasArg().withDescription("create a virtual partition on a table").create("addvp"));
		options.addOption(OptionBuilder.withArgName("tablename").hasArg().withDescription("drop a virtual partition on a table").create("dropvp"));
		options.addOption(OptionBuilder.withDescription("lists virtual partitioned tables").create("listvp"));		
		options.addOption(new Option("v", "software version"));
		options.addOption(OptionBuilder.withDescription("print this message").create("help"));		
		return options;
	}
	
    private static String getSql(String fileName) {
    	String sql = null;
    	try {
	    	InputStream in = new FileInputStream(fileName);
	    	if(in == null) {
	    		System.err.println(fileName +" not found!");
	    		return null;
	    	}
	    	BufferedReader br = new BufferedReader(new InputStreamReader(in));
	    	String line;
	    	sql = "";
	    	while((line = br.readLine()) != null) {
	    		sql += line +"\n";
	    	}
    	} catch (IOException e) {
    		e.printStackTrace(System.err);
			System.err.println(e.getMessage());
    	}
    	return sql;
    }


	@Override
	protected void finalize() throws Throwable {
		super.finalize();
		con.close();
	}	  	
}
