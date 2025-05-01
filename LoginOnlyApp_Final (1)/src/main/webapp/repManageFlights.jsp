<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <title>Manage Flights</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 15px;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ccc;
            text-align: center;
        }
        form {
            margin-top: 10px;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Flight Management</h2>

    <% String msg = (String) request.getAttribute("message");
       if (msg != null) { %>
        <p><strong><%= msg %></strong></p>
    <% } %>

    <table>
        <tr>
            <th>ID</th>
            <th>Airline</th>
            <th>From</th>
            <th>To</th>
            <th>Date</th>
            <th>Dep Time</th>
            <th>Arr Time</th>
            <th>Price</th>
            <th>Stops</th>
            <th>Capacity</th>
            <th>Actions</th>
        </tr>
    <%
        List<String[]> flightList = (List<String[]>) request.getAttribute("flightList");
        if (flightList != null) {
            for (String[] row : flightList) {
    %>
        <tr>
            <% for (int i = 0; i < row.length; i++) { %>
                <td><%= row[i] %></td>
            <% } %>
            <td>
                <form action="FlightServlet" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="edit_view">
                    <input type="hidden" name="flight_id" value="<%= row[0] %>">
                    <input type="hidden" name="airline" value="<%= row[1] %>">
                    <input type="hidden" name="from_airport" value="<%= row[2] %>">
                    <input type="hidden" name="to_airport" value="<%= row[3] %>">
                    <input type="hidden" name="departure_date" value="<%= row[4] %>">
                    <input type="hidden" name="departure_time" value="<%= row[5] %>">
                    <input type="hidden" name="arrival_time" value="<%= row[6] %>">
                    <input type="hidden" name="price" value="<%= row[7] %>">
                    <input type="hidden" name="stops" value="<%= row[8] %>">
                    <input type="hidden" name="capacity" value="<%= row[9] %>">
                    <input type="submit" value="Edit">
                </form>

                <form action="FlightServlet" method="post" style="display:inline;" 
                      onsubmit="return confirm('Are you sure you want to delete this flight?');">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="flight_id" value="<%= row[0] %>">
                    <input type="submit" value="Delete">
                </form>
            </td>
        </tr>
    <%
            }
        }
    %>
    </table>

    <hr>

    <h3>Add New Flight</h3>
    <form action="FlightServlet" method="post">
        <input type="hidden" name="action" value="add">

        Flight ID: <input type="text" name="flight_id" required><br><br>
        Airline: <input type="text" name="airline"><br><br>
        From Airport: <input type="text" name="from_airport"><br><br>
        To Airport: <input type="text" name="to_airport"><br><br>
        Departure Date: <input type="date" name="departure_date"><br><br>
        Departure Time: <input type="time" name="departure_time"><br><br>
        Arrival Time: <input type="time" name="arrival_time"><br><br>
        Price: <input type="number" step="0.01" name="price"><br><br>
        Stops: <input type="number" name="stops"><br><br>
        Capacity: <input type="number" name="capacity"><br><br>

        <input type="submit" value="Add Flight">
    </form>

    <% if ("true".equals(String.valueOf(request.getAttribute("edit")))) { %>
        <hr>
        <h3>Edit Flight</h3>
        <form action="FlightServlet" method="post">
            <input type="hidden" name="action" value="edit">

            Flight ID: <input type="text" name="flight_id" value="<%= request.getAttribute("flight_id") %>" readonly><br><br>
            Airline: <input type="text" name="airline" value="<%= request.getAttribute("airline") %>"><br><br>
            From Airport: <input type="text" name="from_airport" value="<%= request.getAttribute("from_airport") %>"><br><br>
            To Airport: <input type="text" name="to_airport" value="<%= request.getAttribute("to_airport") %>"><br><br>
            Departure Date: <input type="date" name="departure_date" value="<%= request.getAttribute("departure_date") %>"><br><br>
            Departure Time: <input type="time" name="departure_time" value="<%= request.getAttribute("departure_time") %>"><br><br>
            Arrival Time: <input type="time" name="arrival_time" value="<%= request.getAttribute("arrival_time") %>"><br><br>
            Price: <input type="number" step="0.01" name="price" value="<%= request.getAttribute("price") %>"><br><br>
            Stops: <input type="number" name="stops" value="<%= request.getAttribute("stops") %>"><br><br>
            Capacity: <input type="number" name="capacity" value="<%= request.getAttribute("capacity") %>"><br><br>

            <input type="submit" value="Update Flight">
        </form>
    <% } %>

    <br>
    <form action="repEditHub.jsp" method="get">
        <input type="submit" value="⬅ Back to Edit Hub">
    </form>
</div>
</body>
</html>
