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

            if (rs.next()) {
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

                // Step 2: Get flight price
                PreparedStatement getFlight = conn.prepareStatement(
                    "SELECT price FROM flights WHERE flight_id = ?");
                getFlight.setInt(1, flightId);
                ResultSet rsFlight = getFlight.executeQuery();

                double basePrice = 0.0;
                if (rsFlight.next()) {
                    basePrice = rsFlight.getDouble("price");
                }

                double adjustment = 0.0;
                if ("business".equalsIgnoreCase(ticketClass)) {
                    adjustment = 100.0;
                } else if ("first".equalsIgnoreCase(ticketClass)) {
                    adjustment = 200.0;
                }

                double finalPrice = basePrice + adjustment;

                // Step 3: Insert into canceled_bookings
                PreparedStatement insertCancel = conn.prepareStatement(
                    "INSERT INTO canceled_bookings (booking_id, user_id, flight_id, ticket_class, cancel_date) VALUES (?, ?, ?, ?, ?)");
                insertCancel.setInt(1, bookingId);
                insertCancel.setInt(2, userId);
                insertCancel.setInt(3, flightId);
                insertCancel.setString(4, ticketClass);
                insertCancel.setTimestamp(5, new Timestamp(System.currentTimeMillis()));
                insertCancel.executeUpdate();

                // Step 4: Delete from bookings
                PreparedStatement deleteBooking = conn.prepareStatement(
                    "DELETE FROM bookings WHERE booking_id = ?");
                deleteBooking.setInt(1, bookingId);
                deleteBooking.executeUpdate();

                // Step 5: Delete matching ticket
                PreparedStatement deleteTicket = conn.prepareStatement(
                    "DELETE FROM ticket WHERE user_id = ? AND flight_number = (SELECT flight_number FROM flights WHERE flight_id = ?)");
                deleteTicket.setInt(1, userId);
                deleteTicket.setInt(2, flightId);
                deleteTicket.executeUpdate();

                // Step 6: Notify next waitlisted user
                PreparedStatement getWaitlist = conn.prepareStatement(
                    "SELECT user_id FROM waiting_list WHERE flight_id = ? AND notified = FALSE ORDER BY added_time ASC LIMIT 1");
                getWaitlist.setInt(1, flightId);
                ResultSet rsWait = getWaitlist.executeQuery();

                if (rsWait.next()) {
                    int nextUserId = rsWait.getInt("user_id");

                    PreparedStatement notifyStmt = conn.prepareStatement(
                        "UPDATE waiting_list SET notified = TRUE WHERE user_id = ? AND flight_id = ?");
                    notifyStmt.setInt(1, nextUserId);
                    notifyStmt.setInt(2, flightId);
                    notifyStmt.executeUpdate();
                }

                request.getSession().setAttribute("message", "Booking cancelled. User notified if on waitlist.");

                rsFlight.close();
                getFlight.close();
            } else {
                request.getSession().setAttribute("message", "Booking not found.");
            }

            rs.close();
            getBooking.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("message", "❌ Error while cancelling booking.");
        }

        response.sendRedirect("viewBookings?filter=upcoming");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.getWriter().println("❌ Wrong HTTP Method. Use POST for cancellation.");
    }
}
