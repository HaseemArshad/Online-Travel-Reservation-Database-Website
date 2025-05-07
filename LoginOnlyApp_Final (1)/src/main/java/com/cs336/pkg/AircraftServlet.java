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
        Connection con = null;
        PreparedStatement ps = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            if ("add".equals(action)) {
                String sql = "INSERT INTO aircrafts (seat_capacity, day_of_operation) VALUES (?, ?)";
                ps = con.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(request.getParameter("seat_capacity")));
                ps.setString(2, request.getParameter("day_of_operation"));
                ps.executeUpdate();
                request.setAttribute("message", "Aircraft added.");
            }

            else if ("edit_view".equals(action)) {
                request.setAttribute("aircraft_id", request.getParameter("aircraft_id"));
                request.setAttribute("seat_capacity", request.getParameter("seat_capacity"));
                request.setAttribute("day_of_operation", request.getParameter("day_of_operation"));
                request.setAttribute("edit", "true");
            }

            else if ("edit".equals(action)) {
                String sql = "UPDATE aircrafts SET seat_capacity=?, day_of_operation=? WHERE aircraft_id=?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(request.getParameter("seat_capacity")));
                ps.setString(2, request.getParameter("day_of_operation"));
                ps.setInt(3, Integer.parseInt(request.getParameter("aircraft_id")));
                int rows = ps.executeUpdate();
                request.setAttribute("message", (rows > 0) ? "Aircraft updated." : "Update failed.");
            }

            else if ("delete".equals(action)) {
                String sql = "DELETE FROM aircrafts WHERE aircraft_id=?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(request.getParameter("aircraft_id")));
                int rows = ps.executeUpdate();
                request.setAttribute("message", (rows > 0) ? "Aircraft deleted." : "Could not delete.");
            }

        } catch (Exception e) {
            request.setAttribute("message", "Error: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        }

        try (PreparedStatement fetch = con.prepareStatement("SELECT * FROM aircrafts");
             ResultSet rs = fetch.executeQuery()) {

            List<String[]> aircraftList = new ArrayList<>();
            while (rs.next()) {
                aircraftList.add(new String[] {
                    rs.getString("aircraft_id"),
                    rs.getString("seat_capacity"),
                    rs.getString("day_of_operation")
                });
            }
            request.setAttribute("aircraftList", aircraftList);

        } catch (Exception ignored) {}

        try { if (con != null) con.close(); } catch (Exception ignored) {}

        request.getRequestDispatcher("repManageAircrafts.jsp").forward(request, response);
    }
}

