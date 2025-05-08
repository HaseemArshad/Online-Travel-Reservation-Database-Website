package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class BookFlightServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String customerFirst = (String) session.getAttribute("firstName");
        String customerLast = (String) session.getAttribute("lastName");
        String ticketClass = request.getParameter("ticketClass");
        String tripType = request.getParameter("tripType");
        String confirmed = request.getParameter("confirmed");

        // Collect flight IDs (could be 1 for one-way or 2 for round-trip)
        Set<String> flightIdSet = new LinkedHashSet<>(Arrays.asList(
                request.getParameter("flightId1"),
                request.getParameter("flightId2")
        ));
        flightIdSet.removeIf(id -> id == null || id.isEmpty());

        // If round-trip and not yet confirmed, fetch flight details inline and forward to review page
        if ("roundtrip".equalsIgnoreCase(tripType) && confirmed == null) {
            Map<String, String> flight1 = null;
            Map<String, String> flight2 = null;
            try (Connection conn = new ApplicationDB().getConnection()) {
                Iterator<String> it = flightIdSet.iterator();
                if (it.hasNext()) {
                    flight1 = fetchFlightMap(conn, Integer.parseInt(it.next()));
                }
                if (it.hasNext()) {
                    flight2 = fetchFlightMap(conn, Integer.parseInt(it.next()));
                }
            } catch (Exception e) {
                throw new ServletException(e);
            }
            request.setAttribute("flight1", flight1);
            request.setAttribute("flight2", flight2);
            request.setAttribute("ticketClass", ticketClass);
            RequestDispatcher rd = request.getRequestDispatcher("confirmRoundTrip.jsp");
            rd.forward(request, response);
            return;
        }

        // Otherwise perform actual booking (either confirmed round-trip or one-way)
        StringBuilder messageBuilder = new StringBuilder();
        try (Connection conn = new ApplicationDB().getConnection()) {
            Integer bookingGroupId = null;
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

            for (String flightIdStr : flightIdSet) {
                int flightId = Integer.parseInt(flightIdStr);
                // existing booking logic: select flight, check capacity, insert booking & ticket
                // ...
            }

            request.setAttribute("message", messageBuilder.length()>0
                    ? messageBuilder.toString()
                    : "✅ Booking complete.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "⚠️ Booking error.");
        }
        request.getRequestDispatcher("bookingConfirmation.jsp").forward(request, response);
    }

    /**
     * Helper: load a single flight's data into a Map
     */
    private Map<String,String> fetchFlightMap(Connection conn, int flightId) throws SQLException {
        String sql = "SELECT *, TIMEDIFF(arrival_time, departure_time) AS duration FROM flights WHERE flight_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, flightId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String,String> f = new HashMap<>();
                    f.put("flight_id",      rs.getString("flight_id"));
                    f.put("airline",        rs.getString("airline"));
                    f.put("from_airport",   rs.getString("from_airport"));
                    f.put("to_airport",     rs.getString("to_airport"));
                    f.put("departure_date", rs.getString("departure_date"));
                    f.put("departure_time", rs.getString("departure_time"));
                    f.put("arrival_date",   rs.getString("arrival_date"));
                    f.put("arrival_time",   rs.getString("arrival_time"));
                    f.put("price",          rs.getString("price"));
                    f.put("stops",          rs.getString("stops"));
                    f.put("duration",       rs.getString("duration"));
                    return f;
                } else {
                    return Collections.emptyMap();
                }
            }
        }
    }}

