<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Book Flight for User</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f3f3f3;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            padding: 25px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
        }
        label {
            font-weight: bold;
        }
        input[type="text"], select {
            width: 100%;
            padding: 8px;
            margin-top: 6px;
            margin-bottom: 16px;
            box-sizing: border-box;
        }
        input[type="submit"] {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #45a049;
        }
        .message {
            padding: 10px;
            font-weight: bold;
            text-align: center;
            margin-bottom: 15px;
        }
        .success {
            color: green;
        }
        .error {
            color: red;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Book Flight on Behalf of a User</h2>

    <%
        String msg = (String) request.getAttribute("message");
        if (msg != null) {
            boolean isSuccess = msg.startsWith("✅") || msg.startsWith("⚠️");
    %>
        <p class="message <%= isSuccess ? "success" : "error" %>"><%= msg %></p>
    <% } %>

    <form action="RepBookFlightServlet" method="post">
        <label for="username">Customer Username:</label>
        <input type="text" id="username" name="username" required>

        <label for="flightNumber">Flight Number:</label>
        <input type="text" id="flightNumber" name="flightNumber" required>

        <label for="seatClass">Seat Class:</label>
        <select id="seatClass" name="seatClass">
            <option value="Economy">Economy</option>
            <option value="Business">Business</option>
            <option value="First">First</option>
        </select>

        <input type="submit" value="Book Flight">
    </form>

    <br>
    <form action="representativehome.jsp" method="get">
        <input type="submit" value="Back to Dashboard">
    </form>
</div>
</body>
</html>
