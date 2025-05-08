package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;                // brings in java.sql.Date, Time, etc.
import java.util.*;               // brings in List, Map, etc.
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class BookFlightServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId       = (Integer) session.getAttribute("userId");
        String customerFirst = (String)  session.getAttribute("firstName");
        String customerLast  = (String)  session.getAttribute("lastName");
        String ticketClass   = request.getParameter("ticketClass");
        String tripType      = request.getParameter("tripType");
        String confirmed     = request.getParameter("confirmed");

        Set<String> flightIdSet = new LinkedHashSet<>();
        if (request.getParameter("flightId1") != null) flightIdSet.add(request.getParameter("flightId1"));
        if (request.getParameter("flightId2") != null) flightIdSet.add(request.getParameter("flightId2"));

        // First pass for round‑trip confirmation
        if ("roundtrip".equalsIgnoreCase(tripType) && confirmed == null) {
            Map<String,String> flight1 = null, flight2 = null;
            try (Connection conn = new ApplicationDB().getConnection()) {
                Iterator<String> it = flightIdSet.iterator();
                if (it.hasNext()) flight1 = fetchFlightMap(conn, Integer.parseInt(it.next()));
                if (it.hasNext()) flight2 = fetchFlightMap(conn, Integer.parseInt(it.next()));
            } catch (Exception e) {
                throw new ServletException(e);
            }
            request.setAttribute("flight1", flight1);
            request.setAttribute("flight2", flight2);
            request.setAttribute("ticketClass", ticketClass);
            request.setAttribute("confirmed", "yes");
            RequestDispatcher rd = request.getRequestDispatcher("confirmRoundTrip.jsp");
            rd.forward(request, response);
            return;
        }

        // Actual booking
        StringBuilder messageBuilder = new StringBuilder();
        try (Connection conn = new ApplicationDB().getConnection()) {

            Integer bookingGroupId = null;
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

            for (String fid : flightIdSet) {
                int flightId = Integer.parseInt(fid);

                // load flight
                PreparedStatement flightStmt = conn.prepareStatement(
                    "SELECT * FROM flights WHERE flight_id = ?");
                flightStmt.setInt(1, flightId);
                ResultSet rsFlight = flightStmt.executeQuery();
                if (!rsFlight.next()) { flightStmt.close(); continue; }

                String flightNumber = rsFlight.getString("flight_number");
                String airlineCode  = rsFlight.getString("airline");
                java.sql.Date depDate  = rsFlight.getDate("departure_date");
                Time           depTime  = rsFlight.getTime("departure_time");
                java.sql.Date arrDate  = rsFlight.getDate("arrival_date");
                Time           arrTime  = rsFlight.getTime("arrival_time");
                int    capacity     = rsFlight.getInt("capacity");
                double basePrice    = rsFlight.getDouble("price");
                rsFlight.close();
                flightStmt.close();

                // price
                double adjustment = "Business".equalsIgnoreCase(ticketClass)?100
                                  : "First".equalsIgnoreCase(ticketClass)?200
                                  : 0;
                double totalFare  = basePrice + adjustment;
                double bookingFee = totalFare * 0.10;

                // capacity check
                PreparedStatement chk = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM bookings WHERE flight_id = ?");
                chk.setInt(1, flightId);
                ResultSet rsChk = chk.executeQuery();
                rsChk.next();
                int bookedSeats = rsChk.getInt("cnt");
                rsChk.close();
                chk.close();

                if (bookedSeats >= capacity) {
                    PreparedStatement w = conn.prepareStatement(
                        "INSERT INTO waiting_list(user_id, flight_id) VALUES(?,?)");
                    w.setInt(1, userId);
                    w.setInt(2, flightId);
                    w.executeUpdate();
                    w.close();
                    messageBuilder.append("⚠️ Flight ")
                                  .append(flightNumber)
                                  .append(" full—added to waitlist.<br>");
                    continue;
                }

                // insert booking
                PreparedStatement b = conn.prepareStatement(
                    "INSERT INTO bookings(user_id,flight_id,ticket_class,booking_group_id) VALUES(?,?,?,?)",
                    Statement.RETURN_GENERATED_KEYS);
                b.setInt(1, userId);
                b.setInt(2, flightId);
                b.setString(3, ticketClass);
                if (bookingGroupId == null) b.setNull(4, Types.INTEGER);
                else                        b.setInt(4, bookingGroupId);
                b.executeUpdate();

                ResultSet gk = b.getGeneratedKeys();
                if (gk.next() && bookingGroupId == null) {
                    bookingGroupId = gk.getInt(1);
                    PreparedStatement u = conn.prepareStatement(
                        "UPDATE bookings SET booking_group_id=? WHERE booking_id=?");
                    u.setInt(1, bookingGroupId);
                    u.setInt(2, bookingGroupId);
                    u.executeUpdate();
                    u.close();
                }
                gk.close();
                b.close();

                // assign seat
                PreparedStatement s = conn.prepareStatement(
                    "SELECT COUNT(*) AS sc FROM ticket WHERE flight_number=? AND airline_code=?");
                s.setString(1, flightNumber);
                s.setString(2, airlineCode);
                ResultSet rsS = s.executeQuery();
                rsS.next();
                String seatNumber = "Seat " + (rsS.getInt("sc")+1);
                rsS.close();
                s.close();

                // insert ticket
                PreparedStatement t = conn.prepareStatement(
                    "INSERT INTO ticket(user_id,purchase_date,flight_number,airline_code,"
                  + "departure_date,departure_time,arrival_date,arrival_time,seat_number,"
                  + "customer_first_name,customer_last_name,total_fare,booking_fee,class,booking_group_id)"
                  + "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
                t.setInt(1, userId);
                t.setDate(2, today);
                t.setString(3, flightNumber);
                t.setString(4, airlineCode);
                t.setDate(5, depDate);
                t.setTime(6, depTime);
                t.setDate(7, arrDate);
                t.setTime(8, arrTime);
                t.setString(9, seatNumber);
                t.setString(10, customerFirst);
                t.setString(11, customerLast);
                t.setDouble(12, totalFare);
                t.setDouble(13, bookingFee);
                t.setString(14, ticketClass.toLowerCase());
                t.setInt(15, bookingGroupId);
                t.executeUpdate();
                t.close();

                messageBuilder.append("✅ Booked flight ").append(flightNumber).append("<br>");
            }

            session.setAttribute("message",
                    messageBuilder.length()>0 ? messageBuilder.toString() : "✅ Booking complete.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message","⚠️ Booking error.");
        }

        response.sendRedirect("viewBookings");
    }

    private Map<String,String> fetchFlightMap(Connection conn, int flightId) throws SQLException {
        String sql = "SELECT *, TIMEDIFF(arrival_time,departure_time) AS duration FROM flights WHERE flight_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, flightId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return Collections.emptyMap();
                Map<String,String> m = new HashMap<>();
                m.put("flight_id",      rs.getString("flight_id"));
                m.put("airline",        rs.getString("airline"));
                m.put("from_airport",   rs.getString("from_airport"));
                m.put("to_airport",     rs.getString("to_airport"));
                m.put("departure_date", rs.getString("departure_date"));
                m.put("departure_time", rs.getString("departure_time"));
                m.put("arrival_date",   rs.getString("arrival_date"));
                m.put("arrival_time",   rs.getString("arrival_time"));
                m.put("price",          rs.getString("price"));
                m.put("stops",          rs.getString("stops"));
                m.put("duration",       rs.getString("duration"));
                return m;
            }
        }
    }
}
