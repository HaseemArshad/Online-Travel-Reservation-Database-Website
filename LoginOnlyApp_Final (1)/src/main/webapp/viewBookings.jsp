<%@ page import="java.util.*" %>
<html>
<head>
    <title>My Bookings</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        .container { padding: 20px; }
        .toggle-buttons { margin-bottom: 20px; }
        .toggle-buttons form { display: inline; }
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
        Map<Integer, String> seatAvailableMap = (Map<Integer, String>) request.getAttribute("seatAvailableMap");
        if (seatAvailableMap != null && !seatAvailableMap.isEmpty()) {
            for (Map.Entry<Integer, String> entry : seatAvailableMap.entrySet()) {
                Integer flightId = entry.getKey();
                String flightNumber = entry.getValue();
    %>
        <div class="seat-available">
            A seat is now available for Flight <%= flightNumber %>!
            <form action="bookFlight" method="post" style="display:inline;">
                <input type="hidden" name="flightId" value="<%= flightId %>">
                <input type="hidden" name="ticketClass" value="economy">
                <input type="hidden" name="price" value="0">
                <input type="hidden" name="fromWaitlist" value="true">
                <button type="submit">Book Now</button>
            </form>
        </div>
    <%
            }
        }

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
        List<Map<String, Object>> bookingsList = (List<Map<String, Object>>) request.getAttribute("bookingsList");
        if (bookingsList == null || bookingsList.isEmpty()) {
    %>
        <p>No <%= currentFilter %> bookings.</p>
    <%
        } else {
            for (Map<String, Object> booking : bookingsList) {
                List<Map<String, String>> flights = (List<Map<String, String>>) booking.get("flights");
                if (flights != null && !flights.isEmpty()) {
    %>
        <div class="booking-card">
            <% for (Map<String, String> f : flights) { 
                String travelType = "N/A";
                if (f.containsKey("is_international") && f.get("is_international") != null) {
                    String internationalFlag = f.get("is_international").trim();
                    if ("1".equals(internationalFlag)) {
                        travelType = "International";
                    } else if ("0".equals(internationalFlag)) {
                        travelType = "Domestic";
                    }
                }
            %>
                User Ticket ID: <%= f.get("booking_id") != null ? f.get("booking_id") : "N/A" %><br>
                Flight: <%= f.get("flight_number") %> (<%= f.get("airline_code") %>) |
                From: <%= f.get("from_airport") %> To: <%= f.get("to_airport") %> |
                Departure: <%= f.get("departure_date") %> <%= f.get("departure_time") %> |
                Arrival: <%= f.get("arrival_date") %> <%= f.get("arrival_time") %><br>
                Class: <%= f.get("class") != null ? f.get("class") : f.get("ticket_class") %> |
                Seat: <%= f.get("seat_number") != null ? f.get("seat_number") : "N/A" %> |
                Fare: $<%= f.get("total_fare") != null ? f.get("total_fare") : "N/A" %> |
                Purchased On: <%= f.get("purchase_date") != null ? f.get("purchase_date") : "N/A" %><br>
                Type: <%= travelType %><br><br>
            <% } %>

            Passenger: <%= flights.get(0).get("customer_first_name") %> <%= flights.get(0).get("customer_last_name") %><br>

            <%
                String ticketClass = flights.get(0).get("class");
                if (ticketClass == null) {
                    ticketClass = flights.get(0).get("ticket_class");
                }
                boolean isEligibleToCancel = ticketClass != null &&
                    (ticketClass.equalsIgnoreCase("first") || ticketClass.equalsIgnoreCase("business"));

                if ("upcoming".equals(currentFilter) && isEligibleToCancel) {
            %>
                <form action="cancelBooking" method="post">
                    <input type="hidden" name="bookingId" value="<%= flights.get(0).get("booking_id") %>">
                    <input type="submit" value="Cancel Booking">
                </form>
            <% } else if ("upcoming".equals(currentFilter)) { %>
                <p style="color: gray; font-style: italic;">Only Business and First class tickets can be cancelled for free.</p>
            <% } %>
        </div>
    <%
                }
            }
        }
    %>

    <a href="home.jsp">Back to Home</a>
</div>
</body>
</html>