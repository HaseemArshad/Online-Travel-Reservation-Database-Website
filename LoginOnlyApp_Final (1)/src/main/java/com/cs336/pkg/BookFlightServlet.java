package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class BookFlightServlet extends HttpServlet {
    private static final int MAX_CAPACITY = 5;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        String flightIdStr = request.getParameter("flightId");
        String ticketClass = request.getParameter("ticketClass");

        if (userId == null || flightIdStr == null || ticketClass == null) {
            request.setAttribute("message", "❌ Missing booking information.");
        } else {
            try {
                int flightId = Integer.parseInt(flightIdStr);
                ApplicationDB db = new ApplicationDB();
                Connection conn = db.getConnection();

                PreparedStatement checkStmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM bookings WHERE flight_id = ?");
                checkStmt.setInt(1, flightId);
                ResultSet rs = checkStmt.executeQuery();
                rs.next();
                int bookedSeats = rs.getInt("count");

                if (bookedSeats >= MAX_CAPACITY) {
                    PreparedStatement waitStmt = conn.prepareStatement("INSERT INTO waiting_list (user_id, flight_id) VALUES (?, ?)");
                    waitStmt.setInt(1, userId);
                    waitStmt.setInt(2, flightId);
                    waitStmt.executeUpdate();
                    request.setAttribute("message", "🚨 Flight full. Added to waiting list.");
                } else {
                    PreparedStatement bookStmt = conn.prepareStatement("INSERT INTO bookings (user_id, flight_id, ticket_class) VALUES (?, ?, ?)");
                    bookStmt.setInt(1, userId);
                    bookStmt.setInt(2, flightId);
                    bookStmt.setString(3, ticketClass);
                    bookStmt.executeUpdate();
                    request.setAttribute("message", "✅ Flight booked in " + ticketClass + " class!");
                }

                conn.close();
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("message", "⚠️ Booking error.");
            }
        }

        RequestDispatcher rd = request.getRequestDispatcher("bookingConfirmation.jsp");
        rd.forward(request, response);
    }
}
