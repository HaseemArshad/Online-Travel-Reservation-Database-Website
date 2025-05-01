<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<html>
<head>
    <title>Flights by Airport</title>
    <style>
        table {
            border-collapse: collapse;
            margin: 10px 0;
            width: 80%;
        }
        th, td {
            padding: 6px 12px;
            border: 1px solid #000;
            text-align: center;
        }
        form {
            margin: 15px 0;
        }
        h3 {
            margin-top: 20px;
        }
    </style>
</head>
<body>

<h2>Lookup Flights by Airport Code</h2>

<form action="AirportFlightServlet" method="post">
    Airport Code: <input type="text" name="airport_code" maxlength="5" required>
    <input type="hidden" name="action" value="lookup">
    <input type="submit" value="Search">
</form>

<% String msg = (String) request.getAttribute("message");
   if (msg != null) { %>
   <p><b><%= msg %></b></p>
<% } %>

<% 
    List<Map<String, String>> departures = (List<Map<String, String>>) request.getAttribute("departingFlights");
    List<Map<String, String>> arrivals = (List<Map<String, String>>) request.getAttribute("arrivingFlights");

    if (departures != null && !departures.isEmpty()) { 
%>
    <h3>Departing Flights</h3>
    <table>
    <tr><th>ID</th><th>Airline</th><th>To</th><th>Date</th><th>Departure Time</th></tr>
    <% for (Map<String, String> f : departures) { %>
    <tr>
        <td><%= f.get("flight_id") %></td>
        <td><%= f.get("airline") %></td>
        <td><%= f.get("to_airport") %></td>
        <td><%= f.get("departure_date") %></td>
        <td><%= f.get("departure_time") %></td>
    </tr>
    <% } %>
    </table>
<% } %>

<% if (arrivals != null && !arrivals.isEmpty()) { %>
    <h3>Arriving Flights</h3>
    <table>
    <tr><th>ID</th><th>Airline</th><th>From</th><th>Date</th><th>Arrival Time</th></tr>
    <% for (Map<String, String> f : arrivals) { %>
    <tr>
        <td><%= f.get("flight_id") %></td>
        <td><%= f.get("airline") %></td>
        <td><%= f.get("from_airport") %></td>
        <td><%= f.get("departure_date") %></td>
        <td><%= f.get("arrival_time") %></td>
    </tr>
    <% } %>
    </table>
<% } %>

<br>
<form action="representativehome.jsp" method="get">
    <input type="submit" value="Back to Representative Dashboard">
</form>

</body>
</html>
