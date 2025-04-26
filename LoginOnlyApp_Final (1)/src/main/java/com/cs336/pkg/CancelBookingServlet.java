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

            PreparedStatement ps = conn.prepareStatement("DELETE FROM bookings WHERE booking_id = ?");
            ps.setInt(1, bookingId);
            int rowsDeleted = ps.executeUpdate();

            conn.close();

            if (rowsDeleted > 0) {
                // Store success message in session for display after redirect
                request.getSession().setAttribute("message", "Booking cancelled successfully.");
            } else {
                request.getSession().setAttribute("message", "Booking not found or already cancelled.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("message", "Error while cancelling booking.");
        }

        // Redirect to trigger GET request and avoid 405 error
        response.sendRedirect("viewBookings");
    }

    // Handle accidental GET requests gracefully
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.getWriter().println("❌ Wrong HTTP Method. Use POST for cancellation.");
    }
}
