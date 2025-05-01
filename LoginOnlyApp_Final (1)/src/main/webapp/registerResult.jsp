<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<html>
<head>
    <title>Registration Result</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<%
    String username = request.getParameter("username");
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String password = request.getParameter("password");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    PreparedStatement psCheck = con.prepareStatement("SELECT * FROM users WHERE username=?");
    psCheck.setString(1, username);
    ResultSet rsCheck = psCheck.executeQuery();

    if (rsCheck.next()) {
%>
<div class="container">
    <h2>Error: Username Already Exists</h2>
    <p>The username '<strong><%= username %></strong>' is already taken.</p>

    <form action="register.jsp" method="post" style="display:inline-block; margin-right: 10px;">
        <input type="submit" value="Try Again" />
    </form>

    <form action="login.jsp" method="post" style="display:inline-block;">
        <input type="submit" value="Login Instead" />
    </form>
</div>
<%
    } else {
        PreparedStatement psInsert = con.prepareStatement(
            "INSERT INTO users (username, first_name, last_name, password) VALUES (?, ?, ?, ?)"
        );
        psInsert.setString(1, username);
        psInsert.setString(2, firstName);
        psInsert.setString(3, lastName);
        psInsert.setString(4, password);
        int rowsAffected = psInsert.executeUpdate();

        if (rowsAffected > 0) {
            response.sendRedirect("login.jsp");
        } else {
%>
<div class="container">
    <p style="color: red;">Unknown error occurred during registration. Please try again.</p>
</div>
<%
        }
    }

    con.close();
%>
</body>
</html>
