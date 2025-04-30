package com.cs336.pkg;

import java.io.IOException;
import java.io.PrintWriter;
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
        String flightId = request.getParameter("flightId");
        String seatClass = request.getParameter("seatClass");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            String userQuery = "SELECT id FROM users WHERE username = ?";
            ps = con.prepareStatement(userQuery);
            ps.setString(1, username);
            rs = ps.executeQuery();

            int userId = -1;
            if (rs.next()) {
                userId = rs.getInt("id");
            } else {
                request.setAttribute("message", "Error: No such user found.");
                request.getRequestDispatcher("repBookFlight.jsp").forward(request, response);
                return;
            }

            ps.close();
            rs.close();
            String flightQuery = "SELECT flight_id FROM flights WHERE flight_id = ?";
            ps = con.prepareStatement(flightQuery);
            ps.setInt(1, Integer.parseInt(flightId));
            rs = ps.executeQuery();

            if (!rs.next()) {
                request.setAttribute("message", "Error: Flight ID " + flightId + " does not exist.");
                request.getRequestDispatcher("repBookFlight.jsp").forward(request, response);
                return;
            }

            ps.close();
            String insertQuery = "INSERT INTO bookings (user_id, flight_id, ticket_class) VALUES (?, ?, ?)";
            ps = con.prepareStatement(insertQuery);
            ps.setInt(1, userId);
            ps.setInt(2, Integer.parseInt(flightId));
            ps.setString(3, seatClass);

            int rows = ps.executeUpdate();

            String message = (rows > 0)
                ? "Successfully booked flight " + flightId + " for user " + username
                : "Booking failed. Please try again.";

            request.setAttribute("message", message);
            request.getRequestDispatcher("repBookFlight.jsp").forward(request, response);


        } catch (Exception e) {
            throw new ServletException("Database error: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
