<%@ page import="java.util.*" %>
<html>
<head>
    <title>Booking Confirmation</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        .flight-summary {
            border: 1px solid #ccc;
            border-radius: 6px;
            padding: 12px;
            margin-bottom: 20px;
            background-color: #f0f8ff;
        }
    </style>
</head>
<body>
<div class="container">
    <h2><%= request.getAttribute("message") %></h2>
    <br>

    <% 
        List<Map<String, String>> flightList = (List<Map<String, String>>) request.getAttribute("roundTripFlights");
        Map<String, String> singleFlight = (Map<String, String>) request.getAttribute("singleFlight");
    %>

    <% if (flightList != null && !flightList.isEmpty()) { %>
        <h3>Round-Trip Booking Summary:</h3>
        <% for (Map<String, String> flight : flightList) { %>
            <div class="flight-summary">
                <strong>Flight:</strong> <%= flight.get("flight_number") %> (<%= flight.get("airline") %>)<br>
                <strong>From:</strong> <%= flight.get("from_airport") %> → <strong>To:</strong> <%= flight.get("to_airport") %><br>
                <strong>Departure:</strong> <%= flight.get("departure_date") %> at <%= flight.get("departure_time") %><br>
                <strong>Arrival:</strong> <%= flight.get("arrival_date") %> at <%= flight.get("arrival_time") %><br>
                <strong>Seat:</strong> <%= flight.get("seat_number") %> | <strong>Class:</strong> <%= flight.get("class") %><br>
                <strong>Total Fare:</strong> $<%= flight.get("total_fare") %>
            </div>
        <% } %>
    <% } else if (singleFlight != null) { %>
        <h3>One-Way Booking Summary:</h3>
        <div class="flight-summary">
            <strong>Flight:</strong> <%= singleFlight.get("flight_number") %> (<%= singleFlight.get("airline") %>)<br>
            <strong>From:</strong> <%= singleFlight.get("from_airport") %> → <strong>To:</strong> <%= singleFlight.get("to_airport") %><br>
            <strong>Departure:</strong> <%= singleFlight.get("departure_date") %> at <%= singleFlight.get("departure_time") %><br>
            <strong>Arrival:</strong> <%= singleFlight.get("arrival_date") %> at <%= singleFlight.get("arrival_time") %><br>
            <strong>Seat:</strong> <%= singleFlight.get("seat_number") %> | <strong>Class:</strong> <%= singleFlight.get("class") %><br>
            <strong>Total Fare:</strong> $<%= singleFlight.get("total_fare") %>
        </div>
    <% } else { %>
        <p>No flight information available.</p>
    <% } %>

    <a href="home.jsp">Back to Home</a>
</div>
</body>
</html>
