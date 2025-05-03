<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
    <title>Search Flights</title>
</head>
<body>
    <h2>Search for Flights</h2>
    <form action="searchFlights" method="post">
        From Airport Code: <input type="text" name="fromAirport" required><br><br>
        To Airport Code: <input type="text" name="toAirport" required><br><br>
        Departure Date (YYYY-MM-DD): <input type="text" name="departureDate" required><br><br>
        <input type="submit" value="Search Flights">
    </form>
</body>
</html>
