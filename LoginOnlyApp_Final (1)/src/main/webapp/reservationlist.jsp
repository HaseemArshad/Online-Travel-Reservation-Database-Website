<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%
    String searchBy = request.getParameter("searchBy");
    String usernameInput = request.getParameter("username");
    String fullNameInput = request.getParameter("full_name");
    String flightNumberInput = request.getParameter("flight_number");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    PreparedStatement ps;
    ResultSet rs;

    if ("flight_number".equals(searchBy) && flightNumberInput != null && !flightNumberInput.trim().isEmpty()) {
        ps = con.prepareStatement(
            "SELECT b.booking_id, f.flight_number, b.booking_date, u.username, u.first_name, u.last_name " +
            "FROM bookings b " +
            "JOIN users u ON b.user_id = u.id " +
            "JOIN flights f ON b.flight_id = f.flight_id " +
            "WHERE f.flight_number = ?"
        );
        ps.setString(1, flightNumberInput);
        rs = ps.executeQuery();

    } else if ("full_name".equals(searchBy) &&
               usernameInput != null && !usernameInput.trim().isEmpty() &&
               fullNameInput != null && !fullNameInput.trim().isEmpty()) {

        String[] nameParts = fullNameInput.trim().split(" ");
        String firstName = nameParts.length > 0 ? nameParts[0] : "";
        String lastName = nameParts.length > 1 ? nameParts[1] : "";

        ps = con.prepareStatement(
            "SELECT b.booking_id, f.flight_number, b.booking_date, u.username, u.first_name, u.last_name " +
            "FROM bookings b " +
            "JOIN users u ON b.user_id = u.id " +
            "JOIN flights f ON b.flight_id = f.flight_id " +
            "WHERE u.username = ? AND u.first_name = ? AND u.last_name = ?"
        );
        ps.setString(1, usernameInput);
        ps.setString(2, firstName);
        ps.setString(3, lastName);
        rs = ps.executeQuery();

    } else {
        ps = con.prepareStatement(
            "SELECT b.booking_id, f.flight_number, b.booking_date, u.username, u.first_name, u.last_name " +
            "FROM bookings b " +
            "JOIN users u ON b.user_id = u.id " +
            "JOIN flights f ON b.flight_id = f.flight_id"
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
        .input-group {
            margin-bottom: 10px;
        }
    </style>
    <script>
        function toggleInputs() {
            var searchBy = document.getElementById("searchBy").value;
            document.getElementById("flightNumberInput").style.display = (searchBy === "flight_number") ? "block" : "none";
            document.getElementById("nameInputs").style.display = (searchBy === "full_name") ? "block" : "none";
        }
        window.onload = toggleInputs;
    </script>
</head>
<body>
<div class="container">
    <h1>Reservation Lookup</h1>

    <form method="get" action="reservationlist.jsp">
        <label for="searchBy">Search by:</label>
        <select name="searchBy" id="searchBy" onchange="toggleInputs()">
            <option value="flight_number" <%= "flight_number".equals(searchBy) ? "selected" : "" %>>Flight Number</option>
            <option value="full_name" <%= "full_name".equals(searchBy) ? "selected" : "" %>>Full Name + Username</option>
        </select><br><br>

        <div id="flightNumberInput" class="input-group">
            <label for="flight_number">Flight Number:</label>
            <input type="text" name="flight_number" value="<%= (flightNumberInput != null ? flightNumberInput : "") %>" />
        </div>

        <div id="nameInputs" class="input-group">
            <label for="username">Username:</label>
            <input type="text" name="username" value="<%= (usernameInput != null ? usernameInput : "") %>" /><br><br>

            <label for="full_name">Full Name:</label>
            <input type="text" name="full_name" placeholder="First Last" value="<%= (fullNameInput != null ? fullNameInput : "") %>" />
        </div>

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
            <td><%= rs.getString("flight_number") %></td>
            <td><%= rs.getTimestamp("booking_date") %></td>
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
        <input type="submit" value=" Back to Admin Dashboard">
    </form>
</div>
</body>
</html>