package com.cs336.pkg;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/AirportServlet")
public class AirportServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        Connection con = null;
        PreparedStatement ps = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            if ("add".equals(action)) {
                String sql = "INSERT INTO airports (airport_code, airport_name, city, country) VALUES (?, ?, ?, ?)";
                ps = con.prepareStatement(sql);
                ps.setString(1, request.getParameter("airport_code"));
                ps.setString(2, request.getParameter("airport_name"));
                ps.setString(3, request.getParameter("city"));
                ps.setString(4, request.getParameter("country"));
                ps.executeUpdate();
                request.setAttribute("message", "Airport added.");
            }
            if ("edit_view".equals(action)) {
                request.setAttribute("airport_code", request.getParameter("airport_code"));
                request.setAttribute("airport_name", request.getParameter("airport_name"));
                request.setAttribute("city", request.getParameter("city"));
                request.setAttribute("country", request.getParameter("country"));
                request.setAttribute("edit", "true");

            } else if ("edit".equals(action)) {
                String sql = "UPDATE airports SET airport_name=?, city=?, country=? WHERE airport_code=?";
                ps = con.prepareStatement(sql);
                ps.setString(1, request.getParameter("airport_name"));
                ps.setString(2, request.getParameter("city"));
                ps.setString(3, request.getParameter("country"));
                ps.setString(4, request.getParameter("airport_code"));
                int rows = ps.executeUpdate();
                request.setAttribute("message", (rows > 0) ? "Airport updated." : "No changes made.");
            }
            else if ("delete".equals(action)) {
                String sql = "DELETE FROM airports WHERE airport_code=?";
                ps = con.prepareStatement(sql);
                ps.setString(1, request.getParameter("airport_code"));
                int rows = ps.executeUpdate();
                request.setAttribute("message", (rows > 0) ? "Airport deleted." : "Could not delete airport.");
            }


        } catch (Exception e) {
            request.setAttribute("message", "Error: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        }

        // Reload airport list
        try (PreparedStatement fetch = con.prepareStatement("SELECT * FROM airports");
             ResultSet rs = fetch.executeQuery()) {

            List<String[]> airportList = new ArrayList<>();
            while (rs.next()) {
                airportList.add(new String[] {
                    rs.getString("airport_code"),
                    rs.getString("airport_name"),
                    rs.getString("city"),
                    rs.getString("country")
                });
            }
            request.setAttribute("airportList", airportList);

        } catch (Exception ignored) {}

        try { if (con != null) con.close(); } catch (Exception ignored) {}

        request.getRequestDispatcher("repManageAirports.jsp").forward(request, response);
    }
}
