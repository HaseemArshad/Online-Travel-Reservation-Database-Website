<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Edit Flight-Related Info</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h2>Flight Management Options</h2>

    <ul>
        <li><a href="repManageAirports.jsp">Manage Airports</a></li>
        <li><a href="repManageAircrafts.jsp">Manage Aircrafts</a></li>
        <li><a href="repManageFlights.jsp">Manage Flights</a></li>
    </ul>

    <br>
    <form action="representativehome.jsp" method="get">
        <input type="submit" value="Back to Dashboard">
    </form>
</div>
</body>
</html>
