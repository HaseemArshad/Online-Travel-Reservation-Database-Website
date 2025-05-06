package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

// note: removed any @WebServlet annotation to avoid duplicate‑mapping errors

public class BookFlightServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String flightId = request.getParameter("flightId");
        request.setAttribute("flightId", flightId);
        RequestDispatcher rd = request.getRequestDispatcher("bookFlight.jsp");
        rd.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ——— LOG ALL INCOMING PARAMETERS ———
        System.out.println("=== BookFlightServlet parameters ===");
        request.getParameterMap()
               .forEach((name, values) ->
                   System.out.println("  " + name + " = " + java.util.Arrays.toString(values))
               );
        System.out.println("====================================");
        // ————————————————————————————————

        HttpSession session = request.getSession();
        Integer userId      = (Integer) session.getAttribute("userId");
        String  firstName   = (String)  session.getAttribute("firstName");
        String  lastName    = (String)  session.getAttribute("lastName");
        String  ticketClass = request.getParameter("ticketClass");
        String  fromWaitlist= request.getParameter("fromWaitlist");
        String  tripType    = request.getParameter("tripType");

        if (userId == null || firstName == null || lastName == null || ticketClass == null) {
            request.setAttribute("message", "❌ Missing booking information.");
        } else {
            ApplicationDB db = new ApplicationDB();
            try (Connection conn = db.getConnection()) {

                if ("roundtrip".equalsIgnoreCase(tripType)) {
                    String outIdStr = request.getParameter("outboundFlightId");
                    String retIdStr = request.getParameter("returnFlightId");
                    if (outIdStr == null || retIdStr == null) {
                        request.setAttribute("message", "❌ Missing booking information.");
                    } else {
                        int outId = Integer.parseInt(outIdStr);
                        int retId = Integer.parseInt(retIdStr);

                        if (isFull(conn, outId) || isFull(conn, retId)) {
                            if (isFull(conn, outId)) addToWaitlist(conn, userId, outId);
                            if (isFull(conn, retId)) addToWaitlist(conn, userId, retId);
                            request.setAttribute("message", "🚨 One or both legs full; added to waiting list.");
                        } else {
                            try (PreparedStatement ps = conn.prepareStatement(
                                    "INSERT INTO bookings (user_id, outbound_flight_id, return_flight_id, ticket_class) VALUES (?,?,?,?)")) {
                                ps.setInt(1, userId);
                                ps.setInt(2, outId);
                                ps.setInt(3, retId);
                                ps.setString(4, ticketClass);
                                ps.executeUpdate();
                            }
                            createTicket(conn, outId,  userId, firstName, lastName, ticketClass, fromWaitlist);
                            createTicket(conn, retId,  userId, firstName, lastName, ticketClass, fromWaitlist);

                            request.setAttribute("message", "✅ Round‑trip booked successfully!");
                        }
                    }

                } else {
                    String flightIdStr = request.getParameter("flightId");
                    if (flightIdStr == null) {
                        request.setAttribute("message", "❌ Missing booking information.");
                    } else {
                        int flightId = Integer.parseInt(flightIdStr);
                        try (PreparedStatement flightStmt = conn.prepareStatement(
                                "SELECT * FROM flights WHERE flight_id=?")) {
                            flightStmt.setInt(1, flightId);
                            try (ResultSet rs = flightStmt.executeQuery()) {
                                if (!rs.next()) {
                                    request.setAttribute("message", "⚠️ Flight not found.");
                                } else {
                                    double basePrice = rs.getDouble("price");
                                    double adjustment = "Business".equalsIgnoreCase(ticketClass) ? 100.0
                                                      : "First".equalsIgnoreCase(ticketClass)    ? 200.0
                                                      : 0.0;
                                    double totalFare = basePrice + adjustment;
                                    double bookingFee = totalFare * 0.10;

                                    if (isFull(conn, flightId)) {
                                        addToWaitlist(conn, userId, flightId);
                                        request.setAttribute("message", "🚨 Flight full. Added to waiting list.");
                                    } else {
                                        try (PreparedStatement bookStmt = conn.prepareStatement(
                                                "INSERT INTO bookings (user_id, outbound_flight_id, ticket_class) VALUES (?,?,?)")) {
                                            bookStmt.setInt(1, userId);
                                            bookStmt.setInt(2, flightId);
                                            bookStmt.setString(3, ticketClass);
                                            bookStmt.executeUpdate();
                                        }
                                        createTicket(conn, flightId, userId, firstName, lastName, ticketClass, fromWaitlist);
                                        request.setAttribute("message", "✅ Flight and ticket booked successfully!");
                                    }
                                }
                            }
                        }
                    }
                }

            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("message", "⚠️ Booking error.");
            }
        }

        RequestDispatcher rd = request.getRequestDispatcher("bookingConfirmation.jsp");
        rd.forward(request, response);
    }

    private boolean isFull(Connection conn, int flightId) throws SQLException {
        String sql = "SELECT SUM(cnt) FROM ("
                   + "SELECT COUNT(*) AS cnt FROM bookings WHERE outbound_flight_id=? "
                   + "UNION ALL "
                   + "SELECT COUNT(*)       FROM bookings WHERE return_flight_id=?) x";
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, flightId);
            st.setInt(2, flightId);
            try (ResultSet rs = st.executeQuery()) {
                rs.next();
                int booked = rs.getInt(1);
                try (PreparedStatement cap = conn.prepareStatement(
                        "SELECT capacity FROM flights WHERE flight_id=?")) {
                    cap.setInt(1, flightId);
                    try (ResultSet crs = cap.executeQuery()) {
                        crs.next();
                        return booked >= crs.getInt("capacity");
                    }
                }
            }
        }
    }

    private void addToWaitlist(Connection conn, int userId, int flightId) throws SQLException {
        try (PreparedStatement ws = conn.prepareStatement(
                "INSERT INTO waiting_list (user_id, flight_id) VALUES (?,?)")) {
            ws.setInt(1, userId);
            ws.setInt(2, flightId);
            ws.executeUpdate();
        }
    }

    private void createTicket(Connection conn,
                              int flightId,
                              int userId,
                              String firstName,
                              String lastName,
                              String ticketClass,
                              String fromWaitlist) throws SQLException {
        try (PreparedStatement s = conn.prepareStatement(
                "SELECT flight_number, airline, departure_date, departure_time, arrival_date, arrival_time "
              + "FROM flights WHERE flight_id=?")) {
            s.setInt(1, flightId);
            try (ResultSet rs = s.executeQuery()) {
                rs.next();
                String fn = rs.getString("flight_number");
                String ac = rs.getString("airline");
                Date dd    = rs.getDate("departure_date");
                Time dt    = rs.getTime("departure_time");
                Date ad    = rs.getDate("arrival_date");
                Time at    = rs.getTime("arrival_time");

                try (PreparedStatement seat = conn.prepareStatement(
                        "SELECT COUNT(*) AS cnt FROM ticket WHERE flight_number=?")) {
                    seat.setString(1, fn);
                    try (ResultSet r2 = seat.executeQuery()) {
                        r2.next();
                        String seatNum = "Seat " + (r2.getInt("cnt") + 1);

                        try (PreparedStatement ti = conn.prepareStatement(
                                "INSERT INTO ticket "
                              + "(user_id,purchase_date,flight_number,airline_code,"
                              + "departure_date,departure_time,arrival_date,arrival_time,"
                              + "seat_number,customer_first_name,customer_last_name,"
                              + "total_fare,booking_fee,class) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)")) {
                            ti.setInt(1, userId);
                            ti.setDate(2, new java.sql.Date(System.currentTimeMillis()));
                            ti.setString(3, fn);
                            ti.setString(4, ac);
                            ti.setDate(5, dd);
                            ti.setTime(6, dt);
                            ti.setDate(7, ad);
                            ti.setTime(8, at);
                            ti.setString(9, seatNum);
                            ti.setString(10, firstName);
                            ti.setString(11, lastName);
                            ti.setDouble(12, 0.0);
                            ti.setDouble(13, 0.0);
                            ti.setString(14, ticketClass.toLowerCase());
                            ti.executeUpdate();
                        }
                    }
                }

                if ("true".equalsIgnoreCase(fromWaitlist)) {
                    try (PreparedStatement rm = conn.prepareStatement(
                            "DELETE FROM waiting_list WHERE user_id=? AND flight_id=?")) {
                        rm.setInt(1, userId);
                        rm.setInt(2, flightId);
                        rm.executeUpdate();
                    }
                }
            }
        }
    }
}
