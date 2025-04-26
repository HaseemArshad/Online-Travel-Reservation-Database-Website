<%@ page import="java.util.*" %>
<html>
<head>
    <title>My Bookings</title>
    <style>
        .toggle-buttons { margin-bottom: 20px; }
        .toggle-buttons form { display: inline; }
        .toggle-buttons button { padding: 8px 16px; margin-right: 10px; cursor: pointer; }
        .booking-card {
            margin-bottom: 10px;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
        }
    </style>
</head>
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

        String currentFilter = (String) request.getAttribute("currentFilter");
        if (currentFilter == null) currentFilter = "upcoming";
    %>

    <!-- Toggle Buttons -->
    <div class="toggle-buttons">
        <form method="get" action="viewBookings">
            <input type="hidden" name="filter" value="upcoming">
            <button type="submit" <%= "upcoming".equals(currentFilter) ? "style='font-weight:bold;'" : "" %>>Upcoming Flights</button>
        </form>
        <form method="get" action="viewBookings">
            <input type="hidden" name="filter" value="past">
            <button type="submit" <%= "past".equals(currentFilter) ? "style='font-weight:bold;'" : "" %>>Past Flights</button>
        </form>
        <form method="get" action="viewBookings">
            <input type="hidden" name="filter" value="canceled">
            <button type="submit" <%= "canceled".equals(currentFilter) ? "style='font-weight:bold;'" : "" %>>Canceled Flights</button>
        </form>
    </div>

    <h3>
        <%= currentFilter.equals("upcoming") ? "Upcoming Flights" : 
             currentFilter.equals("past") ? "Past Flights" : 
             "Canceled Flights" %>
    </h3>

    <%
        List<Map<String, String>> bookingsList = (List<Map<String, String>>) request.getAttribute("bookingsList");
        if (bookingsList == null || bookingsList.isEmpty()) {
    %>
        <p>No <%= currentFilter %> bookings.</p>
    <%
        } else {
            for (Map<String, String> booking : bookingsList) {
    %>
        <div class="booking-card">
            Booking ID: <%= booking.get("booking_id") %> |
            <%= booking.get("airline") %> |
            <%= booking.get("from_airport") %> ➔ <%= booking.get("to_airport") %> |
            Date: <%= booking.get("departure_date") %> |
            Time: <%= booking.get("departure_time") %> |
            Price: $<%= booking.get("price") %> |
            Class: <%= booking.get("ticket_class") != null ? booking.get("ticket_class") : "N/A" %>
            <% if ("canceled".equals(currentFilter)) { %>
                | Canceled On: <%= booking.get("cancel_date") %>
            <% } else if ("upcoming".equals(currentFilter)) { %>
                <form action="cancelBooking" method="post" style="display:inline;">
                    <input type="hidden" name="bookingId" value="<%= booking.get("booking_id") %>">
                    <input type="submit" value="Cancel Booking">
                </form>
            <% } %>
        </div>
    <%
            }
        }
    %>

    <br><a href="home.jsp">Back to Home</a>
</body>
</html>
