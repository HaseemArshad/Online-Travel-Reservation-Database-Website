<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Round‑Trip Flight Results</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <h2>Choose Your Round‑Trip Flights</h2>

  <!-- Sort form -->
  <form method="get" action="searchFlights">
    <!-- carry original search context -->
    <input type="hidden" name="tripType"      value="<%= request.getAttribute("tripType") %>">
    <input type="hidden" name="fromAirport"   value="<%= request.getParameter("fromAirport") %>">
    <input type="hidden" name="toAirport"     value="<%= request.getParameter("toAirport") %>">
    <input type="hidden" name="departureDate" value="<%= request.getAttribute("departureDate") %>">
    <input type="hidden" name="returnDate"    value="<%= request.getAttribute("returnDate") %>">
    <input type="hidden" name="flexibleDates" value="<%= request.getParameter("flexibleDates") %>">

    Sort by:
    <select name="sortBy">
      <option value="">--</option>
      <option value="price"          <%= "price".equals(request.getAttribute("sortBy"))          ? "selected" : "" %>>Price</option>
      <option value="departure_time" <%= "departure_time".equals(request.getAttribute("sortBy")) ? "selected" : "" %>>Depart Time</option>
      <option value="arrival_time"   <%= "arrival_time".equals(request.getAttribute("sortBy"))   ? "selected" : "" %>>Arrive Time</option>
      <option value="stops"          <%= "stops".equals(request.getAttribute("sortBy"))          ? "selected" : "" %>>Stops</option>
      <option value="duration"       <%= "duration".equals(request.getAttribute("sortBy"))       ? "selected" : "" %>>Duration</option>
    </select>

    <select name="sortOrder">
      <option value="asc"  <%= "asc".equals(request.getAttribute("sortOrder"))  ? "selected" : "" %>>Asc</option>
      <option value="desc" <%= "desc".equals(request.getAttribute("sortOrder")) ? "selected" : "" %>>Desc</option>
    </select>
    
    
  <label>
    <input type="checkbox" name="flexibleDates" value="true"
      <%= "true".equalsIgnoreCase(request.getParameter("flexibleDates")) ? "checked" : "" %> />
    Flexible Dates (±3 days)
  </label>
  <br><br>

    <button type="submit">Apply Sort</button>
  </form>
  <br/>

  <form action="bookFlight" method="post">
    <!-- Hidden fields to track booking -->
    <input type="hidden" name="departureDate" value="<%= request.getAttribute("departureDate") %>">
    <input type="hidden" name="returnDate"    value="<%= request.getAttribute("returnDate")    %>">
    <input type="hidden" name="tripType"      value="roundtrip">

    <!-- Ticket class selector -->
    <label>
      Ticket class:
      <select name="ticketClass">
        <option value="Economy">Economy</option>
        <option value="Business">Business (+ $100)</option>
        <option value="First">First (+ $200)</option>
      </select>
    </label>
    <br><br>

    <!-- Outbound Flights -->
    <h3>Outbound Flights (<%= request.getAttribute("departureDate") %>)</h3>
    <table border="1" cellpadding="5" cellspacing="0">
      <tr>
        <th>Select</th><th>Airline</th><th>From</th><th>To</th>
        <th>Depart Time</th><th>Arrive Time</th><th>Price</th><th>Stops</th>
      </tr>
      <%
        List<Map<String, String>> dep = (List<Map<String, String>>) request.getAttribute("departureFlights");
        for (Map<String, String> f : dep) {
      %>
      <tr>
        <td><input type="radio" name="flightId1" value="<%= f.get("flight_id") %>" required></td>
        <td><%= f.get("airline") %></td>
        <td><%= f.get("from_airport") %></td>
        <td><%= f.get("to_airport") %></td>
        <td><%= f.get("departure_time") %></td>
        <td><%= f.get("arrival_time") %></td>
        <td>$<%= f.get("price") %></td>
        <td><%= f.get("stops") %></td>
      </tr>
      <% } %>
    </table>

    <!-- Return Flights -->
    <h3>Return Flights (<%= request.getAttribute("returnDate") %>)</h3>
    <table border="1" cellpadding="5" cellspacing="0">
      <tr>
        <th>Select</th><th>Airline</th><th>From</th><th>To</th>
        <th>Depart Time</th><th>Arrive Time</th><th>Price</th><th>Stops</th>
      </tr>
      <%
        List<Map<String, String>> ret = (List<Map<String, String>>) request.getAttribute("returnFlights");
        for (Map<String, String> f : ret) {
      %>
      <tr>
        <td><input type="radio" name="flightId2" value="<%= f.get("flight_id") %>" required></td>
        <td><%= f.get("airline") %></td>
        <td><%= f.get("from_airport") %></td>
        <td><%= f.get("to_airport") %></td>
        <td><%= f.get("departure_time") %></td>
        <td><%= f.get("arrival_time") %></td>
        <td>$<%= f.get("price") %></td>
        <td><%= f.get("stops") %></td>
      </tr>
      <% } %>
    </table>

    <br>
    <button type="submit">Book Both Flights</button>
  </form>
</body>
</html>