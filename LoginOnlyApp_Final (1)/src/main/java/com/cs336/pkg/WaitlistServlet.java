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
        Connection con = null;
        PreparedStatement ps = null;

        if ("lookup".equals(action)) {
            try {
                ApplicationDB db = new ApplicationDB();
                con = db.getConnection();

                int flightId = Integer.parseInt(request.getParameter("flight_id"));
                request.setAttribute("flight_id", flightId);

                String sql = """
                    SELECT wl.user_id, u.username, u.first_name, u.last_name, wl.added_time
                    FROM waiting_list wl
                    JOIN users u ON wl.user_id = u.id
                    WHERE wl.flight_id = ?
                    ORDER BY wl.added_time ASC
                """;

                ps = con.prepareStatement(sql);
                ps.setInt(1, flightId);
                ResultSet rs = ps.executeQuery();

                List<Map<String, String>> list = new ArrayList<>();
                while (rs.next()) {
                    Map<String, String> row = new HashMap<>();
                    row.put("user_id", rs.getString("user_id"));
                    row.put("username", rs.getString("username"));
                    row.put("first_name", rs.getString("first_name"));
                    row.put("last_name", rs.getString("last_name"));
                    row.put("added_time", rs.getString("added_time"));
                    list.add(row);
                }

                if (list.isEmpty()) {
                    request.setAttribute("message", "No users are on the waiting list for that flight.");
                }

                request.setAttribute("waitlist", list);

            } catch (Exception e) {
                request.setAttribute("message", "Error: " + e.getMessage());
            } finally {
                try { if (ps != null) ps.close(); } catch (Exception ignored) {}
                try { if (con != null) con.close(); } catch (Exception ignored) {}
            }

            request.getRequestDispatcher("repViewWaitlist.jsp").forward(request, response);
        }
    }
}
