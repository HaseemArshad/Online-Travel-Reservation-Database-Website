<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <title>Manage Airports</title>
</head>
<body>
<h2>Airport Management</h2>

<% String msg = (String) request.getAttribute("message");
   if (msg != null) { %>
   <p><b><%= msg %></b></p>
<% } %>

<!-- Airport Table -->
<table border="1">
<tr>
    <th>Code</th><th>Name</th><th>City</th><th>Country</th><th>Actions</th>
</tr>
<%
    List<String[]> airportList = (List<String[]>) request.getAttribute("airportList");
    if (airportList != null) {
        for (String[] row : airportList) {
%>
<tr>
    <% for (String col : row) { %>
        <td><%= col %></td>
    <% } %>
	<td>
	    <!-- Edit Button -->
	    <form action="AirportServlet" method="post" style="display:inline;">
	        <input type="hidden" name="action" value="edit_view">
	        <input type="hidden" name="airport_code" value="<%= row[0] %>">
	        <input type="hidden" name="airport_name" value="<%= row[1] %>">
	        <input type="hidden" name="city" value="<%= row[2] %>">
	        <input type="hidden" name="country" value="<%= row[3] %>">
	        <input type="submit" value="Edit">
	    </form>
	
	    <!-- Delete Button -->
	    <form action="AirportServlet" method="post" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this airport?');">
	        <input type="hidden" name="action" value="delete">
	        <input type="hidden" name="airport_code" value="<%= row[0] %>">
	        <input type="submit" value="Delete">
	    </form>
	</td>
</tr>
<% }} %>
</table>

<hr>

<!-- Add Airport Form -->
<h3>Add New Airport</h3>
<form action="AirportServlet" method="post">
    <input type="hidden" name="action" value="add">
    Airport Code: <input type="text" name="airport_code" required><br>
    Name: <input type="text" name="airport_name"><br>
    City: <input type="text" name="city"><br>
    Country: <input type="text" name="country"><br>
    <input type="submit" value="Add Airport">
</form>

<% if ("true".equals(String.valueOf(request.getAttribute("edit")))) { %>
<hr>
<h3>Edit Airport</h3>
<form action="AirportServlet" method="post">
    <input type="hidden" name="action" value="edit">
    Airport Code: <input type="text" name="airport_code" value="<%= request.getAttribute("airport_code") %>" readonly><br>
    Name: <input type="text" name="airport_name" value="<%= request.getAttribute("airport_name") %>"><br>
    City: <input type="text" name="city" value="<%= request.getAttribute("city") %>"><br>
    Country: <input type="text" name="country" value="<%= request.getAttribute("country") %>"><br>
    <input type="submit" value="Update Airport">
</form>
<% } %>

<br>
<form action="repEditHub.jsp" method="get">
    <input type="submit" value="⬅ Back to Edit Hub">
</form>
</body>
</html>
