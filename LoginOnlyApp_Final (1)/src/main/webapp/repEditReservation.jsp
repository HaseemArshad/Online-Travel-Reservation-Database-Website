<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Edit Reservation</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h2>Edit a Customer's Flight Reservation</h2>

    <% String msg = (String) request.getAttribute("message");
       if (msg != null) { %>
        <p style="color: green; font-weight: bold;"><%= msg %></p>
    <% } %>

    <form action="RepEditReservationServlet" method="post">
        <label for="username">Username:</label><br>
        <input type="text" name="username" id="username" required><br><br>

        <label for="bookingId">Booking ID:</label><br>
        <input type="text" name="bookingId" id="bookingId" required><br><br>

        <label for="newFlightNumber">New Flight Number:</label><br> 
        <input type="text" name="newFlightNumber" id="newFlightNumber"><br><br>

        <label for="newClass">New Class:</label><br>
        <select name="newClass" id="newClass">
            <option value="">(No change)</option>
            <option value="Economy">Economy</option>
            <option value="Business">Business</option>
            <option value="First">First</option>
        </select><br><br>

        <input type="submit" value="Update Reservation">
    </form>

    <br>
    <form action="representativehome.jsp" method="get">
        <input type="submit" value="⬅ Back to Dashboard">
    </form>
</div>
</body>
</html>
