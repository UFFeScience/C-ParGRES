<%@page language="java" import="java.io.*,java.sql.*,java.util.*, org.pargres.console.*, org.pargres.webadmin.*" %>
 <% 
 
 	 System.out.println(":: WebAdmin DUMP");
 	 System.out.println("logoff = "+request.getParameter("logoff"));
 	 System.out.println("host = "+request.getParameter("host"));
 	 System.out.println("port = "+request.getParameter("port"));
 	 System.out.println("login = "+request.getParameter("login"));
 	 System.out.println("password = "+request.getParameter("password"));
 	 System.out.println("disable = "+request.getParameter("disable"));
 	 System.out.println("newnode = "+request.getParameter("newnode"));
 	 System.out.println("disableVp = "+request.getParameter("disableVp"));
 	 System.out.println("newvp = "+request.getParameter("newvp"));	  	  	  	  	 
 	 System.out.println("::"); 	 
 	 
	if(request.getParameter("logoff") != null) {
		session.putValue("webadmin",null);
	    System.out.println("WebAdmin logoff");		
	} 
	
    WebAdmin webAdmin = (WebAdmin)session.getValue("webadmin");
 	if(webAdmin == null) {
 		webAdmin = new WebAdmin(); 		
 		session.putValue("webadmin",webAdmin);
	    System.out.println("WebAdmin created as session variable.");
 	}
 	
    if(!webAdmin.isLogged() && 
          request.getParameter("login")!=null && request.getParameter("password")!=null) {
		    webAdmin.login("localhost","8050",request.getParameter("login").trim(),request.getParameter("password").trim());
	    System.out.println("WebAdmin login done!");
	}		 	
	
   String infoNode = "";
   if(request.getParameter("disable") != null) {
   		int disableNode = Integer.parseInt(request.getParameter("disable"));
   		infoNode = webAdmin.dropNode(disableNode);
   		response.sendRedirect("index.jsp");
	    System.out.println("WebAdmin: drop vp!");   		
   } else if (request.getParameter("newnode") != null) {
	    infoNode = webAdmin.addNode(request.getParameter("newnode"));	    
	    System.out.println("WebAdmin: add node!");	    
   }	
   
   String infoVp = "";
   if(request.getParameter("disableVp") != null) {
   		infoVp = webAdmin.dropVp(request.getParameter("disableVp"));
   		response.sendRedirect("index.jsp");   		
	    System.out.println("WebAdmin: drop vp!");   		
   } else if (request.getParameter("newvp") != null) {
	    infoVp = webAdmin.addVp(request.getParameter("newvp"));
	    System.out.println("WebAdmin: add vp!");
   }   
 %>
 
