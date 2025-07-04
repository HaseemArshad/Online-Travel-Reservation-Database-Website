package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
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
        String fromWaitlist = request.getParameter("fromWaitlist");

        Set<String> flightIdSet = new LinkedHashSet<>(Arrays.asList(
                request.getParameter("flightId"),
                request.getParameter("flightId1"),
                request.getParameter("flightId2")
        ));
        flightIdSet.removeIf(id -> id == null || id.isEmpty());

        if ("roundtrip".equalsIgnoreCase(tripType) && confirmed == null) {
            try (Connection conn = new ApplicationDB().getConnection()) {
                Iterator<String> it = flightIdSet.iterator();
                if (it.hasNext()) request.setAttribute("flight1", fetchFlightMap(conn, Integer.parseInt(it.next())));
                if (it.hasNext()) request.setAttribute("flight2", fetchFlightMap(conn, Integer.parseInt(it.next())));
                request.setAttribute("ticketClass", ticketClass);
                request.getRequestDispatcher("confirmRoundTrip.jsp").forward(request, response);
                return;
            } catch (Exception e) {
                throw new ServletException(e);
            }
        }

        if (userId == null || customerFirst == null || customerLast == null || ticketClass == null) {
            request.setAttribute("message", " Missing booking information.");
            request.getRequestDispatcher("bookingConfirmation.jsp").forward(request, response);
            return;
        }

        StringBuilder messageBuilder = new StringBuilder();
        try (Connection conn = new ApplicationDB().getConnection()) {
            Integer bookingGroupId = null;
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

            for (String flightIdStr : flightIdSet) {
                int flightId = Integer.parseInt(flightIdStr);

                PreparedStatement flightStmt = conn.prepareStatement("SELECT * FROM flights WHERE flight_id = ?");
                flightStmt.setInt(1, flightId);
                ResultSet rsFlight = flightStmt.executeQuery();

                if (rsFlight.next()) {
                    String flightNumber = rsFlight.getString("flight_number");
                    String airlineCode = rsFlight.getString("airline");
                    java.sql.Date departureDate = rsFlight.getDate("departure_date");
                    java.sql.Time departureTime = rsFlight.getTime("departure_time");
                    java.sql.Date arrivalDate = rsFlight.getDate("arrival_date");
                    java.sql.Time arrivalTime = rsFlight.getTime("arrival_time");
                    int capacity = rsFlight.getInt("capacity");
                    double basePrice = rsFlight.getDouble("price");

                    double adjustment = "Business".equalsIgnoreCase(ticketClass) ? 100 : "First".equalsIgnoreCase(ticketClass) ? 200 : 0;
                    double totalFare = basePrice + adjustment;
                    double bookingFee = totalFare * 0.10;

                    PreparedStatement checkStmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM bookings WHERE flight_id = ?");
                    checkStmt.setInt(1, flightId);
                    ResultSet rsCheck = checkStmt.executeQuery();
                    rsCheck.next();
                    int bookedSeats = rsCheck.getInt("count");
                    rsCheck.close();
                    checkStmt.close();

                    if (bookedSeats >= capacity) {
                        PreparedStatement waitStmt = conn.prepareStatement("INSERT INTO waiting_list (user_id, flight_id) VALUES (?, ?)");
                        waitStmt.setInt(1, userId);
                        waitStmt.setInt(2, flightId);
                        waitStmt.executeUpdate();
                        waitStmt.close();

                        messageBuilder.append("Flight ").append(flightNumber).append(" is full. You've been waitlisted.<br>");
                        continue;
                    }

                    PreparedStatement bookStmt = conn.prepareStatement(
                            "INSERT INTO bookings (user_id, flight_id, ticket_class, booking_group_id) VALUES (?, ?, ?, ?)",
                            Statement.RETURN_GENERATED_KEYS);
                    bookStmt.setInt(1, userId);
                    bookStmt.setInt(2, flightId);
                    bookStmt.setString(3, ticketClass);
                    if (bookingGroupId == null) bookStmt.setNull(4, Types.INTEGER);
                    else bookStmt.setInt(4, bookingGroupId);
                    bookStmt.executeUpdate();

                    ResultSet generatedKeys = bookStmt.getGeneratedKeys();
                    if (generatedKeys.next() && bookingGroupId == null) {
                        int newBookingId = generatedKeys.getInt(1);
                        bookingGroupId = newBookingId;
                        PreparedStatement updateStmt = conn.prepareStatement(
                                "UPDATE bookings SET booking_group_id = ? WHERE booking_id = ?");
                        updateStmt.setInt(1, newBookingId);
                        updateStmt.setInt(2, newBookingId);
                        updateStmt.executeUpdate();
                        updateStmt.close();
                    }
                    bookStmt.close();

                    PreparedStatement seatStmt = conn.prepareStatement(
                            "SELECT COUNT(*) AS seat_count FROM ticket WHERE flight_number = ? AND airline_code = ?");
                    seatStmt.setString(1, flightNumber);
                    seatStmt.setString(2, airlineCode);
                    ResultSet seatRs = seatStmt.executeQuery();
                    seatRs.next();
                    String seatNumber = "Seat " + (seatRs.getInt("seat_count") + 1);
                    seatRs.close();
                    seatStmt.close();

                    PreparedStatement ticketStmt = conn.prepareStatement(
                            "INSERT INTO ticket (user_id, purchase_date, flight_number, airline_code, departure_date, departure_time, arrival_date, arrival_time, seat_number, customer_first_name, customer_last_name, total_fare, booking_fee, class, booking_group_id) " +
                                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                    ticketStmt.setInt(1, userId);
                    ticketStmt.setDate(2, today);
                    ticketStmt.setString(3, flightNumber);
                    ticketStmt.setString(4, airlineCode);
                    ticketStmt.setDate(5, departureDate);
                    ticketStmt.setTime(6, departureTime);
                    ticketStmt.setDate(7, arrivalDate);
                    ticketStmt.setTime(8, arrivalTime);
                    ticketStmt.setString(9, seatNumber);
                    ticketStmt.setString(10, customerFirst);
                    ticketStmt.setString(11, customerLast);
                    ticketStmt.setDouble(12, totalFare);
                    ticketStmt.setDouble(13, bookingFee);
                    ticketStmt.setString(14, ticketClass.toLowerCase());
                    ticketStmt.setInt(15, bookingGroupId);
                    ticketStmt.executeUpdate();
                    ticketStmt.close();

                    if ("true".equalsIgnoreCase(fromWaitlist)) {
                        PreparedStatement removeStmt = conn.prepareStatement("DELETE FROM waiting_list WHERE user_id = ? AND flight_id = ?");
                        removeStmt.setInt(1, userId);
                        removeStmt.setInt(2, flightId);
                        removeStmt.executeUpdate();
                        removeStmt.close();
                    }

                    messageBuilder.append("Flight ").append(flightNumber).append(" booked successfully.<br>");
                }

                rsFlight.close();
                flightStmt.close();
            }

            request.setAttribute("message", messageBuilder.length() > 0 ? messageBuilder.toString() : "Booking complete.");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Booking error.");
        }

        request.getRequestDispatcher("bookingConfirmation.jsp").forward(request, response);
    }

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
                }
            }
        }
        return Collections.emptyMap();
    }
}
