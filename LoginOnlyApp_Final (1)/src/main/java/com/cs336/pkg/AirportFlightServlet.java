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

            // Departing flights
            String departureQuery = """
                SELECT flight_number, airline, to_airport, departure_date, departure_time
                FROM flights WHERE from_airport = ?
            """;
            try (PreparedStatement ps = con.prepareStatement(departureQuery)) {
                ps.setString(1, airportCode);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> flight = new HashMap<>();
                        flight.put("flight_number", rs.getString("flight_number"));
                        flight.put("airline", rs.getString("airline"));
                        flight.put("to_airport", rs.getString("to_airport"));
                        flight.put("departure_date", rs.getString("departure_date"));
                        flight.put("departure_time", rs.getString("departure_time"));
                        departing.add(flight);
                    }
                }
            }

            // Arriving flights
            String arrivalQuery = """
                SELECT flight_number, airline, from_airport, departure_date, arrival_time
                FROM flights WHERE to_airport = ?
            """;
            try (PreparedStatement ps = con.prepareStatement(arrivalQuery)) {
                ps.setString(1, airportCode);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> flight = new HashMap<>();
                        flight.put("flight_number", rs.getString("flight_number"));
                        flight.put("airline", rs.getString("airline"));
                        flight.put("from_airport", rs.getString("from_airport"));
                        flight.put("departure_date", rs.getString("departure_date"));
                        flight.put("arrival_time", rs.getString("arrival_time"));
                        arriving.add(flight);
                    }
                }
            }

            request.setAttribute("departingFlights", departing);
            request.setAttribute("arrivingFlights", arriving);

            if (departing.isEmpty() && arriving.isEmpty()) {
                request.setAttribute("message", "No flights found for airport: " + airportCode);
            }

        } catch (Exception e) {
            request.setAttribute("message", "Error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }

        request.getRequestDispatcher("repFlightsByAirport.jsp").forward(request, response);
    }
}
