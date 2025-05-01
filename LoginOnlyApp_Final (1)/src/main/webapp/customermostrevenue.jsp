<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<html>
<head>
    <title>Top Revenue Customer</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h1>Customer Who Generated Most Revenue</h1>

<%
    ps = con.prepareStatement(
        "SELECT u.id, u.username, u.first_name, u.last_name, SUM(f.price) AS total_revenue " +
        "FROM bookings b " +
        "JOIN users u ON b.user_id = u.id " +
        "JOIN flights f ON b.flight_id = f.flight_id " +
        "GROUP BY u.id, u.username, u.first_name, u.last_name " +
        "ORDER BY total_revenue DESC LIMIT 1"
    );
    rs = ps.executeQuery();
    if (rs.next()) {
%>
    <table>
        <tr>
            <th>User ID</th>
            <th>Username</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Total Revenue</th>
        </tr>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("username") %></td>
            <td><%= rs.getString("first_name") %></td>
            <td><%= rs.getString("last_name") %></td>
            <td>$<%= String.format("%.2f", rs.getDouble("total_revenue")) %></td>
        </tr>
    </table>
<%
    } else {
%>
    <p>No customer data available.</p>
<%
    }
    rs.close();
    con.close();
%>

    <br>
    <a href="adminhome.jsp">← Back to Admin Dashboard</a>
</div>
</body>
</html>
