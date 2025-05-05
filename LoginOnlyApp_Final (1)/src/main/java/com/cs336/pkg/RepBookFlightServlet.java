package com.cs336.pkg;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/RepBookFlightServlet")
public class RepBookFlightServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String flightNumber = request.getParameter("flightNumber");
        String seatClass = request.getParameter("seatClass");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            // Get user ID
            String userQuery = "SELECT id FROM users WHERE username = ?";
            ps = con.prepareStatement(userQuery);
            ps.setString(1, username);
            rs = ps.executeQuery();

            if (!rs.next()) {
                request.setAttribute("message", "❌ Error: User not found.");
                request.getRequestDispatcher("repBookFlight.jsp").forward(request, response);
                return;
            }
            int userId = rs.getInt("id");
            rs.close();
            ps.close();

            // Get flight ID using flight_number
            String flightQuery = "SELECT flight_id FROM flights WHERE flight_number = ?";
            ps = con.prepareStatement(flightQuery);
            ps.setString(1, flightNumber);
            rs = ps.executeQuery();

            if (!rs.next()) {
                request.setAttribute("message", "❌ Error: Flight number " + flightNumber + " does not exist.");
                request.getRequestDispatcher("repBookFlight.jsp").forward(request, response);
                return;
            }
            int flightId = rs.getInt("flight_id");
            rs.close();
            ps.close();

            // Book the flight
            String insertQuery = "INSERT INTO bookings (user_id, flight_id, ticket_class) VALUES (?, ?, ?)";
            ps = con.prepareStatement(insertQuery);
            ps.setInt(1, userId);
            ps.setInt(2, flightId);
            ps.setString(3, seatClass);

            int result = ps.executeUpdate();

            String message = (result > 0)
                    ? "✅ Successfully booked flight " + flightNumber + " for user " + username
                    : "❌ Booking failed. Please try again.";

            request.setAttribute("message", message);
            request.getRequestDispatcher("repBookFlight.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