<html><head><title>Pargres Web Admin</title>

    <style>
        .login { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 8pt; color: #666666; }
        .header { font-family:Verdana, Arial, Helvetica, sans-serif; font-size: 10pt; color: #666666; font-weight: bold; }
        .tableHeader { background-color: #c0c0c0; color: #666666;}
        .tableHeaderLight { background-color: #cccccc; color: #666666;}
        .main { font-family:Verdana, Arial, Helvetica, sans-serif; font-size: 8pt; color: #666666;}
        .copy { font-family:Verdana, Arial, Helvetica, sans-serif; font-size: 8pt; color: #999999;}
        .copy:Hover { color: #666666; text-decoration : underline; }
        td { font-family:Verdana, Arial, Helvetica, sans-serif; font-size: 8pt; color: #666666;}
        A { text-decoration: none; }
        A:Hover { color : Red; text-decoration : underline; }
        BODY { OVERFLOW: auto; font-family:Verdana, Arial, Helvetica, sans-serif; font-size: 8pt; color: #666666; }
    </style>

</head>
<body bgcolor="#FFFFFF">


<table border="0"><tr><td valign="top" align="center" width="250">
<!-- RESULT -->

<img height="99" width="172" src="pargres.png"/>
<br>
<br>
<% if(webAdmin.isLogged()) { %> 

<table>

<tr><td>

	<center>
	<table width="220" cellpadding="7" border="1"><tr><td>
	
		<% out.print(webAdmin.listNodes()); %>
	
	</td></tr></table>
	</center>
  

</td></tr>
<tr><td>
	<center>
		<form method="post">
		Add new node: <input class="main" name="newnode" size="19"/><br>
		Format: < hostname:port > <input class="main" name="addNode" type="submit" value="add"> 
		</form>
		<font color='red'><b><%=infoNode%></b></font>
	<br>
	</center>
	
</td></tr>

<tr><td>

	<center>
	<table width="220" cellpadding="7" border="1"><tr><td>
	
		<% out.print(webAdmin.listVirtualPartitionedTable()); %>
	
	</td></tr></table>
	</center>
  

</td></tr>
<tr><td>
	<center>
		<form method="post">
		Add new vp: <input class="main" name="newvp" size="19"/><br>
		Format: < tablename:field > <input class="main" name="addVp" type="submit" value="add">
		</form>
		<font color='red'><b><%=infoVp%></b></font>
	</center>
		<i>c = cardinality<br>
		rb = range begin<br>
		re = range end<br></i>
			
</td></tr>

</table>

<% } %>

</td><td>
</td>
<td valign="top">

<table cellpadding="0" width="750">
<tr><td>
	<form method="post">
<b class="header">Pargres Web Admin</b>
<font class="main">:: Administration Module ::</font>
<% if(!webAdmin.isLogged()) { %>login: <input class="login" type="Text" name="login" value="" size="15"> password: <input class="login" type="Password" name="password" value="" size="15"><input class="main" type="Submit" value="Login">
<% } else {  %> <form method="post">login: <%=webAdmin.getUser()%> <input class="main" name="logoff" value="log off" type="submit">
<% } %></form>	  
</td></tr>
<!-- QUERIE -->
<tr><td>

<center>
       
       <% if(webAdmin.isLogged()) { %>  
	      <form method="post">
	      <table><tr><td align="center">
	      <b>Query</b>
	      </td></tr>
	      <tr><td>     
	      <%
	       if(request.getParameter("query")!=null) { %>
		      <textarea tabindex="0" cols="80" rows="10" name="query" wrap="soft"><%=request.getParameter("query")%></textarea>
	      <% } else if(request.getParameter("Q1")!=null) { %>
	      	 <textarea tabindex="0" cols="80" rows="10" name="query" wrap="soft"><%@ include file="q1.sql" %></textarea>
	      <% } else if(request.getParameter("Q4")!=null) { %>
	      	 <textarea tabindex="0" cols="80" rows="10" name="query" wrap="soft"><%@ include file="q4.sql" %></textarea>
	      <% } else { %>
	      	 <textarea tabindex="0" cols="80" rows="10" name="query" wrap="soft"></textarea>	      
	      <% } %> 
	      
	      </td></tr>
	      <tr><td align="right">
                 Maximum lines in result: <input class="main" name="lines" value="10"/> <input class="main" value="Execute" type="submit">
          </td></tr>
          </table>
	     </form>  	     
	     <form method="post">
	     Pre-defined queries
	     <input class="main" name="Q1" value="Q1" type="submit">
	     <input class="main" name="Q4" value="Q4" type="submit">
	     </form>	     			  
	   <% } %>
	   
</center>

</td></tr>
<!-- RESULT -->
<tr><td>
	   
	   <%
	      String query = null;
	      if(request.getParameter("query")!=null) {
	      	query = request.getParameter("query").trim();
	      	if(!query.equals("")) {
	      		if(query.toUpperCase().startsWith("SELECT")) {	      	
			        String result = webAdmin.executeQuery(query,Integer.parseInt(request.getParameter("lines")));
				    out.print(result);	      	
				    out.println("Maximum number of lines: "+request.getParameter("lines"));
				} else {
			        out.print(webAdmin.executeUpdate(query));
				}
			 } else {
				out.print("Empty query!");	      				 
			 }
	      }    
	   %>
   
</td></tr>
</table>

</td></tr></table>
<hr WIDTH="100%">
<center><p>Copyright © 2005 Equipe Pargres | <a href="http://pargres.nacad.ufrj.br">Pargres Web Site</a></p></center>
</body>
</html> 
   <% System.out.println("PAGE DONE!"); %>