<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    Statement stmt = con.createStatement();
    ResultSet allUsers = null;
    try {
        allUsers = stmt.executeQuery("SELECT * FROM users");
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
%>
<html>
<head>
    <title>Manage Users</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h1>Manage Users</h1>

    <form action="addusers.jsp" method="get" style="display:inline-block; margin-right: 10px;">
        <input type="submit" value="Add User" />
    </form>
    <form action="editusers.jsp" method="get" style="display:inline-block; margin-right: 10px;">
        <input type="submit" value="Edit User" />
    </form>
    <form action="deleteusers.jsp" method="get" style="display:inline-block;">
        <input type="submit" value="Delete User" />
    </form>

    <hr>
    <h2>List of All Active Users</h2>
    <table>
        <tr>
            <th>User ID</th>
            <th>Username</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Role</th>
        </tr>
<%
    while (allUsers.next()) {
%>
        <tr>
            <td><%= allUsers.getInt("id") %></td>
            <td><%= allUsers.getString("username") %></td>
            <td><%= allUsers.getString("first_name") %></td>
            <td><%= allUsers.getString("last_name") %></td>
            <td><%= allUsers.getString("role") %></td>
        </tr>
<%
    }
    allUsers.close();
    con.close();
%>
    </table>

    <br><a href="adminhome.jsp">← Back to Admin Dashboard</a>
</div>
</body>
</html>
