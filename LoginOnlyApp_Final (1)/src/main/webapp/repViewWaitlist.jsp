<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<html>
<head>
    <title>Flight Waiting List</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        table {
            border-collapse: collapse;
            margin-top: 15px;
            width: 100%;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ccc;
            text-align: center;
        }
        form {
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Flight Waiting List Lookup</h2>

    <form action="WaitlistServlet" method="post">
        <label for="flight_number">Enter Flight Number:</label>
        <input type="text" name="flight_number" id="flight_number" required>
        <input type="hidden" name="action" value="lookup">
        <input type="submit" value="Search">
    </form>

    <% String msg = (String) request.getAttribute("message");
       if (msg != null) { %>
        <p><strong><%= msg %></strong></p>
    <% } %>

    <%
        List<Map<String, String>> waitlist = (List<Map<String, String>>) request.getAttribute("waitlist");
        if (waitlist != null && !waitlist.isEmpty()) {
    %>
        <h3>Passengers on Waiting List for Flight <%= request.getAttribute("flight_number") %></h3>
        <table>
            <tr>
                <th>User ID</th>
                <th>Username</th>
                <th>First Name</th>
                <th>Last Name</th>
                <th>Time Added</th>
            </tr>
            <% for (Map<String, String> row : waitlist) { %>
            <tr>
                <td><%= row.get("user_id") %></td>
                <td><%= row.get("username") %></td>
                <td><%= row.get("first_name") %></td>
                <td><%= row.get("last_name") %></td>
                <td><%= row.get("added_time") %></td>
            </tr>
            <% } %>
        </table>
    <% } %>

    <br>
    <form action="representativehome.jsp" method="get">
        <input type="submit" value="⬅ Back to Representative Dashboard">
    </form>
</div>
</body>
</html>
