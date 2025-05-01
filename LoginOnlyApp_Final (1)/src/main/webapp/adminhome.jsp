<%@ page session="true" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<html>
<head>
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h1>Welcome to Admin View!</h1>

    <ul>
        <li><a href="adminmanage.jsp">Manage Users</a></li>
        <li><a href="salesreport.jsp">Monthly Sales Report</a></li>
        <li><a href="reservationlist.jsp">Reservation List</a></li>
        <li><a href="revenuelist.jsp">Revenue List</a></li>
        <li><a href="customermostrevenue.jsp">Highest Spending Customer Currently</a></li>
        <li><a href="mostticketssold.jsp">Highest Selling Flight(s)</a></li>
    </ul>

    <form action="logout.jsp" method="post">
        <input type="submit" value="Log Out" />
    </form>
</div>
</body>
</html>
