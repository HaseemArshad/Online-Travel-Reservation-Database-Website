<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<html>
<head><title>Registration Result</title></head>
<body>
<%
    String username = request.getParameter("username");
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String password = request.getParameter("password");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    // Check if the username already exists
    PreparedStatement psCheck = con.prepareStatement("SELECT * FROM users WHERE username=?");
    psCheck.setString(1, username);
    ResultSet rsCheck = psCheck.executeQuery();

    if (rsCheck.next()) {
        out.println("Username already exists. Please choose a different username.");
    } else {
        // Insert new user into the database
        PreparedStatement psInsert = con.prepareStatement("INSERT INTO users (username, first_name, last_name, password) VALUES (?, ?, ?, ?)");
        psInsert.setString(1, username);
        psInsert.setString(2, firstName);
        psInsert.setString(3, lastName);
        psInsert.setString(4, password);
        int rowsAffected = psInsert.executeUpdate();

        if (rowsAffected > 0) {
            // Redirect to the login page after successful registration
            response.sendRedirect("login.jsp");
        } else {
            out.println("Error during registration. Please try again.");
        }
    }

    con.close();
%>
</body>
</html>