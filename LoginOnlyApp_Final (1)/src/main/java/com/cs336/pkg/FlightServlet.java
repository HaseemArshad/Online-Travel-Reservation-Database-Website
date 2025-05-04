package com.cs336.pkg;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import java.math.BigDecimal;

@WebServlet("/FlightServlet")
public class FlightServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String flightNumber = request.getParameter("flight_number");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            if ("edit_view".equals(action)) {
                // Load form for editing
                String[] keys = {
                    "flight_number", "airline", "from_airport", "to_airport",
                    "departure_date", "arrival_date", "departure_time", "arrival_time",
                    "price", "stops", "capacity"
                };
                for (String key : keys) {
                    request.setAttribute(key, request.getParameter(key));
                }
                request.setAttribute("edit", "true");

            } else if ("add".equals(action)) {
                String sql = "INSERT INTO flights (flight_number, airline, from_airport, to_airport, departure_date, arrival_date, departure_time, arrival_time, price, stops, capacity) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                ps = con.prepareStatement(sql);
                ps.setString(1, flightNumber);
                ps.setString(2, request.getParameter("airline"));
                ps.setString(3, request.getParameter("from_airport"));
                ps.setString(4, request.getParameter("to_airport"));
                ps.setDate(5, java.sql.Date.valueOf(request.getParameter("departure_date")));
                ps.setDate(6, java.sql.Date.valueOf(request.getParameter("arrival_date")));

                String depTimeRaw = request.getParameter("departure_time");
                if (!depTimeRaw.matches("^\\d{2}:\\d{2}:\\d{2}$")) depTimeRaw += ":00";
                ps.setTime(7, java.sql.Time.valueOf(depTimeRaw));

                String arrTimeRaw = request.getParameter("arrival_time");
                if (!arrTimeRaw.matches("^\\d{2}:\\d{2}:\\d{2}$")) arrTimeRaw += ":00";
                ps.setTime(8, java.sql.Time.valueOf(arrTimeRaw));

                ps.setBigDecimal(9, new BigDecimal(request.getParameter("price")));
                ps.setInt(10, Integer.parseInt(request.getParameter("stops")));
                ps.setInt(11, Integer.parseInt(request.getParameter("capacity")));

                int rows = ps.executeUpdate();
                request.setAttribute("message", "Flight added.");

            } else if ("edit".equals(action)) {
                String sql = "UPDATE flights SET airline=?, from_airport=?, to_airport=?, departure_date=?, arrival_date=?, departure_time=?, arrival_time=?, price=?, stops=?, capacity=? " +
                             "WHERE flight_number=?";

                ps = con.prepareStatement(sql);
                ps.setString(1, request.getParameter("airline"));
                ps.setString(2, request.getParameter("from_airport"));
                ps.setString(3, request.getParameter("to_airport"));
                ps.setDate(4, java.sql.Date.valueOf(request.getParameter("departure_date")));
                ps.setDate(5, java.sql.Date.valueOf(request.getParameter("arrival_date")));

                String depTimeRaw = request.getParameter("departure_time");
                if (!depTimeRaw.matches("^\\d{2}:\\d{2}:\\d{2}$")) depTimeRaw += ":00";
                ps.setTime(6, java.sql.Time.valueOf(depTimeRaw));

                String arrTimeRaw = request.getParameter("arrival_time");
                if (!arrTimeRaw.matches("^\\d{2}:\\d{2}:\\d{2}$")) arrTimeRaw += ":00";
                ps.setTime(7, java.sql.Time.valueOf(arrTimeRaw));

                ps.setBigDecimal(8, new BigDecimal(request.getParameter("price")));
                ps.setInt(9, Integer.parseInt(request.getParameter("stops")));
                ps.setInt(10, Integer.parseInt(request.getParameter("capacity")));
                ps.setString(11, flightNumber);

                int rows = ps.executeUpdate();
                request.setAttribute("message", (rows > 0) ? "Flight updated." : "No changes made.");

            } else if ("delete".equals(action)) {
                String sql = "DELETE FROM flights WHERE flight_number=?";
                ps = con.prepareStatement(sql);
                ps.setString(1, flightNumber);
                int rows = ps.executeUpdate();
                request.setAttribute("message", (rows > 0) ? "Flight deleted." : "Could not delete flight.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        }

        // Fetch all flights
        try (PreparedStatement fetch = con.prepareStatement("SELECT * FROM flights");
             ResultSet rs = fetch.executeQuery()) {

            List<String[]> flightList = new ArrayList<>();
            while (rs.next()) {
                flightList.add(new String[] {
                    rs.getString("flight_number"), rs.getString("airline"),
                    rs.getString("from_airport"), rs.getString("to_airport"),
                    rs.getString("departure_date"), rs.getString("arrival_date"),
                    rs.getString("departure_time"), rs.getString("arrival_time"),
                    rs.getString("price"), rs.getString("stops"), rs.getString("capacity")
                });
            }
            request.setAttribute("flightList", flightList);
        } catch (Exception ignored) {}

        try { if (con != null) con.close(); } catch (Exception ignored) {}
        request.getRequestDispatcher("repManageFlights.jsp").forward(request, response);
    }
}
