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

  <form action="bookFlight" method="post">
    <!-- carry over search params -->
    <input type="hidden" name="departureDate" value="<%= request.getAttribute("departureDate") %>">
    <input type="hidden" name="returnDate"    value="<%= request.getAttribute("returnDate")    %>">
    <!-- tell servlet this is round‑trip -->
    <input type="hidden" name="tripType"      value="roundtrip">

    <!-- let user choose class -->
    <label>
      Ticket class:
      <select name="ticketClass" required>
        <option value="Economy">Economy</option>
        <option value="Business">Business</option>
        <option value="First">First</option>
      </select>
    </label>
    <br><br>

    <h3>Outbound Flights (<%= request.getAttribute("departureDate") %>)</h3>
    <table border="1" cellpadding="5" cellspacing="0">
      <tr>
        <th>Select</th><th>Airline</th><th>From</th><th>To</th>
        <th>Depart Time</th><th>Arrive Time</th><th>Price</th><th>Stops</th>
      </tr>
      <%
        List<Map<String,String>> dep = (List<Map<String,String>>)request.getAttribute("departureFlights");
        for (Map<String,String> f : dep) {
      %>
      <tr>
        <td><input type="radio" name="outboundFlightId" value="<%=f.get("flight_id")%>" required></td>
        <td><%=f.get("airline")%></td>
        <td><%=f.get("from_airport")%></td>
        <td><%=f.get("to_airport")%></td>
        <td><%=f.get("departure_time")%></td>
        <td><%=f.get("arrival_time")%></td>
        <td>$<%=f.get("price")%></td>
        <td><%=f.get("stops")%></td>
      </tr>
      <% } %>
    </table>

    <h3>Return Flights (<%= request.getAttribute("returnDate") %>)</h3>
    <table border="1" cellpadding="5" cellspacing="0">
      <tr>
        <th>Select</th><th>Airline</th><th>From</th><th>To</th>
        <th>Depart Time</th><th>Arrive Time</th><th>Price</th><th>Stops</th>
      </tr>
      <%
        List<Map<String,String>> ret = (List<Map<String,String>>)request.getAttribute("returnFlights");
        for (Map<String,String> f : ret) {
      %>
      <tr>
        <td><input type="radio" name="returnFlightId" value="<%=f.get("flight_id")%>" required></td>
        <td><%=f.get("airline")%></td>
        <td><%=f.get("from_airport")%></td>
        <td><%=f.get("to_airport")%></td>
        <td><%=f.get("departure_time")%></td>
        <td><%=f.get("arrival_time")%></td>
        <td>$<%=f.get("price")%></td>
        <td><%=f.get("stops")%></td>
      </tr>
      <% } %>
    </table>

    <br>
    <button type="submit">Book Both Flights</button>
  </form>
</body>
</html>
