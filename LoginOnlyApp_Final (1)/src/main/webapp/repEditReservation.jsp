<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Edit Reservation</title>
</head>
<body>
<h2>Edit a Customer's Flight Reservation</h2>

<% String msg = (String) request.getAttribute("message");
   if (msg != null) { %>
    <p style="color:green;"><%= msg %></p>
<% } %>

<form action="RepEditReservationServlet" method="post">
    Username: <input type="text" name="username" required><br><br>
    Booking ID: <input type="text" name="bookingId" required><br><br>
    New Flight ID: <input type="text" name="newFlightId"><br><br>
    New Class:
    <select name="newClass">
        <option value="">(No change)</option>
        <option value="Economy">Economy</option>
        <option value="Business">Business</option>
        <option value="First">First</option>
    </select><br><br>

    <input type="submit" value="Update Reservation">
</form>

<form action="representativehome.jsp" method="get">
    <input type="submit" value="⬅ Back to Dashboard">
</form>
</body>
</html>
