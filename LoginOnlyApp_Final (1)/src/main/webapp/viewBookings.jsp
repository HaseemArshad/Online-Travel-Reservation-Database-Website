<%@ page import="java.util.*" %>
<html>
<head><title>My Bookings</title></head>
<body>
    <h2>Your Flight Bookings</h2>
    <%
    String msg = (String) session.getAttribute("message");
    if (msg != null) {
%>
    <p style="color:green;"><%= msg %></p>
<%
        session.removeAttribute("message");
    }
%>
    
    <%
        String message = (String) request.getAttribute("message");
        if (message != null) {
            out.println("<p><b>" + message + "</b></p>");
        }

        List<Map<String, String>> bookingsList = (List<Map<String, String>>) request.getAttribute("bookingsList");
        if (bookingsList == null || bookingsList.isEmpty()) {
    %>
        <p>You have no bookings.</p>
    <%
        } else {
            for (Map<String, String> booking : bookingsList) {
    %>
                <p>
                    Booking ID: <%= booking.get("booking_id") %> |
                    <%= booking.get("airline") %> |
                    <%= booking.get("from_airport") %> -> <%= booking.get("to_airport") %> |
                    Date: <%= booking.get("departure_date") %> |
                    Time: <%= booking.get("departure_time") %> |
                    Price: $<%= booking.get("price") %>
                    <!-- Cancel Button -->
                    <form action="cancelBooking" method="post" style="display:inline;">
                        <input type="hidden" name="bookingId" value="<%= booking.get("booking_id") %>">
                        <input type="submit" value="Cancel Booking">
                    </form>
                </p>
    <%
            }
        }
    %>
    <br><a href="home.jsp">Back to Home</a>
</body>
</html>
