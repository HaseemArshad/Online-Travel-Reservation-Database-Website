<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<html>
<head>
    <title>Home - Flight Reservation</title>
</head>
<body>
<%
    // Asking for username and password from the end user
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    // If parameters are null, fallback to session (for back-to-home)
    if (username == null) {
        username = (String) session.getAttribute("username");
    }

    if (username == null) {
        out.println("<h2>You're not logged in. <a href='login.jsp'>Login</a></h2>");
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    if (con == null) {
        out.println("Database connection failed. Please try again later.");
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
                session.setAttribute("role", rs.getString("role")); // <-- INSERT: Save role in session

                String role = rs.getString("role"); // <-- INSERT: Get role from query

                // INSERT: Redirect based on role
                if ("admin".equals(role)) {
                    response.sendRedirect("adminhome.jsp");
                    con.close();
                    return;
                } else if ("representative".equals(role)) {
                    response.sendRedirect("representativehome.jsp");
                    con.close();
                    return;
                }
                // Otherwise continue normally for customer
            } else {
                out.println("<h2>Login for username '" + username + "' failed. Please check your username and password.</h2>");
                out.println("<p><a href='login.jsp'>Try Again</a></p>");
                con.close();
                return;
            }
        }

        // Either logged in via form or already logged in via session
        out.println("<h1>Successfully Logged In User: " + username + "!</h1>");
        out.println("<h2>Welcome back!</h2>");
        out.println("<p><a href='viewBookings'>View My Bookings</a></p>");
%>

        <!-- Flight Search Form -->
        <form action="searchFlights" method="get">
            <h3>Search for Flights</h3>
            Trip Type:
            <select name="tripType">
                <option value="oneway">One Way</option>
                <option value="roundtrip">Round Trip</option>
            </select><br><br>

            From Airport Code: <input type="text" name="fromAirport" required><br><br>
            To Airport Code: <input type="text" name="toAirport" required><br><br>
            Departure Date (YYYY-MM-DD): <input type="text" name="departureDate" required><br><br>
            Return Date (YYYY-MM-DD): <input type="text" name="returnDate"><br><br>
            <input type="submit" value="Search Flights">
        </form>

<%
    }

    if (session.getAttribute("username") != null) {
%>
        <form action="logout.jsp" method="post">
            <input type="submit" value="Log Out" />
        </form>
<%
    }
    con.close();
%>

<p><a href="browseQA.jsp">Browse FAQs</a></p>

</body>
</html>