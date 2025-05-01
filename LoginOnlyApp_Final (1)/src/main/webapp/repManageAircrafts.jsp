<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<html>
<head><title>Manage Aircrafts</title></head>
<body>

<h2>Aircraft Management</h2>

<% String msg = (String) request.getAttribute("message");
   if (msg != null) { %>
   <p><b><%= msg %></b></p>
<% } %>

<table border="1">
<tr>
    <th>ID</th><th>Seat Capacity</th><th>Day of Operation</th><th>Actions</th>
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
        <!-- Edit Button -->
        <form action="AircraftServlet" method="post" style="display:inline;">
            <input type="hidden" name="action" value="edit_view">
            <input type="hidden" name="aircraft_id" value="<%= row[0] %>">
            <input type="hidden" name="seat_capacity" value="<%= row[1] %>">
            <input type="hidden" name="day_of_operation" value="<%= row[2] %>">
            <input type="submit" value="Edit">
        </form>

        <!-- Delete Button -->
        <form action="AircraftServlet" method="post" style="display:inline;" onsubmit="return confirm('Delete aircraft <%= row[0] %>?');">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="aircraft_id" value="<%= row[0] %>">
            <input type="submit" value="Delete">
        </form>
    </td>
</tr>
<% }} %>
</table>

<hr>

<h3>Add New Aircraft</h3>
<form action="AircraftServlet" method="post">
    <input type="hidden" name="action" value="add">
    Seat Capacity: <input type="number" name="seat_capacity" required><br>
    Day of Operation: <input type="text" name="day_of_operation" required><br>
    <input type="submit" value="Add Aircraft">
</form>

<% if ("true".equals(String.valueOf(request.getAttribute("edit")))) { %>
<hr>
<h3>Edit Aircraft</h3>
<form action="AircraftServlet" method="post">
    <input type="hidden" name="action" value="edit">
    Aircraft ID: <input type="text" name="aircraft_id" value="<%= request.getAttribute("aircraft_id") %>" readonly><br>
    Seat Capacity: <input type="number" name="seat_capacity" value="<%= request.getAttribute("seat_capacity") %>"><br>
    Day of Operation: <input type="text" name="day_of_operation" value="<%= request.getAttribute("day_of_operation") %>"><br>
    <input type="submit" value="Update Aircraft">
</form>
<% } %>

<br>
<form action="repEditHub.jsp" method="get">
    <input type="submit" value="Back to Edit Hub">
</form>

</body>
</html>
