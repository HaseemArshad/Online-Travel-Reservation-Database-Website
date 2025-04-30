<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

<h2>Customer Representative Dashboard</h2>

<form action="repBookFlight.jsp" method="get">
    <input type="submit" value="Make Reservation for a User">
</form>

<form action="repEditReservation.jsp" method="get">
    <input type="submit" value="Edit Customer Reservation">
</form>

<form action="repEditHub.jsp" method="get">
    <input type="submit" value="Edit Flight-Related Info">
</form>

<form action="logout.jsp" method="post" style="display:inline;">
    <input type="submit" value="Sign Out">
</form>


</body>
</html>