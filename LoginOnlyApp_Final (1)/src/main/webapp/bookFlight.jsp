<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="java.io.PrintWriter" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String flightIdStr = request.getParameter("flightId");

    if (userId == null) {
        out.println("<h2>You must be logged in to book a flight.</h2>");
        out.println("<a href='login.jsp'>Login</a>");
    } else if (flightIdStr == null) {
        out.println("<h2>No flight selected for booking.</h2>");
        out.println("<a href='home.jsp'>Back to Home</a>");
    } else {
        int flightId = Integer.parseInt(flightIdStr);
        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            // ✅ Fetch capacity
            PreparedStatement capStmt = conn.prepareStatement(
                "SELECT capacity FROM flights WHERE flight_id = ?");
            capStmt.setInt(1, flightId);
            ResultSet capRs = capStmt.executeQuery();

            int capacity = 0;
            if (capRs.next()) {
                capacity = capRs.getInt("capacity");
            }
            capRs.close();
            capStmt.close();

            // ✅ Fetch number of bookings
            PreparedStatement bookStmt = conn.prepareStatement(
                "SELECT COUNT(*) AS booked FROM bookings WHERE flight_id = ?");
            bookStmt.setInt(1, flightId);
            ResultSet bookRs = bookStmt.executeQuery();

            int booked = 0;
            if (bookRs.next()) {
                booked = bookRs.getInt("booked");
            }
            bookRs.close();
            bookStmt.close();

            boolean canBook = (booked < capacity);

            if (canBook) {
                // ✅ Insert into bookings
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO bookings (user_id, flight_id) VALUES (?, ?)");
                ps.setInt(1, userId);
                ps.setInt(2, flightId);
                ps.executeUpdate();
                ps.close();

                // ✅ REMOVE user from waiting_list if they were there
                PreparedStatement deleteWaitlist = conn.prepareStatement(
                    "DELETE FROM waiting_list WHERE user_id = ? AND flight_id = ?");
                deleteWaitlist.setInt(1, userId);
                deleteWaitlist.setInt(2, flightId);
                deleteWaitlist.executeUpdate();
                deleteWaitlist.close();

                out.println("<h2>✅ Flight booked successfully!</h2>");
                out.println("<p>Redirecting you back to Home...</p>");
%>
                <script>
                    setTimeout(function() {
                        window.location.href = 'home.jsp';
                    }, 3000);
                </script>
<%
            } else {
                out.println("<h2>❌ Sorry, the flight is already full! You have been added to the waitlist.</h2>");
                out.println("<p><a href='home.jsp'>Back to Home</a></p>");
            }

            conn.close();
        } catch (Exception e) {
            out.println("<h2>Error booking flight. Please try again.</h2>");
            e.printStackTrace(new PrintWriter(out));
        }
    }
%>
