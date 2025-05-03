<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<html>
<head>
    <title>Confirm Booking</title>
    <script>
        let countdown = 300;
        function startTimer() {
            const timerDisplay = document.getElementById("timer");
            const interval = setInterval(() => {
                let minutes = Math.floor(countdown / 60);
                let seconds = countdown % 60;
                timerDisplay.textContent = `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
                if (--countdown < 0) {
                    clearInterval(interval);
                    document.getElementById("expired").style.display = "block";
                    document.getElementById("bookingForm").style.display = "none";
                }
            }, 1000);
        }
        window.onload = startTimer;
    </script>
</head>
<body>

<%
    String flightId = request.getParameter("flightId");
    String ticketClass = request.getParameter("ticketClass");

    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");

    if (flightId == null) {
%>
    <p style="color:red;">No flight selected. <a href="home.jsp">Return to home</a></p>
<%
    } else {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();
        PreparedStatement ps = con.prepareStatement("SELECT * FROM flights WHERE flight_id = ?");
        ps.setInt(1, Integer.parseInt(flightId));
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            String airline = rs.getString("airline");
            String from = rs.getString("from_airport");
            String to = rs.getString("to_airport");
            String departure = rs.getString("departure_time");
            String arrival = rs.getString("arrival_time");
            String date = rs.getString("departure_date");
            double basePrice = rs.getDouble("price");

            double adjustment = 0.0;
            if ("Business".equals(ticketClass)) {
                adjustment = 100.0;
            } else if ("First".equals(ticketClass)) {
                adjustment = 200.0;
            }

            double price = basePrice + adjustment;
            double fee = price * 0.10;
            double total = price + fee;

            DecimalFormat df = new DecimalFormat("0.00");
%>

    <h3>Flight Summary</h3>
    <p><strong>Airline:</strong> <%= airline %></p>
    <p><strong>From:</strong> <%= from %></p>
    <p><strong>To:</strong> <%= to %></p>
    <p><strong>Departure:</strong> <%= date %> at <%= departure %></p>
    <p><strong>Arrival:</strong> <%= arrival %></p>

<% if (ticketClass != null) { %>
    <h3>Payment Summary</h3>
    <p>Base Price: $<%= df.format(basePrice) %></p>
    <p>Class Fee: $<%= df.format(adjustment) %></p>
    <p>Booking Fee (10%): $<%= df.format(fee) %></p>
    <p><strong>Total: $<%= df.format(total) %></strong></p>

    <div id="expired" style="color:red; display:none; font-weight:bold;">
        Reservation expired. Please start again.
    </div>

    <div id="bookingForm">
        <form action="bookFlight" method="post">
            <input type="hidden" name="flightId" value="<%= flightId %>">
            <input type="hidden" name="ticketClass" value="<%= ticketClass %>">
            <input type="hidden" name="price" value="<%= df.format(total) %>">
            <input type="hidden" name="firstName" value="<%= firstName %>">
            <input type="hidden" name="lastName" value="<%= lastName %>">
            <input type="submit" value="Confirm and Pay">
        </form>
    </div>
<% } %>

<%
        } else {
%>
    <p style="color:red;">Flight not found.</p>
<%
        }
        rs.close();
        ps.close();
        con.close();
    }
%>

</body>
</html>
