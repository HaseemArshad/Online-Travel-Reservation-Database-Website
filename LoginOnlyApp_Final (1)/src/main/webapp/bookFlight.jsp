<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String flightIdStr = request.getParameter("flightId");

    if (userId == null) {
        out.println("<h2>You must be logged in to book a flight.</h2>");
        out.println("<a href='login.jsp'>Login</a>");
    } else if (flightIdStr == null) {
        out.println("<h2>No flight selected for booking.</h2>");
        out.println("<a href='home.jsp'>Back to Home</a>");
    } else {
        int flightId = Integer.parseInt(flightIdStr);
        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            PreparedStatement ps = conn.prepareStatement("INSERT INTO bookings (user_id, flight_id) VALUES (?, ?)");
            ps.setInt(1, userId);
            ps.setInt(2, flightId);
            ps.executeUpdate();

            out.println("<h2>✅ Flight booked successfully!</h2>");
            out.println("<p><a href='home.jsp'>Back to Home</a></p>");

            conn.close();
        } catch (Exception e) {
            out.println("<h2>Error booking flight. Please try again.</h2>");
            e.printStackTrace(out);
        }
    }
%>
