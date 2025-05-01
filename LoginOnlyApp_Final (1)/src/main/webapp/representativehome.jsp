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

<form action="QuestionServlet" method="post">
    <input type="hidden" name="action" value="view">
    <input type="submit" value="Reply to User Questions">
</form>

<form action="repViewWaitlist.jsp" method="get">
    <input type="submit" value="View Flight Waiting List">
</form>

<form action="repFlightsByAirport.jsp" method="get">
    <input type="submit" value="View Flights by Airport">
</form>

<form action="logout.jsp" method="post" style="display:inline;">
    <input type="submit" value="Sign Out">
</form>


</body>
</html>