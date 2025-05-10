<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    Statement stmt = con.createStatement();

    String searchQuery = request.getParameter("search");
    String searchBy = request.getParameter("searchBy");
    if (searchBy == null || searchBy.isEmpty()) {
        searchBy = "username";
    }

    String message = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String userId = request.getParameter("id");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String updateRole = request.getParameter("role");

        try {
            String updateSQL = "UPDATE users SET username=?, password=?, first_name=?, last_name=?, role=? WHERE id=?";
            PreparedStatement ps = con.prepareStatement(updateSQL);
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, firstName);
            ps.setString(4, lastName);
            ps.setString(5, updateRole);
            ps.setInt(6, Integer.parseInt(userId));
            int updated = ps.executeUpdate();
            message = (updated > 0) ? "User updated successfully!" : "Update failed.";
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        }
    }

    ResultSet users;
    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
        String query = "SELECT * FROM users WHERE " + searchBy + " LIKE ?";
        PreparedStatement ps = con.prepareStatement(query);
        ps.setString(1, "%" + searchQuery + "%");
        users = ps.executeQuery();
    } else {
        users = stmt.executeQuery("SELECT * FROM users");
    }
%>
<html>
<head>
    <title>Edit Users</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h1>Edit Users</h1>

    <% if (message != null) { %>
        <p><strong><%= message %></strong></p>
    <% } %>

    <!-- Search Bar -->
    <form method="get" action="editusers.jsp">
        <label for="searchBy">Search by:</label>
        <select name="searchBy" id="searchBy">
            <option value="username" <%= "username".equals(searchBy) ? "selected" : "" %>>Username</option>
            <option value="first_name" <%= "first_name".equals(searchBy) ? "selected" : "" %>>First Name</option>
            <option value="last_name" <%= "last_name".equals(searchBy) ? "selected" : "" %>>Last Name</option>
            <option value="id" <%= "id".equals(searchBy) ? "selected" : "" %>>User ID</option>
        </select>
        <input type="text" name="search" value="<%= (searchQuery != null ? searchQuery : "") %>" />
        <input type="submit" value="Search" />
    </form>

    <br/>

    <!-- User Table -->
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Username</th>
            <th>Password</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Role</th>
            <th>Action</th>
        </tr>
    <%
        while (users.next()) {
    %>
        <tr>
        <form method="post" action="editusers.jsp">
            <td><input type="text" name="id" value="<%= users.getInt("id") %>" readonly size="3" /></td>
            <td><input type="text" name="username" value="<%= users.getString("username") %>" /></td>
            <td><input type="password" name="password" value="<%= users.getString("password") %>" /></td>
            <td><input type="text" name="first_name" value="<%= users.getString("first_name") %>" /></td>
            <td><input type="text" name="last_name" value="<%= users.getString("last_name") %>" /></td>
            <td>
                <select name="role">
                    <option value="customer" <%= "customer".equals(users.getString("role")) ? "selected" : "" %>>Customer</option>
                    <option value="representative" <%= "representative".equals(users.getString("role")) ? "selected" : "" %>>Representative</option>
                    <option value="admin" <%= "admin".equals(users.getString("role")) ? "selected" : "" %>>Admin</option>
                </select>
            </td>
            <td><input type="submit" value="Update" /></td>
        </form>
        </tr>
    <%
        }
        users.close();
        con.close();
    %>
    </table>

    <br>
    <a href="adminmanage.jsp"> Back to Manage Users</a>
</div>
</body>
</html>
