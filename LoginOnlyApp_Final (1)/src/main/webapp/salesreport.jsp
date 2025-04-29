<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%
 
    String selectedMonth = request.getParameter("month"); // format YYYY-MM
    int totalTickets = 0;
    double totalRevenue = 0;

    if (selectedMonth != null && !selectedMonth.isEmpty()) {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        PreparedStatement ps = con.prepareStatement(
            "SELECT COUNT(*) AS ticket_count, SUM(f.price) AS revenue " +
            "FROM bookings b JOIN flights f ON b.flight_id = f.flight_id " +
            "WHERE DATE_FORMAT(b.booking_date, '%Y-%m') = ?"
        );
        ps.setString(1, selectedMonth);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            totalTickets = rs.getInt("ticket_count");
            totalRevenue = rs.getDouble("revenue");
        }

        rs.close();
        con.close();
    }
%>
<html>
<head><title>Monthly Sales Report</title></head>
<body>
<h1>Monthly Sales Report</h1>

<form method="get" action="salesreport.jsp">
    Search by Month:
    <input type="month" name="month" value="<%= (selectedMonth != null ? selectedMonth : "") %>" />
    <input type="submit" value="View Report" />
</form>

<% if (selectedMonth != null) { %>
    <h2>Results for <%= selectedMonth %>:</h2>
    <p><b>Total Tickets Sold:</b> <%= totalTickets %></p>
    <p><b>Total Revenue:</b> $<%= totalRevenue %></p>
<% } %>

<br><a href="adminhome.jsp">Back to Admin Dashboard</a>
</body>
</html>
