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

            // 1️⃣ Get booking details before deleting
            PreparedStatement getBooking = conn.prepareStatement(
                "SELECT user_id, flight_id FROM bookings WHERE booking_id = ?");
            getBooking.setInt(1, bookingId);
            ResultSet rs = getBooking.executeQuery();

            if (rs.next()) {
                int userId = rs.getInt("user_id");
                int flightId = rs.getInt("flight_id");

                // 2️⃣ Insert into canceled_bookings
                PreparedStatement insertCancel = conn.prepareStatement(
                    "INSERT INTO canceled_bookings (booking_id, user_id, flight_id) VALUES (?, ?, ?)");
                insertCancel.setInt(1, bookingId);
                insertCancel.setInt(2, userId);
                insertCancel.setInt(3, flightId);
                insertCancel.executeUpdate();

                // 3️⃣ Delete from bookings
                PreparedStatement deleteBooking = conn.prepareStatement(
                    "DELETE FROM bookings WHERE booking_id = ?");
                deleteBooking.setInt(1, bookingId);
                deleteBooking.executeUpdate();

                request.getSession().setAttribute("message", "Booking cancelled successfully.");
            } else {
                request.getSession().setAttribute("message", "Booking not found.");
            }

            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("message", "Error while cancelling booking.");
        }

        response.sendRedirect("viewBookings?filter=canceled");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.getWriter().println("❌ Wrong HTTP Method. Use POST for cancellation.");
    }
}
