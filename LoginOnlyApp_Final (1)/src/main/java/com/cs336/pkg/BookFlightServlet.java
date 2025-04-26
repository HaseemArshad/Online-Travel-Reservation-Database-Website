package com.cs336.pkg;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class BookFlightServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String flightId = request.getParameter("flightId");

        if (userId == null || flightId == null) {
            response.getWriter().println("Error: User not logged in or flight ID missing.");
            return;
        }

        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            String sql = "INSERT INTO bookings (user_id, flight_id) VALUES (?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.setInt(2, Integer.parseInt(flightId));

            int rowsInserted = stmt.executeUpdate();
            conn.close();

            if (rowsInserted > 0) {
                request.setAttribute("message", "Flight booked successfully!");
            } else {
                request.setAttribute("message", "Failed to book flight. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "An error occurred while booking.");
        }

        RequestDispatcher rd = request.getRequestDispatcher("bookingConfirmation.jsp");
        rd.forward(request, response);
    }
}
