<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<html>
<head><title>Login Result</title></head>
<body>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    if (con == null) {
        out.println("Database connection failed. Please try again later.");
    } else {
        // Query the database to check if the username and password match
        PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE username=? AND password=?");
        ps.setString(1, username);
        ps.setString(2, password);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            // Successful login
            out.println("<h1>Successfully Logged In User: " + rs.getString("username") +"!<h1>");
            out.println("<h2>Welcome, " + rs.getString("first_name") + " " + rs.getString("last_name") + "!</h2>");
            // Set session attributes for the logged-in user
            session.setAttribute("username", username);
            session.setAttribute("userId", rs.getInt("id"));
          //commenting this line out for now -haseem
        //  out.println("<p><a href='home.jsp'>Go to Home Page</a></p>");
        } else {
            // Login failed, personalized error message
            out.println("<h2>Login for username '" + username + "' failed. Please check your username and password.</h2>");
            out.println("<p><a href='login.jsp'>Try Again</a></p>");
        }
    }
    
    // If the user is logged in, show the log out button
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