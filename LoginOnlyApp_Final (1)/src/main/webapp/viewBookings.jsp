<%@ page import="java.util.*" %>
<html>
<head>
    <title>My Bookings</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        .container {
            padding: 20px;
        }

        .toggle-buttons {
            margin-bottom: 20px;
        }

        .toggle-buttons form {
            display: inline;
        }

        .toggle-buttons button {
            padding: 8px 16px;
            margin-right: 10px;
            cursor: pointer;
            border: none;
            background-color: #e7e7e7;
            border-radius: 4px;
        }

        .toggle-buttons button:hover {
            background-color: #d4d4d4;
        }

        .booking-card {
            margin-bottom: 15px;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 6px;
            background-color: #f9f9f9;
        }

        .seat-available {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 6px;
            color: #155724;
            font-weight: bold;
        }

        .booking-card form {
            display: inline;
            margin-left: 15px;
        }

        a {
            display: inline-block;
            margin-top: 20px;
            text-decoration: none;
            color: #007bff;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Your Flight Bookings</h2>

    <%
        Map<Integer, Boolean> seatAvailableMap = (Map<Integer, Boolean>) request.getAttribute("seatAvailableMap");
        if (seatAvailableMap != null && !seatAvailableMap.isEmpty()) {
            for (Integer flightId : seatAvailableMap.keySet()) {
    %>
        <div class="seat-available">
            A seat is now available for Flight ID: <%= flightId %>!
            <form action="bookFlight.jsp" method="get" style="display:inline;">
                <input type="hidden" name="flightId" value="<%= flightId %>">
                <button type="submit">Book Now</button>
            </form>
        </div>
    <%
            }
        }
    %>

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

    <div class="toggle-buttons">
        <form method="get" action="viewBookings">
            <input type="hidden" name="filter" value="upcoming">
            <button type="submit" <%= "upcoming".equals(currentFilter) ? "style='font-weight:bold; background-color:#d4d4d4;'" : "" %>>Upcoming Flights</button>
        </form>
        <form method="get" action="viewBookings">
            <input type="hidden" name="filter" value="past">
            <button type="submit" <%= "past".equals(currentFilter) ? "style='font-weight:bold; background-color:#d4d4d4;'" : "" %>>Past Flights</button>
        </form>
        <form method="get" action="viewBookings">
            <input type="hidden" name="filter" value="canceled">
            <button type="submit" <%= "canceled".equals(currentFilter) ? "style='font-weight:bold; background-color:#d4d4d4;'" : "" %>>Canceled Flights</button>
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
            <%= booking.get("from_airport") %> -> <%= booking.get("to_airport") %> |
            Date: <%= booking.get("departure_date") %> |
            Time: <%= booking.get("departure_time") %> |
            Price: $<%= booking.get("price") %> |
            Class: <%= booking.get("ticket_class") != null ? booking.get("ticket_class") : "N/A" %>

            <% if ("canceled".equals(currentFilter)) { %>
                | Canceled On: <%= booking.get("cancel_date") %>
            <% } else if ("upcoming".equals(currentFilter)) { %>
                <form action="cancelBooking" method="post">
                    <input type="hidden" name="bookingId" value="<%= booking.get("booking_id") %>">
                    <input type="submit" value="Cancel Booking">
                </form>
            <% } %>
        </div>
    <%
            }
        }
    %>

    <a href="home.jsp"> Back to Home</a>
</div>
</body>
</html>
