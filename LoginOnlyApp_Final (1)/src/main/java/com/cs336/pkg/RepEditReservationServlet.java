package com.cs336.pkg;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/RepEditReservationServlet")
public class RepEditReservationServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String bookingId = request.getParameter("bookingId");
        String newFlightId = request.getParameter("newFlightId");
        String newClass = request.getParameter("newClass");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();
            ps = con.prepareStatement("SELECT id FROM users WHERE username = ?");
            ps.setString(1, username);
            rs = ps.executeQuery();

            int userId = -1;
            if (rs.next()) {
                userId = rs.getInt("id");
            } else {
                request.setAttribute("message", "Error: User not found.");
                request.getRequestDispatcher("repEditReservation.jsp").forward(request, response);
                return;
            }

            ps.close(); rs.close();
            ps = con.prepareStatement("SELECT * FROM bookings WHERE booking_id = ? AND user_id = ?");
            ps.setInt(1, Integer.parseInt(bookingId));
            ps.setInt(2, userId);
            rs = ps.executeQuery();

            if (!rs.next()) {
                request.setAttribute("message", "Error: Booking does not exist or does not belong to this user.");
                request.getRequestDispatcher("repEditReservation.jsp").forward(request, response);
                return;
            }

            StringBuilder query = new StringBuilder("UPDATE bookings SET ");
            boolean setNeeded = false;

            if (newFlightId != null && !newFlightId.isEmpty()) {
                query.append("flight_id = ?");
                setNeeded = true;
            }

            if (newClass != null && !newClass.isEmpty()) {
                if (setNeeded) query.append(", ");
                query.append("ticket_class = ?");
                setNeeded = true;
            }

            if (!setNeeded) {
                request.setAttribute("message", "No updates were made.");
                request.getRequestDispatcher("repEditReservation.jsp").forward(request, response);
                return;
            }

            query.append(" WHERE booking_id = ?");

            ps.close();
            ps = con.prepareStatement(query.toString());

            int index = 1;
            if (newFlightId != null && !newFlightId.isEmpty()) {
                ps.setInt(index++, Integer.parseInt(newFlightId));
            }
            if (newClass != null && !newClass.isEmpty()) {
                ps.setString(index++, newClass);
            }
            ps.setInt(index, Integer.parseInt(bookingId));

            int rows = ps.executeUpdate();
            String msg = (rows > 0)
                ? "Booking updated successfully!"
                : "Update failed.";
            request.setAttribute("message", msg);
            request.getRequestDispatcher("repEditReservation.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Database error: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
