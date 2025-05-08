<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map" %>
<%
    // pulled from request attributes by servlet, use f1/f2 to avoid collision with implicit "out"
    Map<String,String> f1 = (Map<String,String>)request.getAttribute("flight1");
    Map<String,String> f2 = (Map<String,String>)request.getAttribute("flight2");
    String ticketClass   = (String)request.getAttribute("ticketClass");
    double price1        = Double.parseDouble(f1.get("price"));
    double price2        = Double.parseDouble(f2.get("price"));
    double classUpcharge = "Business".equalsIgnoreCase(ticketClass) ? 100 : "First".equalsIgnoreCase(ticketClass) ? 200 : 0;
    double total         = price1 + price2 + 2 * classUpcharge;
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Confirm Your Booking</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <h2>Review & Confirm</h2>

  <h3>Outbound</h3>
  Airline: <%= f1.get("airline") %><br>
  From: <%= f1.get("from_airport") %> → <%= f1.get("to_airport") %><br>
  Departs: <%= f1.get("departure_date") %> @ <%= f1.get("departure_time") %><br>
  Arrives: <%= f1.get("arrival_date") %> @ <%= f1.get("arrival_time") %><br>
  Price: $<%= f1.get("price") %><br>

  <h3>Return</h3>
  Airline: <%= f2.get("airline") %><br>
  From: <%= f2.get("from_airport") %> → <%= f2.get("to_airport") %><br>
  Departs: <%= f2.get("departure_date") %> @ <%= f2.get("departure_time") %><br>
  Arrives: <%= f2.get("arrival_date") %> @ <%= f2.get("arrival_time") %><br>
  Price: $<%= f2.get("price") %><br>

  <h3>Class: <%= ticketClass %> (up‑charge: $<%= classUpcharge %> per leg)</h3>
  <h2>Total: $<%= String.format("%.2f", total) %></h2>

  <form action="bookFlight" method="post">
    <input type="hidden" name="flightId1"   value="<%= f1.get("flight_id") %>">
    <input type="hidden" name="flightId2"   value="<%= f2.get("flight_id") %>">
    <input type="hidden" name="ticketClass" value="<%= ticketClass %>">
    <input type="hidden" name="tripType"    value="roundtrip">
    <input type="hidden" name="confirmed"   value="true">
    <button type="submit">Confirm &amp; Pay</button>
  </form>
</body>
</html>