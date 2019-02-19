package org.pargres.webadmin;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;

import org.pargres.console.ResultSetPrinter;
import org.pargres.cqp.connection.ServerConnectionImpl;

public class WebAdmin {
	private Connection con = null;
	private String user = null;
	
	public static void main(String[] args) {
		WebAdmin webAdmin = new WebAdmin();
		try {
			webAdmin.login("localhost","8050","user","");
		} catch (Exception e) {
			e.printStackTrace();
		}
		String result = webAdmin.executeQuery("SELECT * FROM REGION",10);
		System.out.println(result);
	}
	
	public boolean isLogged() {
		try {
			return con != null;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	/*public String getUser() {
		return user;
	}*/
	
	public String listVirtualPartitionedTable() {
		try {
			String saida = ""; 

			ResultSet rs = con.createStatement().executeQuery(ServerConnectionImpl.GET_VP_LIST);
			//for(String list : connectionManager.listVirtualPartitionedTable().split("\n")) {
			while(rs.next()) {
				String list = rs.getString(1);
				String number = list.substring(0,list.indexOf("-")).trim();
				String tableName = list.substring(list.indexOf("-")+1,list.indexOf("[")).split(":")[0].trim();
				String field = list.substring(list.indexOf("-")+1,list.indexOf("[")).split(":")[1].trim();
				String cardinality = list.substring(list.indexOf("=")+1,list.indexOf(","));				
				String rangeInit = list.split(",")[1].split("=")[1].trim();
				String rangeEnd = list.split(",")[2].split("=")[1].replaceAll("]","").trim();
				saida += number+" - "+tableName+":"+field+"<BR>\n" +
						 "[c:"+cardinality+", rb:"+rangeInit+", re:"+rangeEnd+"]<BR>\n" +
						 "<a href=\"index.jsp?disableVp="+tableName+"\">disable</a><br>\n";
			}
			
			return "<b>Loaded VPs: </b><br>\n"+saida+"<BR>"; 
				
		} catch (Exception e) {
			//e.printStackTrace();
			return e.getMessage();
		}
	}	
	
	public String addVp(String newvp) {
		try {
			con.createStatement().executeUpdate(ServerConnectionImpl.ADD_VP+" "+newvp.split(":")[0]+" "+newvp.split(":")[1]);
			System.out.println("WebAdmin: adding vp "+newvp);
			return "VP added!";
		} catch (Exception e) {
			e.printStackTrace();
			return "Failed to add vp!";
		}
	}
	
	public String dropVp(String table) {
		try {
			con.createStatement().executeUpdate(ServerConnectionImpl.DROP_VP+" "+table);
			
			System.out.println("WebAdmin: drop vp "+table);
			return "VP removed!";
		} catch (Exception e) {
			e.printStackTrace();
			return "Failed to remove vp!";
		}		
	}
	
	public String listNodes() {
		try {
			String saida = ""; 

			ResultSet rs = con.createStatement().executeQuery(ServerConnectionImpl.GET_NODE_LIST);
			//String list : connectionManager.getNodesList().split(";")
			while(rs.next()) {
				String[] nodeInfo = rs.getString(1).split(":");
				saida += nodeInfo[0]+" - "+nodeInfo[1]+":"+nodeInfo[2]+" <a href=\"index.jsp?disable="+nodeInfo[0]+"\">disable</a><br>";
			}
			
			return "<b>Loaded nodes: </b><br>"+saida+"<BR>"; 
				
		} catch (Exception e) {
			//e.printStackTrace();
			return e.getMessage();
		}
	}
	
	public String dropNode(int nodeId) {
		try {
			con.createStatement().executeUpdate(ServerConnectionImpl.DROP_NODE+" "+nodeId);
			System.out.println("WebAdmin: droping node "+nodeId+"!");
			return "Node removed!";
		} catch (Exception e) {
			e.printStackTrace();
			return "Failed to remove node!";
		}
	}
	
	public String addNode(String newNode) {
		try {		
			String[] params = newNode.split(":");
			String host;
			int port;
			if(params.length == 1)
				port = 3001;
			else
				port = Integer.parseInt(params[1]);
			
			host = params[0];			
			//connectionManager.addNode(host,port);
			con.createStatement().executeUpdate(ServerConnectionImpl.ADD_NODE+" "+host+" "+port);
			System.out.println("WebAdmin: adding node "+host+":"+port+"!");
			return "Node added!";
		} catch (Exception e) {
			e.printStackTrace();
			return "Failed to add node!";
		}
	}
	
	public void login(String host, String port, String user, String password) {
		try {	
			host = host.trim();
			int portInt = Integer.parseInt(port.trim());
			this.user = user.trim();
			password = password.trim();
			Class.forName("org.pargres.jdbc.Driver");
			System.out.println("Connecting with user: "+user);
			con = DriverManager.getConnection("jdbc:pargres://"+host+":"+portInt,user,password);
		} catch (Exception e) {
			e.printStackTrace();
			//throw e;
		}
	}
	
	public String executeQuery(String sql, int lines) {
		try {
			long init = System.currentTimeMillis();
			ResultSet rs = con.createStatement().executeQuery(sql);
			long end = System.currentTimeMillis() - init;
		    String saida = "<center><font class=\"header\">Query Result</font><center>\n"+
			"<DIV STYLE=\"width=740px; height: 180; overflow: auto; \n" +
		    "padding:0px; margin: 0px\">\n";	
			saida += ResultSetPrinter.getPrintHtml(rs,lines);
			saida += "</div>\n";
			saida += "<br>Elapsed time: "+end+" ms.<br>";
			return saida;
		} catch (Exception e) {
			//e.printStackTrace();
			return e.getMessage()+"<BR>";
		}
	}
	
	public String executeUpdate(String sql) {
		try {
			long init = System.currentTimeMillis();
			int count = con.createStatement().executeUpdate(sql);
			long end = System.currentTimeMillis() - init;
		
			String saida = "<center><font class=\"header\">Query Result</font><center>\n";
			
			saida += "<br>Elapsed time: "+end+" ms.<br>";
			saida += "Rows modified: "+count+"<BR>";
			return saida;
		} catch (Exception e) {
			//e.printStackTrace();
			return e.getMessage()+"<BR>";
		}
	}

	public String getUser() {
		return user;
	}	
}
