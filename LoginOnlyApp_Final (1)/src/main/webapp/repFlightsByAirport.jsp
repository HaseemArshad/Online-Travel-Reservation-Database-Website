<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<html>
<head>
    <title>Flights by Airport</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        table {
            border-collapse: collapse;
            margin: 15px 0;
            width: 100%;
        }
        th, td {
            padding: 8px 14px;
            border: 1px solid #ccc;
            text-align: center;
        }
        form {
            margin: 20px 0;
        }
        h3 {
            margin-top: 25px;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Lookup Flights by Airport Code</h2>

    <form action="AirportFlightServlet" method="post">
        <label for="airport_code">Airport Code:</label>
        <input type="text" name="airport_code" id="airport_code" maxlength="5" required>
        <input type="hidden" name="action" value="lookup">
        <input type="submit" value="Search">
    </form>

    <% String msg = (String) request.getAttribute("message");
       if (msg != null) { %>
        <p><strong><%= msg %></strong></p>
    <% } %>

    <%
        List<Map<String, String>> departures = (List<Map<String, String>>) request.getAttribute("departingFlights");
        List<Map<String, String>> arrivals = (List<Map<String, String>>) request.getAttribute("arrivingFlights");
    %>

    <% if (departures != null && !departures.isEmpty()) { %>
        <h3>Departing Flights</h3>
        <table>
            <tr>
                <th>Flight Number</th>
                <th>Airline</th>
                <th>To</th>
                <th>Departure Date</th>
                <th>Departure Time</th>
            </tr>
            <% for (Map<String, String> f : departures) { %>
            <tr>
                <td><%= f.get("flight_number") %></td>
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
            <tr>
                <th>Flight Number</th>
                <th>Airline</th>
                <th>From</th>
                <th>Departure Date</th>
                <th>Arrival Time</th>
            </tr>
            <% for (Map<String, String> f : arrivals) { %>
            <tr>
                <td><%= f.get("flight_number") %></td>
                <td><%= f.get("airline") %></td>
                <td><%= f.get("from_airport") %></td>
                <td><%= f.get("departure_date") %></td>
                <td><%= f.get("arrival_time") %></td>
            </tr>
            <% } %>
        </table>
    <% } %>

    <form action="representativehome.jsp" method="get">
        <input type="submit" value="⬅ Back to Representative Dashboard">
    </form>
</div>
</body>
</html>
