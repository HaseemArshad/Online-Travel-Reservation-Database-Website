package com.cs336.pkg;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/AirportFlightServlet")
public class AirportFlightServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (!"lookup".equals(action)) return;

        String airportCode = request.getParameter("airport_code").toUpperCase();
        request.setAttribute("message", "Showing flights for airport: " + airportCode);

        Connection con = null;
        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            List<Map<String, String>> departing = new ArrayList<>();
            List<Map<String, String>> arriving = new ArrayList<>();

            PreparedStatement ps1 = con.prepareStatement("""
                SELECT flight_id, airline, to_airport, departure_date, departure_time
                FROM flights WHERE from_airport = ?
            """);
            ps1.setString(1, airportCode);
            ResultSet rs1 = ps1.executeQuery();
            while (rs1.next()) {
                Map<String, String> f = new HashMap<>();
                f.put("flight_id", rs1.getString("flight_id"));
                f.put("airline", rs1.getString("airline"));
                f.put("to_airport", rs1.getString("to_airport"));
                f.put("departure_date", rs1.getString("departure_date"));
                f.put("departure_time", rs1.getString("departure_time"));
                departing.add(f);
            }

            PreparedStatement ps2 = con.prepareStatement("""
                SELECT flight_id, airline, from_airport, departure_date, arrival_time
                FROM flights WHERE to_airport = ?
            """);
            ps2.setString(1, airportCode);
            ResultSet rs2 = ps2.executeQuery();
            while (rs2.next()) {
                Map<String, String> f = new HashMap<>();
                f.put("flight_id", rs2.getString("flight_id"));
                f.put("airline", rs2.getString("airline"));
                f.put("from_airport", rs2.getString("from_airport"));
                f.put("departure_date", rs2.getString("departure_date"));
                f.put("arrival_time", rs2.getString("arrival_time"));
                arriving.add(f);
            }

            request.setAttribute("departingFlights", departing);
            request.setAttribute("arrivingFlights", arriving);

        } catch (Exception e) {
            request.setAttribute("message", "Error: " + e.getMessage());
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }

        request.getRequestDispatcher("repFlightsByAirport.jsp").forward(request, response);
    }
}
