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
<head><title>Most Active Flights</title></head>
<body>
<h1>Flights with Most Tickets Sold</h1>
<%
    ps = con.prepareStatement(
        "SELECT f.flight_id, f.airline, COUNT(b.booking_id) AS tickets_sold " +
        "FROM bookings b " +
        "JOIN flights f ON b.flight_id = f.flight_id " +
        "GROUP BY f.flight_id, f.airline " +
        "ORDER BY tickets_sold DESC"
    );
    rs = ps.executeQuery();
%>
<table border="1">
    <tr>
        <th>Flight ID</th><th>Airline</th><th>Tickets Sold</th>
    </tr>
<%
    while (rs.next()) {
%>
    <tr>
        <td><%= rs.getString("flight_id") %></td>
        <td><%= rs.getString("airline") %></td>
        <td><%= rs.getInt("tickets_sold") %></td>
    </tr>
<%
    }
    rs.close();
    con.close();
%>
</table>
<br><a href="adminhome.jsp">Back to Admin Dashboard</a>
</body>
</html>
