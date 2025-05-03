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
        	    "SELECT COUNT(*) AS ticket_count, SUM(booking_fee) AS revenue " +
        	    "FROM Ticket " +
        	    "WHERE DATE_FORMAT(purchase_date, '%Y-%m') = ?"
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
<head>
    <title>Monthly Sales Report</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        form {
            margin: 20px 0;
        }
        .summary {
            margin-top: 25px;
            background: #f2f2f2;
            padding: 15px;
            border-radius: 8px;
            width: fit-content;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Monthly Sales Report</h1>

    <form method="get" action="salesreport.jsp">
        <label for="month">Search by Month:</label>
        <input type="month" id="month" name="month" value="<%= (selectedMonth != null ? selectedMonth : "") %>" />
        <input type="submit" value="View Report" />
    </form>

    <% if (selectedMonth != null) { %>
        <div class="summary">
            <h2>Results for <%= selectedMonth %>:</h2>
            <p><strong>Total Tickets Sold:</strong> <%= totalTickets %></p>
            <p><strong>Total Revenue:</strong> $<%= String.format("%.2f", totalRevenue) %></p>
        </div>
    <% } %>

    <br>
    <form action="adminhome.jsp" method="get">
        <input type="submit" value=" Back to Admin Dashboard">
    </form>
</div>
</body>
</html>
