package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class ViewBookingsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.getWriter().println("You must be logged in to view bookings.");
            return;
        }

        List<Map<String, String>> bookingsList = new ArrayList<>();

        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            String sql = "SELECT b.booking_id, f.airline, f.from_airport, f.to_airport, f.departure_date, f.departure_time, f.price " +
                         "FROM bookings b JOIN flights f ON b.flight_id = f.flight_id " +
                         "WHERE b.user_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> booking = new HashMap<>();
                booking.put("booking_id", rs.getString("booking_id"));
                booking.put("airline", rs.getString("airline"));
                booking.put("from_airport", rs.getString("from_airport"));
                booking.put("to_airport", rs.getString("to_airport"));
                booking.put("departure_date", rs.getString("departure_date"));
                booking.put("departure_time", rs.getString("departure_time"));
                booking.put("price", rs.getString("price"));
                bookingsList.add(booking);
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("bookingsList", bookingsList);
        RequestDispatcher rd = request.getRequestDispatcher("viewBookings.jsp");
        rd.forward(request, response);
    }
}
