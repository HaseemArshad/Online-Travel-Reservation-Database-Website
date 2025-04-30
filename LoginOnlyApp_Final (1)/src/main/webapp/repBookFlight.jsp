<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Book Flight for User</title>
</head>
<body>
<h2>Book Flight on Behalf of a User</h2>

<% String msg = (String) request.getAttribute("message");
   if (msg != null) { %>
    <p style="color:green; font-weight:bold;"><%= msg %></p>
<% } %>

<form action="RepBookFlightServlet" method="post">
    Customer Username: <input type="text" name="username" required><br><br>
    Flight ID: <input type="text" name="flightId" required><br><br>
    Seat Class:
    <select name="seatClass">
        <option value="Economy">Economy</option>
        <option value="Business">Business</option>
        <option value="First">First</option>
    </select><br><br>

    <input type="submit" value="Book Flight">
</form>

<form action="representativehome.jsp" method="get">
    <br>
    <input type="submit" value="Back to Dashboard">
</form>

</body>
</html>
