<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<html>
<head><title>Manage Aircrafts</title></head>
<body>
<h2>Manage Aircrafts</h2>

<% String msg = (String) request.getAttribute("message");
   if (msg != null) { %>
   <p><b><%= msg %></b></p>
<% } %>

<table border="1">
    <tr><th>ID</th><th>Model</th><th>Capacity</th><th>Actions</th></tr>
<%
    List<String[]> aircraftList = (List<String[]>) request.getAttribute("aircraftList");
    if (aircraftList != null) {
        for (String[] row : aircraftList) {
%>
    <tr>
        <td><%= row[0] %></td><td><%= row[1] %></td><td><%= row[2] %></td>
        <td>
            <form action="AircraftServlet" method="post" style="display:inline;">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="aircraft_id" value="<%= row[0] %>">
                <input type="submit" value="Delete">
            </form>
        </td>
    </tr>
<%  }} %>
</table>

<hr>
<h3>Add / Edit Aircraft</h3>
<form action="AircraftServlet" method="post">
    <input type="hidden" name="action" value="add_or_edit">
    ID: <input type="text" name="aircraft_id" required><br>
    Model: <input type="text" name="model"><br>
    Capacity: <input type="number" name="capacity"><br>
    <input type="submit" value="Submit">
</form>

<br>
<form action="repEditHub.jsp" method="get">
    <input type="submit" value="⬅ Back to Edit Hub">
</form>
</body>
</html>
