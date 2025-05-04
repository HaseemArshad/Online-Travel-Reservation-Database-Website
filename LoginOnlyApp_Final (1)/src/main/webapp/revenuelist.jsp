<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%
    String searchBy = request.getParameter("searchBy");
    String username = request.getParameter("username");
    String fullName = request.getParameter("full_name");
    String airline = request.getParameter("airline");
    String flightNumber = request.getParameter("flight_number");

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
        table { border-collapse: collapse; margin-top: 20px; width: 100%; }
        th, td { padding: 10px; border: 1px solid #ccc; text-align: center; }
        form { margin-top: 20px; }
    </style>
    <script>
        function toggleSearchFields() {
            var searchBy = document.getElementById("searchBy").value;
            document.getElementById("flightField").style.display = (searchBy === "flight") ? "block" : "none";
            document.getElementById("airlineField").style.display = (searchBy === "airline") ? "block" : "none";
            document.getElementById("customerFields").style.display = (searchBy === "customer") ? "block" : "none";
        }
        window.onload = toggleSearchFields;
    </script>
</head>
<body>
<div class="container">
    <h1>Revenue Summary List</h1>

    <form method="get" action="revenuelist.jsp">
        <label for="searchBy">Search by:</label>
        <select name="searchBy" id="searchBy" onchange="toggleSearchFields()">
            <option value="flight" <%= "flight".equals(searchBy) ? "selected" : "" %>>Flight Number</option>
            <option value="airline" <%= "airline".equals(searchBy) ? "selected" : "" %>>Airline</option>
            <option value="customer" <%= "customer".equals(searchBy) ? "selected" : "" %>>Customer Name</option>
        </select><br><br>

        <div id="flightField" style="display:none;">
            <label for="flight_number">Flight Number:</label>
            <input type="text" name="flight_number" value="<%= (flightNumber != null ? flightNumber : "") %>" />
        </div>

        <div id="airlineField" style="display:none;">
            <label for="airline">Select Airline:</label>
            <select name="airline">
                <option value="">-- Select Airline --</option>
                <%
                    ps = con.prepareStatement("SELECT DISTINCT airline FROM flights");
                    rs = ps.executeQuery();
                    while (rs.next()) {
                        String code = rs.getString("airline");
                %>
                <option value="<%= code %>" <%= code.equals(airline) ? "selected" : "" %>><%= code %></option>
                <%
                    }
                    rs.close();
                %>
            </select>
        </div>

        <div id="customerFields" style="display:none;">
            <label for="username">Username:</label>
            <input type="text" name="username" value="<%= (username != null ? username : "") %>" />
            <label for="full_name">Full Name:</label>
            <input type="text" name="full_name" placeholder="First Last" value="<%= (fullName != null ? fullName : "") %>" />
        </div>

        <input type="submit" value="Search" />
    </form>

    <%-- Flight Search --%>
    <%
        if ("flight".equals(searchBy) && flightNumber != null && !flightNumber.trim().isEmpty()) {
            ps = con.prepareStatement("SELECT SUM(booking_fee) AS revenue FROM ticket WHERE flight_number = ?");
            ps.setString(1, flightNumber);
            rs = ps.executeQuery();
            if (rs.next()) totalRevenue = rs.getDouble("revenue");
            rs.close();
    %>
    <h3>Total Revenue from Flight '<%= flightNumber %>': $<%= String.format("%.2f", totalRevenue) %></h3>
    <%
            ps = con.prepareStatement("SELECT * FROM ticket WHERE flight_number = ?");
            ps.setString(1, flightNumber);
            rs = ps.executeQuery();
    %>
    <table>
        <tr><th>Ticket ID</th><th>Customer</th><th>Flight</th><th>Booking Fee</th></tr>
        <% while (rs.next()) { %>
        <tr>
            <td><%= rs.getInt("ticket_id") %></td>
            <td><%= rs.getString("customer_first_name") %> <%= rs.getString("customer_last_name") %></td>
            <td><%= rs.getString("flight_number") %></td>
            <td>$<%= String.format("%.2f", rs.getDouble("booking_fee")) %></td>
        </tr>
        <% } rs.close(); %>
    </table>

    <%-- Airline Search --%>
    <% } else if ("airline".equals(searchBy) && airline != null && !airline.trim().isEmpty()) {
            ps = con.prepareStatement(
                "SELECT SUM(T.booking_fee) AS revenue FROM ticket T " +
                "JOIN flights F ON T.flight_number = F.flight_number WHERE F.airline = ?"
            );
            ps.setString(1, airline);
            rs = ps.executeQuery();
            if (rs.next()) totalRevenue = rs.getDouble("revenue");
            rs.close();
    %>
    <h3>Total Revenue from Airline '<%= airline %>': $<%= String.format("%.2f", totalRevenue) %></h3>
    <%
            ps = con.prepareStatement(
                "SELECT T.* FROM ticket T " +
                "JOIN flights F ON T.flight_number = F.flight_number WHERE F.airline = ?"
            );
            ps.setString(1, airline);
            rs = ps.executeQuery();
    %>
    <table>
        <tr><th>Ticket ID</th><th>Customer</th><th>Flight</th><th>Booking Fee</th></tr>
        <% while (rs.next()) { %>
        <tr>
            <td><%= rs.getInt("ticket_id") %></td>
            <td><%= rs.getString("customer_first_name") %> <%= rs.getString("customer_last_name") %></td>
            <td><%= rs.getString("flight_number") %></td>
            <td>$<%= String.format("%.2f", rs.getDouble("booking_fee")) %></td>
        </tr>
        <% } rs.close(); %>
    </table>

    <%-- Customer Search with full name match --%>
    <% } else if ("customer".equals(searchBy) &&
                  username != null && fullName != null &&
                  !username.trim().isEmpty() && !fullName.trim().isEmpty()) {

        String[] parts = fullName.trim().split(" ");
        String first = parts.length > 0 ? parts[0] : "";
        String last = parts.length > 1 ? parts[1] : "";

        ps = con.prepareStatement(
            "SELECT SUM(T.booking_fee) AS revenue " +
            "FROM ticket T " +
            "JOIN users U ON T.customer_first_name = U.first_name AND T.customer_last_name = U.last_name " +
            "WHERE U.username = ? AND U.first_name = ? AND U.last_name = ?"
        );
        ps.setString(1, username);
        ps.setString(2, first);
        ps.setString(3, last);
        rs = ps.executeQuery();
        if (rs.next()) totalRevenue = rs.getDouble("revenue");
        rs.close();
    %>
    <h3>Total Revenue from Customer '<%= fullName %>' (Username: <%= username %>): $<%= String.format("%.2f", totalRevenue) %></h3>
    <%
        ps = con.prepareStatement(
            "SELECT T.* FROM ticket T " +
            "JOIN users U ON T.customer_first_name = U.first_name AND T.customer_last_name = U.last_name " +
            "WHERE U.username = ? AND U.first_name = ? AND U.last_name = ?"
        );
        ps.setString(1, username);
        ps.setString(2, first);
        ps.setString(3, last);
        rs = ps.executeQuery();
    %>
    <table>
        <tr><th>Ticket ID</th><th>Flight</th><th>Booking Fee</th></tr>
        <% while (rs.next()) { %>
        <tr>
            <td><%= rs.getInt("ticket_id") %></td>
            <td><%= rs.getString("flight_number") %></td>
            <td>$<%= String.format("%.2f", rs.getDouble("booking_fee")) %></td>
        </tr>
        <% } rs.close(); } con.close(); %>
    </table>

    <br>
    <form action="adminhome.jsp" method="get">
        <input type="submit" value="Back to Admin Dashboard">
    </form>
</div>
</body>
</html>
