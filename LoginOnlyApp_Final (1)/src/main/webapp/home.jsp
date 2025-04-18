<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<html>
<head><title>Login Result</title></head>
<body>
<%
	// asking for username and password from the end user
    String username = request.getParameter("username");
    String password = request.getParameter("password");
	//starting up our connection using applicationDB file (java file)
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
	//exception if/when the database doesnt connect properly
    if (con == null) {
        out.println("Database connection failed. Please try again later.");
    } else {
        //using SQL checks the local workbench to make sure username and password exists
        PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE username=? AND password=?");
        ps.setString(1, username);
        ps.setString(2, password);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            //When the login is correct:
            out.println("<h1>Successfully Logged In User: " + rs.getString("username") +"!<h1>");
            out.println("<h2>Welcome, " + rs.getString("first_name") + " " + rs.getString("last_name") + "!</h2>");
            session.setAttribute("username", username);
            session.setAttribute("userId", rs.getInt("id"));
          //commenting this line out for now -haseem this is just the homepage
        //  out.println("<p><a href='home.jsp'>Go to Home Page</a></p>");
        } else {
            // Giving an error message for when the login doesnt work:
            out.println("<h2>Login for username '" + username + "' failed. Make sure your username and password is correct! </h2>");
            out.println("<p><a href='login.jsp'>Try Again</a></p>");
        }
    }
    
    //when user is logged in we have a log out button 
    if (session.getAttribute("username") != null) {
%>
        <form action="logout.jsp" method="post">
            <input type="submit" value="Log Out" />
        </form>
<%
    }
    con.close();
%>
</body>
</html>