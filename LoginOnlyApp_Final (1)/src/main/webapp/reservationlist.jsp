<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%
    String searchQuery = request.getParameter("search");
    String searchBy = request.getParameter("searchBy");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    PreparedStatement ps;
    ResultSet rs;

    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
        if ("flight_id".equals(searchBy)) {
            ps = con.prepareStatement(
                "SELECT b.booking_id, b.flight_id, b.booking_date, u.username, u.first_name, u.last_name " +
                "FROM bookings b JOIN users u ON b.user_id = u.id " +
                "WHERE b.flight_id = ?"
            );
            ps.setString(1, searchQuery);
        } else {
            ps = con.prepareStatement(
                "SELECT b.booking_id, b.flight_id, b.booking_date, u.username, u.first_name, u.last_name " +
                "FROM bookings b JOIN users u ON b.user_id = u.id " +
                "WHERE u.username LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ?"
            );
            String likeQuery = "%" + searchQuery + "%";
            ps.setString(1, likeQuery);
            ps.setString(2, likeQuery);
            ps.setString(3, likeQuery);
        }
        rs = ps.executeQuery();
    } else {
        ps = con.prepareStatement(
            "SELECT b.booking_id, b.flight_id, b.booking_date, u.username, u.first_name, u.last_name " +
            "FROM bookings b JOIN users u ON b.user_id = u.id"
        );
        rs = ps.executeQuery();
    }
%>
<html>
<head>
    <title>Reservation Lookup</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 10px;
            text-align: center;
        }
        form {
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Reservation Lookup</h1>

    <form method="get" action="reservationlist.jsp">
        <label for="searchBy">Search by:</label>
        <select name="searchBy" id="searchBy">
            <option value="flight_id" <%= "flight_id".equals(searchBy) ? "selected" : "" %>>Flight Number</option>
            <option value="username" <%= "username".equals(searchBy) ? "selected" : "" %>>Customer Name</option>
        </select>
        <input type="text" name="search" value="<%= (searchQuery != null ? searchQuery : "") %>" />
        <input type="submit" value="Search" />
    </form>

    <table>
        <tr>
            <th>Booking ID</th>
            <th>Flight Number</th>
            <th>Booking Date</th>
            <th>Username</th>
            <th>First Name</th>
            <th>Last Name</th>
        </tr>
        <%
            while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("booking_id") %></td>
            <td><%= rs.getString("flight_id") %></td>
            <td><%= rs.getDate("booking_date") %></td>
            <td><%= rs.getString("username") %></td>
            <td><%= rs.getString("first_name") %></td>
            <td><%= rs.getString("last_name") %></td>
        </tr>
        <%
            }
            rs.close();
            con.close();
        %>
    </table>

    <br>
    <form action="adminhome.jsp" method="get">
        <input type="submit" value="⬅ Back to Admin Dashboard">
    </form>
</div>
</body>
</html>
