<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <title>Manage Aircrafts</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        table {
            border-collapse: collapse;
            margin-top: 15px;
            width: 100%;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ccc;
            text-align: center;
        }
        h3 {
            margin-top: 30px;
        }
        form {
            margin-top: 10px;
        }
    </style>
</head>
<body>
<div class="container">

    <h2>Aircraft Management</h2>

    <% String msg = (String) request.getAttribute("message");
       if (msg != null) { %>
        <p><strong><%= msg %></strong></p>
    <% } %>

    <table>
        <tr>
            <th>ID</th>
            <th>Seat Capacity</th>
            <th>Day of Operation</th>
            <th>Actions</th>
        </tr>
    <%
        List<String[]> aircraftList = (List<String[]>) request.getAttribute("aircraftList");
        if (aircraftList != null) {
            for (String[] row : aircraftList) {
    %>
        <tr>
            <td><%= row[0] %></td>
            <td><%= row[1] %></td>
            <td><%= row[2] %></td>
            <td>
                <form action="AircraftServlet" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="edit_view">
                    <input type="hidden" name="aircraft_id" value="<%= row[0] %>">
                    <input type="hidden" name="seat_capacity" value="<%= row[1] %>">
                    <input type="hidden" name="day_of_operation" value="<%= row[2] %>">
                    <input type="submit" value="Edit">
                </form>

                <form action="AircraftServlet" method="post" style="display:inline;" 
                      onsubmit="return confirm('Delete aircraft <%= row[0] %>?');">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="aircraft_id" value="<%= row[0] %>">
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

    <h3>Add New Aircraft</h3>
    <form action="AircraftServlet" method="post">
        <input type="hidden" name="action" value="add">
        <label>Seat Capacity:</label>
        <input type="number" name="seat_capacity" required><br><br>

        <label>Day of Operation:</label>
        <input type="text" name="day_of_operation" required><br><br>

        <input type="submit" value="Add Aircraft">
    </form>

    <% if ("true".equals(String.valueOf(request.getAttribute("edit")))) { %>
    <hr>
    <h3>Edit Aircraft</h3>
    <form action="AircraftServlet" method="post">
        <input type="hidden" name="action" value="edit">
        <label>Aircraft ID:</label>
        <input type="text" name="aircraft_id" value="<%= request.getAttribute("aircraft_id") %>" readonly><br><br>

        <label>Seat Capacity:</label>
        <input type="number" name="seat_capacity" value="<%= request.getAttribute("seat_capacity") %>"><br><br>

        <label>Day of Operation:</label>
        <input type="text" name="day_of_operation" value="<%= request.getAttribute("day_of_operation") %>"><br><br>

        <input type="submit" value="Update Aircraft">
    </form>
    <% } %>

    <br>
    <form action="repEditHub.jsp" method="get">
        <input type="submit" value="⬅ Back to Edit Hub">
    </form>
</div>
</body>
</html>
