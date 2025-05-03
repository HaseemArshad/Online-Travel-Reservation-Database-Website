<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page session="true" %>

<%! 
    public String getOrdinalSuffix(int number) {
        if (number >= 11 && number <= 13) return "th";
        switch (number % 10) {
            case 1: return "st";
            case 2: return "nd";
            case 3: return "rd";
            default: return "th";
        }
    }

    public class FlightEntry {
        String flightNumber, airline;
        java.sql.Date departureDate;
        int ticketsSold;

        public FlightEntry(String flightNumber, String airline, java.sql.Date departureDate, int ticketsSold) {
            this.flightNumber = flightNumber;
            this.airline = airline;
            this.departureDate = departureDate;
            this.ticketsSold = ticketsSold;
        }
    }
%>

<%
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    PreparedStatement ps = con.prepareStatement(
        "SELECT f.flight_number, f.airline, f.departure_date, COUNT(b.booking_id) AS tickets_sold " +
        "FROM bookings b " +
        "JOIN flights f ON b.flight_id = f.flight_id " +
        "GROUP BY f.flight_number, f.airline, f.departure_date " +
        "ORDER BY tickets_sold DESC"
    );
    ResultSet rs = ps.executeQuery();

    List<FlightEntry> flights = new ArrayList<>();
    while (rs.next()) {
        flights.add(new FlightEntry(
            rs.getString("flight_number"),
            rs.getString("airline"),
            rs.getDate("departure_date"),
            rs.getInt("tickets_sold")
        ));
    }
    rs.close();
    con.close();

    // Group flights by ticket count
    Map<Integer, List<FlightEntry>> rankGroups = new LinkedHashMap<>();
    for (FlightEntry f : flights) {
        rankGroups.computeIfAbsent(f.ticketsSold, k -> new ArrayList<>()).add(f);
    }

    List<Integer> sortedCounts = new ArrayList<>(rankGroups.keySet());
    Collections.sort(sortedCounts, Collections.reverseOrder());
%>

<html>
<head>
    <title>Most Active Flights</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h1>Flights with Most Tickets Sold</h1>
    <table>
        <tr>
            <th>Rank</th>
            <th>Flight Number</th>
            <th>Airline</th>
            <th>Departure Date</th>
            <th>Tickets Sold</th>
        </tr>
<%
    int currentRank = 1;
    int maxRanks = 3;
    for (int tickets : sortedCounts) {
        if (currentRank > maxRanks) break;
        List<FlightEntry> group = rankGroups.get(tickets);
        for (FlightEntry f : group) {
%>
        <tr>
            <td><%= currentRank + getOrdinalSuffix(currentRank) %> place</td>
            <td><%= f.flightNumber %></td>
            <td><%= f.airline %></td>
            <td><%= f.departureDate %></td>
            <td><%= f.ticketsSold %></td>
        </tr>
<%
        }
        currentRank++;
    }
%>
    </table>
    <br>
    <a href="adminhome.jsp">Back to Admin Dashboard</a>
</div>
</body>
</html>
