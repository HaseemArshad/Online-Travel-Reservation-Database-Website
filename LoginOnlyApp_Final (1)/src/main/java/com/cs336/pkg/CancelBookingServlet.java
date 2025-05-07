package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class CancelBookingServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String bookingIdStr = request.getParameter("bookingId");

        if (bookingIdStr == null) {
            response.getWriter().println("No booking selected for cancellation.");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            // Step 1: Get booking details
            PreparedStatement getBooking = conn.prepareStatement(
                "SELECT user_id, flight_id, ticket_class FROM bookings WHERE booking_id = ?");
            getBooking.setInt(1, bookingId);
            ResultSet rs = getBooking.executeQuery();

            if (!rs.next()) {
                request.getSession().setAttribute("message", "Booking not found.");
                rs.close();
                getBooking.close();
                conn.close();
                response.sendRedirect("viewBookings?filter=upcoming");
                return;
            }

            int userId = rs.getInt("user_id");
            int flightId = rs.getInt("flight_id");
            String ticketClass = rs.getString("ticket_class");

            // ❌ Block economy class from cancellation
            if ("economy".equalsIgnoreCase(ticketClass)) {
                request.getSession().setAttribute("message", "❌ Economy class tickets are non-refundable and cannot be cancelled.");
                rs.close();
                getBooking.close();
                conn.close();
                response.sendRedirect("viewBookings?filter=upcoming");
                return;
            }

            // Step 2: Cancel this flight and check if part of round-trip
            cancelFlight(conn, bookingId, userId, flightId, ticketClass);

            // Step 3: Check and cancel return leg (if part of round-trip)
            PreparedStatement findReturn = conn.prepareStatement(
                "SELECT booking_id, flight_id FROM bookings WHERE user_id = ? AND booking_id != ? AND ticket_class = ?");
            findReturn.setInt(1, userId);
            findReturn.setInt(2, bookingId);
            findReturn.setString(3, ticketClass);
            ResultSet rsReturn = findReturn.executeQuery();

            if (rsReturn.next()) {
                int returnBookingId = rsReturn.getInt("booking_id");
                int returnFlightId = rsReturn.getInt("flight_id");
                cancelFlight(conn, returnBookingId, userId, returnFlightId, ticketClass);
            }

            request.getSession().setAttribute("message", "Booking(s) cancelled. Users notified if on waitlist.");

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("message", "❌ Error while cancelling booking.");
        }

        response.sendRedirect("viewBookings?filter=upcoming");
    }

    private void cancelFlight(Connection conn, int bookingId, int userId, int flightId, String ticketClass) throws SQLException {
        // Get price
        double price = 0.0;
        PreparedStatement getFlight = conn.prepareStatement("SELECT price FROM flights WHERE flight_id = ?");
        getFlight.setInt(1, flightId);
        ResultSet rsFlight = getFlight.executeQuery();
        if (rsFlight.next()) {
            price = rsFlight.getDouble("price");
        }
        rsFlight.close();
        getFlight.close();

        double adjustment = 0.0;
        if ("business".equalsIgnoreCase(ticketClass)) adjustment = 100.0;
        if ("first".equalsIgnoreCase(ticketClass)) adjustment = 200.0;

        double finalPrice = price + adjustment;

        // Insert into canceled_bookings
        PreparedStatement cancelInsert = conn.prepareStatement(
            "INSERT INTO canceled_bookings (booking_id, user_id, flight_id, ticket_class, cancel_date) VALUES (?, ?, ?, ?, ?)");
        cancelInsert.setInt(1, bookingId);
        cancelInsert.setInt(2, userId);
        cancelInsert.setInt(3, flightId);
        cancelInsert.setString(4, ticketClass);
        cancelInsert.setTimestamp(5, new Timestamp(System.currentTimeMillis()));
        cancelInsert.executeUpdate();

        // Delete from bookings
        PreparedStatement deleteBooking = conn.prepareStatement("DELETE FROM bookings WHERE booking_id = ?");
        deleteBooking.setInt(1, bookingId);
        deleteBooking.executeUpdate();

        // Delete ticket
        PreparedStatement deleteTicket = conn.prepareStatement(
            "DELETE FROM ticket WHERE user_id = ? AND flight_number = (SELECT flight_number FROM flights WHERE flight_id = ?)");
        deleteTicket.setInt(1, userId);
        deleteTicket.setInt(2, flightId);
        deleteTicket.executeUpdate();

        // Notify next waitlisted user
        PreparedStatement waitlist = conn.prepareStatement(
            "SELECT user_id FROM waiting_list WHERE flight_id = ? AND notified = FALSE ORDER BY added_time ASC LIMIT 1");
        waitlist.setInt(1, flightId);
        ResultSet rsWait = waitlist.executeQuery();
        if (rsWait.next()) {
            int nextUserId = rsWait.getInt("user_id");
            PreparedStatement notify = conn.prepareStatement(
                "UPDATE waiting_list SET notified = TRUE WHERE user_id = ? AND flight_id = ?");
            notify.setInt(1, nextUserId);
            notify.setInt(2, flightId);
            notify.executeUpdate();
        }
        rsWait.close();
        waitlist.close();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.getWriter().println("❌ Wrong HTTP Method. Use POST for cancellation.");
    }
}
