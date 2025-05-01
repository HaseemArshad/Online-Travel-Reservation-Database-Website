<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.stream.Collectors" %>
<html>
<head>
    <title>Flight Search Results</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        .flight-card {
            border: 1px solid #ccc;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 8px;
            background: #f9f9f9;
        }
        .flight-card form {
            display: inline-block;
            margin-top: 10px;
        }
        .sort-section, .filter-section {
            margin-bottom: 25px;
        }
    </style>
</head>
<body>
<div class="container">

    <div class="sort-section">
        <h3>Sort Flights</h3>
        <form method="get" action="searchFlights">
            <input type="hidden" name="fromAirport" value="<%= request.getAttribute("fromAirport") %>">
            <input type="hidden" name="toAirport" value="<%= request.getAttribute("toAirport") %>">
            <input type="hidden" name="departureDate" value="<%= request.getAttribute("departureDate") %>">
            <input type="hidden" name="tripType" value="<%= request.getAttribute("tripType") %>">
            <input type="hidden" name="returnDate" value="<%= request.getAttribute("returnDate") %>">

            Sort by:
            <select name="sortBy">
                <option value="price">Price</option>
                <option value="departure_time">Take-off Time</option>
                <option value="arrival_time">Landing Time</option>
                <option value="duration">Duration</option>
            </select>
            <input type="submit" value="Sort">
        </form>
    </div>

    <div class="filter-section">
        <h3>Filter Flights</h3>
        <form method="get" action="searchFlights">
            <input type="hidden" name="fromAirport" value="<%= request.getAttribute("fromAirport") %>">
            <input type="hidden" name="toAirport" value="<%= request.getAttribute("toAirport") %>">
            <input type="hidden" name="departureDate" value="<%= request.getAttribute("departureDate") %>">
            <input type="hidden" name="tripType" value="<%= request.getAttribute("tripType") %>">
            <input type="hidden" name="returnDate" value="<%= request.getAttribute("returnDate") %>">

            Max Price: <input type="number" name="maxPrice" step="0.01">
            Stops: <input type="number" name="stops" min="0">
            Airline: <input type="text" name="airline">
            <input type="submit" value="Apply Filters">
        </form>
    </div>

    <h2>Departure Flights</h2>
    <%
        List<Map<String, String>> departureFlights = (List<Map<String, String>>) request.getAttribute("departureFlights");

        String maxPriceStr = request.getParameter("maxPrice");
        String stopsStr = request.getParameter("stops");
        String airlineFilter = request.getParameter("airline");

        if (maxPriceStr != null || stopsStr != null || (airlineFilter != null && !airlineFilter.isEmpty())) {
            departureFlights = departureFlights.stream().filter(flight -> {
                boolean matches = true;
                if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
                    matches &= Double.parseDouble(flight.get("price")) <= Double.parseDouble(maxPriceStr);
                }
                if (stopsStr != null && !stopsStr.isEmpty()) {
                    matches &= Integer.parseInt(flight.get("stops")) == Integer.parseInt(stopsStr);
                }
                if (airlineFilter != null && !airlineFilter.isEmpty()) {
                    matches &= flight.get("airline").toLowerCase().contains(airlineFilter.toLowerCase());
                }
                return matches;
            }).collect(Collectors.toList());
        }

        if (departureFlights.isEmpty()) {
    %>
        <p>No departure flights found.</p>
    <%
        } else {
            for (Map<String, String> flight : departureFlights) {
    %>
        <div class="flight-card">
            <strong><%= flight.get("airline") %></strong> |
            <%= flight.get("from_airport") %> -> <%= flight.get("to_airport") %><br>
            Date: <%= flight.get("departure_date") %> |
            $<%= flight.get("price") %> |
            Stops: <%= flight.get("stops") %> |
            Duration: <%= flight.get("duration") %>
            <form action="bookFlight" method="post">
                <input type="hidden" name="flightId" value="<%= flight.get("flight_id") %>">
                Class:
                <select name="ticketClass" required>
                    <option value="Economy">Economy</option>
                    <option value="Business">Business</option>
                    <option value="First">First</option>
                </select>
                <input type="submit" value="Book This Flight">
            </form>
        </div>
    <%
            }
        }
    %>

    <br>
    <a href="home.jsp"> Back to Home</a>
</div>
</body>
</html>
