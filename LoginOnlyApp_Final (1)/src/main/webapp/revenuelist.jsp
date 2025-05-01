<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%
    String searchQuery = request.getParameter("search");
    String searchBy = request.getParameter("searchBy");
    double totalRevenue = 0.0;

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    PreparedStatement ps = null;
    ResultSet rs = null;
%>
<html>
<head>
    <title>Revenue Summary</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        table {
            border-collapse: collapse;
            margin-top: 20px;
            width: 100%;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ccc;
            text-align: center;
        }
        form {
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Revenue Summary List</h1>

    <form method="get" action="revenuelist.jsp">
        <label for="searchBy">Search by:</label>
        <select name="searchBy" id="searchBy">
            <option value="flight" <%= "flight".equals(searchBy) ? "selected" : "" %>>Flight ID</option>
            <option value="airline" <%= "airline".equals(searchBy) ? "selected" : "" %>>Airline</option>
            <option value="customer" <%= "customer".equals(searchBy) ? "selected" : "" %>>Customer Name</option>
        </select>
        <input type="text" name="search" value="<%= (searchQuery != null ? searchQuery : "") %>" />
        <input type="submit" value="Search" />
    </form>

    <%
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            if ("flight".equals(searchBy)) {
                ps = con.prepareStatement(
                    "SELECT SUM(f.price) AS revenue FROM bookings b " +
                    "JOIN flights f ON b.flight_id = f.flight_id " +
                    "WHERE b.flight_id = ?"
                );
                ps.setString(1, searchQuery);
                rs = ps.executeQuery();
                if (rs.next()) {
                    totalRevenue = rs.getDouble("revenue");
                }
                rs.close();
    %>
                <h3>Total Revenue from Flight ID '<%= searchQuery %>': $<%= String.format("%.2f", totalRevenue) %></h3>
    <%
                ps = con.prepareStatement(
                    "SELECT u.id, u.username, u.first_name, u.last_name, f.price " +
                    "FROM bookings b JOIN users u ON b.user_id = u.id " +
                    "JOIN flights f ON b.flight_id = f.flight_id WHERE b.flight_id = ?"
                );
                ps.setString(1, searchQuery);
                rs = ps.executeQuery();
    %>
                <table>
                    <tr><th>User ID</th><th>Username</th><th>First Name</th><th>Last Name</th><th>Revenue</th></tr>
    <%
                while (rs.next()) {
    %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("username") %></td>
                        <td><%= rs.getString("first_name") %></td>
                        <td><%= rs.getString("last_name") %></td>
                        <td>$<%= rs.getDouble("price") %></td>
                    </tr>
    <%
                }
                rs.close();
            } else if ("airline".equals(searchBy)) {
                ps = con.prepareStatement(
                    "SELECT SUM(f.price) AS total_revenue FROM bookings b " +
                    "JOIN flights f ON b.flight_id = f.flight_id WHERE f.airline LIKE ?"
                );
                ps.setString(1, "%" + searchQuery + "%");
                rs = ps.executeQuery();
                if (rs.next()) {
                    totalRevenue = rs.getDouble("total_revenue");
                }
                rs.close();
    %>
                <h3>Total Revenue from Airline '<%= searchQuery %>': $<%= String.format("%.2f", totalRevenue) %></h3>
    <%
                ps = con.prepareStatement(
                    "SELECT f.flight_id, SUM(f.price) AS revenue FROM bookings b " +
                    "JOIN flights f ON b.flight_id = f.flight_id WHERE f.airline LIKE ? GROUP BY f.flight_id"
                );
                ps.setString(1, "%" + searchQuery + "%");
                rs = ps.executeQuery();
    %>
                <table>
                    <tr><th>Flight ID</th><th>Revenue</th></tr>
    <%
                while (rs.next()) {
    %>
                    <tr>
                        <td><%= rs.getString("flight_id") %></td>
                        <td>$<%= rs.getDouble("revenue") %></td>
                    </tr>
    <%
                }
                rs.close();
            } else if ("customer".equals(searchBy)) {
                String like = "%" + searchQuery + "%";
                ps = con.prepareStatement(
                    "SELECT SUM(f.price) AS total_revenue FROM bookings b " +
                    "JOIN flights f ON b.flight_id = f.flight_id " +
                    "JOIN users u ON b.user_id = u.id " +
                    "WHERE u.username LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ?"
                );
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
                rs = ps.executeQuery();
                if (rs.next()) {
                    totalRevenue = rs.getDouble("total_revenue");
                }
                rs.close();
    %>
                <h3>Total Revenue from Customer '<%= searchQuery %>': $<%= String.format("%.2f", totalRevenue) %></h3>
    <%
                ps = con.prepareStatement(
                    "SELECT u.id, u.username, u.first_name, u.last_name, b.booking_id, f.airline, f.flight_id, f.price, b.ticket_class " +
                    "FROM bookings b JOIN users u ON b.user_id = u.id " +
                    "JOIN flights f ON b.flight_id = f.flight_id " +
                    "WHERE u.username LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ?"
                );
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
                rs = ps.executeQuery();
    %>
                <table>
                    <tr>
                        <th>User ID</th><th>Username</th><th>First</th><th>Last</th>
                        <th>Booking ID</th><th>Class</th><th>Airline</th><th>Flight ID</th><th>Revenue</th>
                    </tr>
    <%
                while (rs.next()) {
    %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("username") %></td>
                        <td><%= rs.getString("first_name") %></td>
                        <td><%= rs.getString("last_name") %></td>
                        <td><%= rs.getInt("booking_id") %></td>
                        <td><%= rs.getString("ticket_class") %></td>
                        <td><%= rs.getString("airline") %></td>
                        <td><%= rs.getString("flight_id") %></td>
                        <td>$<%= rs.getDouble("price") %></td>
                    </tr>
    <%
                }
                rs.close();
            }
        }
        con.close();
    %>

    <br>
    <form action="adminhome.jsp" method="get">
        <input type="submit" value="⬅ Back to Admin Dashboard">
    </form>
</div>
</body>
</html>
