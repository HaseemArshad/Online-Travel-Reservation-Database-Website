<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%

    String message = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newUsername = request.getParameter("username");
        String newPassword = request.getParameter("password");
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String newRole = request.getParameter("role");

        if (newUsername != null && newPassword != null && firstName != null && lastName != null && newRole != null) {
            try {
                ApplicationDB db = new ApplicationDB();
                Connection con = db.getConnection();

                String checkSQL = "SELECT * FROM users WHERE username = ?";
                PreparedStatement checkStmt = con.prepareStatement(checkSQL);
                checkStmt.setString(1, newUsername);
                ResultSet rs = checkStmt.executeQuery();

                if (rs.next()) {
                    message = "Username already exists.";
                } else {
                    String sql = "INSERT INTO users (username, password, first_name, last_name, role) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setString(1, newUsername);
                    ps.setString(2, newPassword);
                    ps.setString(3, firstName);
                    ps.setString(4, lastName);
                    ps.setString(5, newRole);
                    ps.executeUpdate();
                    message = "User added successfully!";
                }
                con.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
            }
        } else {
            message = "Please fill in all fields.";
        }
    }
%>
<html>
<head>
    <title>Add New User</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h2>Add New User</h2>

    <% if (message != null) { %>
        <p><strong><%= message %></strong></p>
    <% } %>

    <form method="post" action="addusers.jsp">
        <label>Username:</label>
        <input type="text" name="username" required />

        <label>Password:</label>
        <input type="password" name="password" required />

        <label>First Name:</label>
        <input type="text" name="first_name" required />

        <label>Last Name:</label>
        <input type="text" name="last_name" required />

        <label>Role:</label>
        <select name="role" required>
            <option value="customer">Customer</option>
            <option value="representative">Representative</option>
            <option value="admin">Admin</option>
        </select>

        <input type="submit" value="Add User" />
    </form>

    <br>
    <a href="adminmanage.jsp">← Back to Manage Users</a>
</div>
</body>
</html>
