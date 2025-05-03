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

            // Get booking details
            PreparedStatement getBooking = conn.prepareStatement(
                "SELECT user_id, flight_id FROM bookings WHERE booking_id = ?");
            getBooking.setInt(1, bookingId);
            ResultSet rs = getBooking.executeQuery();

            if (rs.next()) {
                int userId = rs.getInt("user_id");
                int flightId = rs.getInt("flight_id");

                // Delete booking
                PreparedStatement deleteBooking = conn.prepareStatement(
                    "DELETE FROM bookings WHERE booking_id = ?");
                deleteBooking.setInt(1, bookingId);
                deleteBooking.executeUpdate();

                // Delete ticket
                PreparedStatement deleteTicket = conn.prepareStatement(
                    "DELETE FROM ticket WHERE user_id = ? AND flight_number = (SELECT flight_number FROM flights WHERE flight_id = ?)");
                deleteTicket.setInt(1, userId);
                deleteTicket.setInt(2, flightId);
                deleteTicket.executeUpdate();

                // Check if any users are waiting
                PreparedStatement getWaitlist = conn.prepareStatement(
                    "SELECT user_id FROM waiting_list WHERE flight_id = ? AND notified = FALSE ORDER BY added_time ASC LIMIT 1");
                getWaitlist.setInt(1, flightId);
                ResultSet rsWait = getWaitlist.executeQuery();

                if (rsWait.next()) {
                    int nextUserId = rsWait.getInt("user_id");

                    // Mark user as notified
                    PreparedStatement notifyStmt = conn.prepareStatement(
                        "UPDATE waiting_list SET notified = TRUE WHERE user_id = ? AND flight_id = ?");
                    notifyStmt.setInt(1, nextUserId);
                    notifyStmt.setInt(2, flightId);
                    notifyStmt.executeUpdate();
                }

                request.getSession().setAttribute("message", "Booking cancelled. Waitlisted user notified.");
            } else {
                request.getSession().setAttribute("message", "Booking not found.");
            }

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
