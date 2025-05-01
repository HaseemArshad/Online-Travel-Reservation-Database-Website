<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
    <title>Search Flights</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        form {
            margin-top: 20px;
            max-width: 400px;
        }
        input[type="text"], input[type="submit"] {
            width: 100%;
            padding: 8px;
            margin: 8px 0;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Search for Flights</h2>
    <form action="searchFlights" method="post">
        <label>From Airport Code:</label>
        <input type="text" name="fromAirport" required>

        <label>To Airport Code:</label>
        <input type="text" name="toAirport" required>

        <label>Departure Date (YYYY-MM-DD):</label>
        <input type="text" name="departureDate" required>

        <input type="submit" value="Search Flights">
    </form>
</div>
</body>
</html>
