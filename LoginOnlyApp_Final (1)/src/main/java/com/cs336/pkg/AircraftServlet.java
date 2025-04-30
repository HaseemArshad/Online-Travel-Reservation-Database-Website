package com.cs336.pkg;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/AircraftServlet")
public class AircraftServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String id = request.getParameter("aircraft_id");
        String model = request.getParameter("model");
        String capacity = request.getParameter("capacity");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            if ("add_or_edit".equals(action)) {
                String query = "INSERT INTO aircrafts (aircraft_id, model, capacity) " +
                               "VALUES (?, ?, ?) " +
                               "ON DUPLICATE KEY UPDATE model=?, capacity=?";
                ps = con.prepareStatement(query);
                ps.setInt(1, Integer.parseInt(id));
                ps.setString(2, model);
                ps.setInt(3, Integer.parseInt(capacity));
                ps.setString(4, model);
                ps.setInt(5, Integer.parseInt(capacity));
            } else if ("delete".equals(action)) {
                ps = con.prepareStatement("DELETE FROM aircrafts WHERE aircraft_id = ?");
                ps.setInt(1, Integer.parseInt(id));
            }

            int rows = ps.executeUpdate();
            request.setAttribute("message", (rows > 0) ? "Operation successful." : "No changes made.");

        } catch (Exception e) {
            request.setAttribute("message", "Error: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        }

        try (PreparedStatement fetch = con.prepareStatement("SELECT * FROM aircrafts");
             ResultSet rs = fetch.executeQuery()) {
            List<String[]> aircraftList = new ArrayList<>();
            while (rs.next()) {
                aircraftList.add(new String[]{
                        rs.getString("aircraft_id"),
                        rs.getString("model"),
                        rs.getString("capacity")
                });
            }
            request.setAttribute("aircraftList", aircraftList);
        } catch (Exception ignored) {}

        try { if (con != null) con.close(); } catch (Exception ignored) {}
        request.getRequestDispatcher("repManageAircrafts.jsp").forward(request, response);
    }
}
