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
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("deleteId") != null) {
        String deleteId = request.getParameter("deleteId");
        try {
            PreparedStatement deleteStmt = con.prepareStatement("DELETE FROM users WHERE id = ?");
            deleteStmt.setInt(1, Integer.parseInt(deleteId));
            int deleted = deleteStmt.executeUpdate();
            message = (deleted > 0) ? "User deleted successfully." : "User not found or could not be deleted.";
        } catch (Exception e) {
            message = "Error deleting user: " + e.getMessage();
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
    <title>Delete Users</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h1>Delete Users</h1>

    <% if (message != null) { %>
        <p><strong><%= message %></strong></p>
    <% } %>

    <form method="get" action="deleteusers.jsp">
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

    <table>
        <tr>
            <th>User ID</th>
            <th>Username</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Action</th>
        </tr>
    <%
        while (users.next()) {
    %>
        <tr>
            <td><%= users.getInt("id") %></td>
            <td><%= users.getString("username") %></td>
            <td><%= users.getString("first_name") %></td>
            <td><%= users.getString("last_name") %></td>
            <td>
                <form method="post" action="deleteusers.jsp" style="display:inline;">
                    <input type="hidden" name="deleteId" value="<%= users.getInt("id") %>" />
                    <input type="submit" value="Delete" onclick="return confirm('Are you sure you want to delete this user?');" />
                </form>
            </td>
        </tr>
    <%
        }
        users.close();
        con.close();
    %>
    </table>

    <br>
    <a href="adminmanage.jsp">← Back to Manage Users</a>
</div>
</body>
</html>
