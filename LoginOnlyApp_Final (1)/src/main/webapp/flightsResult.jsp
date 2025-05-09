<%@ page import="java.util.*" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
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
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        label {
            display: block;
            margin-top: 8px;
        }
        select, input[type="text"], input[type="number"], input[type="submit"] {
            padding: 8px;
            margin-top: 4px;
            width: 100%;
        }
    </style>
</head>
<body>
<div class="container">

    <!-- Sort Section -->
    <div class="sort-section">
        <h3>Sort Flights</h3>
        <form method="get" action="searchFlights">
            <input type="hidden" name="fromAirport" value="<%= request.getAttribute("fromAirport") %>">
            <input type="hidden" name="toAirport" value="<%= request.getAttribute("toAirport") %>">
            <input type="hidden" name="departureDate" value="<%= request.getAttribute("departureDate") %>">
            <input type="hidden" name="tripType" value="<%= request.getAttribute("tripType") %>">
            <input type="hidden" name="returnDate" value="<%= request.getAttribute("returnDate") %>">

            <label for="sortBy">Sort by:</label>
            <select name="sortBy" id="sortBy">
                <option value="price">Price</option>
                <option value="departure_time">Take-off Time</option>
                <option value="arrival_time">Landing Time</option>
                <option value="duration">Duration</option>
                <option value="stops">Number of Stops</option>
            </select>

            <label>
                <input type="checkbox" name="flexibleDates" value="true"
                    <%= "true".equals(request.getParameter("flexibleDates")) ? "checked" : "" %>>
                Include +/- 2 days (Flexible Dates)
            </label>

            <input type="submit" value="Sort">
        </form>
    </div>

    <!-- Filter Section -->
    <div class="filter-section">
        <h3>Filter Flights</h3>
        <form method="get" action="searchFlights">
            <input type="hidden" name="fromAirport" value="<%= request.getAttribute("fromAirport") %>">
            <input type="hidden" name="toAirport" value="<%= request.getAttribute("toAirport") %>">
            <input type="hidden" name="departureDate" value="<%= request.getAttribute("departureDate") %>">
            <input type="hidden" name="tripType" value="<%= request.getAttribute("tripType") %>">
            <input type="hidden" name="returnDate" value="<%= request.getAttribute("returnDate") %>">
            <input type="hidden" name="sortBy" value="<%= request.getParameter("sortBy") != null ? request.getParameter("sortBy") : "" %>">
            <input type="hidden" name="flexibleDates" value="<%= request.getParameter("flexibleDates") != null ? request.getParameter("flexibleDates") : "" %>">

            <label for="maxPrice">Max Price:</label>
            <input type="number" name="maxPrice" step="0.01" id="maxPrice">

            <label for="stops">Stops:</label>
            <input type="number" name="stops" min="0" id="stops">

            <label for="airline">Airline:</label>
            <input type="text" name="airline" id="airline">

            <input type="submit" value="Apply Filters">
        </form>
    </div>

    <!-- Flight Results -->
    <h2>Departure Flights</h2>
    <%
        List<Map<String, String>> departureFlights = (List<Map<String, String>>) request.getAttribute("departureFlights");

        String maxPriceStr = request.getParameter("maxPrice");
        String stopsStr = request.getParameter("stops");
        String airlineFilter = request.getParameter("airline");

        if (departureFlights != null) {
            for (Map<String, String> flight : departureFlights) {
                try {
                    String depTime = flight.get("departure_time");
                    String arrTime = flight.get("arrival_time");
                    if (depTime != null && arrTime != null) {
                        LocalTime dep = LocalTime.parse(depTime);
                        LocalTime arr = LocalTime.parse(arrTime);
                        Duration dur = Duration.between(dep, arr);
                        if (dur.isNegative()) dur = dur.plusHours(24);
                        flight.put("duration", String.format("%d:%02d", dur.toHours(), dur.toMinutesPart()));
                    }
                } catch (Exception e) {
                    flight.put("duration", "N/A");
                }
            }
        }

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

        if (departureFlights == null || departureFlights.isEmpty()) {
    %>
        <p>No departure flights found.</p>
    <%
        } else {
            for (Map<String, String> flight : departureFlights) {
    %>
        <div class="flight-card">
			<strong><%= flight.get("airline") %> - <%= flight.get("flight_number") %></strong>
            <%= flight.get("from_airport") %> -> <%= flight.get("to_airport") %><br>
            Departure: <%= flight.get("departure_date") %> at <%= flight.get("departure_time") %><br>
            Arrival: <%= flight.get("arrival_time") %><br>
            Price: $<%= flight.get("price") %> |
            Stops: <%= flight.get("stops") %> |
            Duration: <%= flight.get("duration") %>

            <form action="bookFlight.jsp" method="get">
                <input type="hidden" name="flightId" value="<%= flight.get("flight_id") %>">
                <label for="ticketClass">Seat Class:</label>
                <select name="ticketClass" required>
                    <option value="Economy">Economy</option>
                    <option value="Business">Business (+$100)</option>
                    <option value="First">First (+$200)</option>
                </select><br><br>
                <input type="submit" value="Book This Flight">
            </form>
        </div>
    <%
            }
        }
    %>

    <br>
    <a href="home.jsp">Back to Home</a>
</div>
</body>
</html>