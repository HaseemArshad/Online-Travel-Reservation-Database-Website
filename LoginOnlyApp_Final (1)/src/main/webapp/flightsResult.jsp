<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.stream.Collectors" %>
<html>
<head>
    <title>Flight Search Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h2 { color: #2c3e50; }
        .flight-card {
            border: 1px solid #ccc;
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 5px;
            background: #f9f9f9;
        }
        .flight-card form { display: inline; }
        .sort-section, .filter-section { margin-bottom: 20px; }
        a { text-decoration: none; color: #2980b9; }
    </style>
</head>
<body>

    <!-- Sort Section -->
    <div class="sort-section">
        <h3>Sort Flights</h3>
        <form method="post" action="searchFlights">
            <input type="hidden" name="fromAirport" value="<%= request.getAttribute("fromAirport") %>">
            <input type="hidden" name="toAirport" value="<%= request.getAttribute("toAirport") %>">
            <input type="hidden" name="departureDate" value="<%= request.getAttribute("departureDate") %>">
            <input type="hidden" name="tripType" value="<%= request.getAttribute("tripType") %>">
            <input type="hidden" name="returnDate" value="<%= request.getAttribute("returnDate") %>">
            <input type="hidden" name="maxPrice" value="<%= request.getParameter("maxPrice") %>">
            <input type="hidden" name="stops" value="<%= request.getParameter("stops") %>">
            <input type="hidden" name="airline" value="<%= request.getParameter("airline") %>">

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

    <!-- Filter Section -->
    <div class="filter-section">
        <h3>Filter Flights</h3>
        <form method="post" action="searchFlights">
            <input type="hidden" name="fromAirport" value="<%= request.getAttribute("fromAirport") %>">
            <input type="hidden" name="toAirport" value="<%= request.getAttribute("toAirport") %>">
            <input type="hidden" name="departureDate" value="<%= request.getAttribute("departureDate") %>">
            <input type="hidden" name="tripType" value="<%= request.getAttribute("tripType") %>">
            <input type="hidden" name="returnDate" value="<%= request.getAttribute("returnDate") %>">
            <input type="hidden" name="sortBy" value="<%= request.getParameter("sortBy") %>">

            Max Price: <input type="number" name="maxPrice" step="0.01"> 
            Stops: <input type="number" name="stops" min="0">
            Airline: <input type="text" name="airline">
            <input type="submit" value="Apply Filters">
        </form>
    </div>

    <h2>Departure Flights</h2>
    <%
        List<Map<String, String>> departureFlights = (List<Map<String, String>>) request.getAttribute("departureFlights");

        // Get filter values
        String maxPriceStr = request.getParameter("maxPrice");
        String stopsStr = request.getParameter("stops");
        String airlineFilter = request.getParameter("airline");

        // Apply Filters
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
            out.println("<p>No departure flights found.</p>");
        } else {
            for (Map<String, String> flight : departureFlights) {
    %>
        <div class="flight-card">
            <strong><%= flight.get("airline") %></strong> | 
            <%= flight.get("from_airport") %> ➔ <%= flight.get("to_airport") %><br>
            Date: <%= flight.get("departure_date") %> | 
            $<%= flight.get("price") %> | 
            Stops: <%= flight.get("stops") %> | 
            Duration: <%= flight.get("duration") %>
            <form action="bookFlight" method="post">
                <input type="hidden" name="flightId" value="<%= flight.get("flight_id") %>">
                <input type="submit" value="Book This Flight">
            </form>
        </div>
    <%
            }
        }

        String tripType = (String) request.getAttribute("tripType");
        if ("roundtrip".equals(tripType)) {
            List<Map<String, String>> returnFlights = (List<Map<String, String>>) request.getAttribute("returnFlights");

            if (returnFlights != null) {
    %>
        <h2>Return Flights</h2>
    <%
                if (returnFlights.isEmpty()) {
                    out.println("<p>No return flights found.</p>");
                } else {
                    for (Map<String, String> flight : returnFlights) {
    %>
        <div class="flight-card">
            <strong><%= flight.get("airline") %></strong> | 
            <%= flight.get("from_airport") %> ➔ <%= flight.get("to_airport") %><br>
            Date: <%= flight.get("departure_date") %> | 
            $<%= flight.get("price") %> | 
            Stops: <%= flight.get("stops") %> | 
            Duration: <%= flight.get("duration") %>
            <form action="bookFlight" method="post">
                <input type="hidden" name="flightId" value="<%= flight.get("flight_id") %>">
                <input type="submit" value="Book This Flight">
            </form>
        </div>
    <%
                    }
                }
            }
        }
    %>

    <br><a href="home.jsp">Back to Home</a>
</body>
</html>
