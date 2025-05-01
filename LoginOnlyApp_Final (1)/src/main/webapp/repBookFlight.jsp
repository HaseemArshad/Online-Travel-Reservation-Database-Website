<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Book Flight for User</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h2>Book Flight on Behalf of a User</h2>

    <% String msg = (String) request.getAttribute("message");
       if (msg != null) { %>
        <p style="color: green; font-weight: bold;"><%= msg %></p>
    <% } %>

    <form action="RepBookFlightServlet" method="post">
        <label for="username">Customer Username:</label><br>
        <input type="text" id="username" name="username" required><br><br>

        <label for="flightId">Flight ID:</label><br>
        <input type="text" id="flightId" name="flightId" required><br><br>

        <label for="seatClass">Seat Class:</label><br>
        <select id="seatClass" name="seatClass">
            <option value="Economy">Economy</option>
            <option value="Business">Business</option>
            <option value="First">First</option>
        </select><br><br>

        <input type="submit" value="Book Flight">
    </form>

    <br>
    <form action="representativehome.jsp" method="get">
        <input type="submit" value="Back to Dashboard">
    </form>
</div>
</body>
</html>
