package com.cs336.pkg;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/WaitlistServlet")
public class WaitlistServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("lookup".equals(action)) {
            String flightNumber = request.getParameter("flight_number");

            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                ApplicationDB db = new ApplicationDB();
                con = db.getConnection();

                // Step 1: Get flight_id from flight_number
                int flightId = -1;
                String getFlightId = "SELECT flight_id FROM flights WHERE flight_number = ?";
                ps = con.prepareStatement(getFlightId);
                ps.setString(1, flightNumber);
                rs = ps.executeQuery();

                if (rs.next()) {
                    flightId = rs.getInt("flight_id");
                } else {
                    request.setAttribute("message", "No flight found with number " + flightNumber);
                    request.getRequestDispatcher("repFlightWaitlist.jsp").forward(request, response);
                    return;
                }

                rs.close();
                ps.close();

                // Step 2: Get users on the waitlist for this flight_id
                String waitlistQuery = """
                    SELECT wl.user_id, u.username, u.first_name, u.last_name, wl.added_time
                    FROM waiting_list wl
                    JOIN users u ON wl.user_id = u.id
                    WHERE wl.flight_id = ?
                    ORDER BY wl.added_time
                """;

                ps = con.prepareStatement(waitlistQuery);
                ps.setInt(1, flightId);
                rs = ps.executeQuery();

                List<Map<String, String>> waitlist = new ArrayList<>();
                while (rs.next()) {
                    Map<String, String> row = new HashMap<>();
                    row.put("user_id", rs.getString("user_id"));
                    row.put("username", rs.getString("username"));
                    row.put("first_name", rs.getString("first_name"));
                    row.put("last_name", rs.getString("last_name"));
                    row.put("added_time", rs.getString("added_time"));
                    waitlist.add(row);
                }

                request.setAttribute("flight_number", flightNumber);
                request.setAttribute("waitlist", waitlist);

                if (waitlist.isEmpty()) {
                    request.setAttribute("message", "No users currently on the waitlist for flight " + flightNumber + ".");
                }

            } catch (Exception e) {
                request.setAttribute("message", "Error: " + e.getMessage());
                e.printStackTrace();
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception ignored) {}
                try { if (ps != null) ps.close(); } catch (Exception ignored) {}
                try { if (con != null) con.close(); } catch (Exception ignored) {}
            }

            request.getRequestDispatcher("repViewWaitlist.jsp").forward(request, response);
        }
    }
}
