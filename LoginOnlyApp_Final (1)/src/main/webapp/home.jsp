<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<html>
<head>
    <title>Home - Flight Reservation</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    if (username == null) {
        username = (String) session.getAttribute("username");
    }

    if (username == null) {
%>
    <h2>You are not logged in. <a href="login.jsp">Login</a></h2>
<%
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    if (con == null) {
%>
    <p style="color: red;">Database connection failed. Please try again later.</p>
<%
    } else {
        PreparedStatement ps;
        ResultSet rs = null;

        if (password != null) {
            ps = con.prepareStatement("SELECT * FROM users WHERE username=? AND password=?");
            ps.setString(1, username);
            ps.setString(2, password);
            rs = ps.executeQuery();

            if (rs.next()) {
                session.setAttribute("username", username);
                session.setAttribute("userId", rs.getInt("id"));
                session.setAttribute("role", rs.getString("role"));
                session.setAttribute("firstName", rs.getString("first_name"));
                session.setAttribute("lastName", rs.getString("last_name"));


                String role = rs.getString("role");

                if ("admin".equals(role)) {
                    response.sendRedirect("adminhome.jsp");
                    con.close();
                    return;
                } else if ("representative".equals(role)) {
                    response.sendRedirect("representativehome.jsp");
                    con.close();
                    return;
                }
            } else {
%>
    <h2>Login failed for username '<%= username %>'</h2>
    <p><a href="login.jsp">Try Again</a></p>
<%
                con.close();
                return;
            }
        }

        // ✅ Get all distinct airport codes
        Set<String> airportSet = new TreeSet<>();
        PreparedStatement psAirports = con.prepareStatement(
            "SELECT DISTINCT from_airport AS airport FROM flights " +
            "UNION SELECT DISTINCT to_airport AS airport FROM flights"
        );
        ResultSet rsAirports = psAirports.executeQuery();
        while (rsAirports.next()) {
            airportSet.add(rsAirports.getString("airport"));
        }
        rsAirports.close();
        psAirports.close();
%>

    <h1>Welcome, <%= username %>!</h1>
    <h2>Successfully Logged In</h2>

    <p><a href="viewBookings">View My Bookings</a></p>

    <form action="searchFlights" method="get">
        <h3>Search for Flights</h3>

        <label>Trip Type:</label>
        <select name="tripType">
            <option value="oneway">One Way</option>
            <option value="roundtrip">Round Trip</option>
        </select><br><br>

        <label for="fromAirport">From Airport:</label>
        <select name="fromAirport" id="fromAirport" required>
            <option value="">-- Select Departure Airport --</option>
            <% for (String airport : airportSet) { %>
                <option value="<%= airport %>"><%= airport %></option>
            <% } %>
        </select><br><br>

        <label for="toAirport">To Airport:</label>
        <select name="toAirport" id="toAirport" required>
            <option value="">-- Select Arrival Airport --</option>
            <% for (String airport : airportSet) { %>
                <option value="<%= airport %>"><%= airport %></option>
            <% } %>
        </select><br><br>

        <label>Departure Date (YYYY-MM-DD):</label>
        <input type="text" name="departureDate" required><br><br>

        <label>Return Date (YYYY-MM-DD):</label>
        <input type="text" name="returnDate"><br><br>

        <input type="submit" value="Search Flights">
    </form>

<%
    }

    if (session.getAttribute("username") != null) {
%>
    <form action="logout.jsp" method="post" style="margin-top: 20px;">
        <input type="submit" value="Log Out" />
    </form>
<%
    }
    con.close();
%>

<br>
<a href="browseQA.jsp">Browse FAQs</a>
</div>
</body>
</html>
