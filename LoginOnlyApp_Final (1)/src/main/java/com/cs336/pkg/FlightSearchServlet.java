package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class FlightSearchServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1) Read form fields
        String tripType      = safeTrim(request.getParameter("tripType"));       // "oneway" or "roundtrip"sdasdasdsa
        String fromAirport   = safeTrim(request.getParameter("fromAirport")).toUpperCase();
        String toAirport     = safeTrim(request.getParameter("toAirport")).toUpperCase();
        String departureDate = safeTrim(request.getParameter("departureDate"));
        String returnDate    = safeTrim(request.getParameter("returnDate"));     // may be empty
        String sortBy        = safeTrim(request.getParameter("sortBy"));
        boolean flexibleDates = "true".equalsIgnoreCase(request.getParameter("flexibleDates"));

        // 2) Prepare lists
        List<Map<String,String>> departureFlights = new ArrayList<>();
        List<Map<String,String>> returnFlights    = new ArrayList<>();

        // 3) Determine round-trip flag
        boolean isRoundTrip = "roundtrip".equalsIgnoreCase(tripType) && !returnDate.isEmpty();

        ApplicationDB db = new ApplicationDB();
        Connection conn = null;
        try {
            conn = db.getConnection();

            // 4) Build ORDER BY
            String orderClause = "";
            if (!sortBy.isEmpty()) {
                switch (sortBy) {
                    case "duration":
                        orderClause = " ORDER BY TIMEDIFF(arrival_time, departure_time)";
                        break;
                    case "price":
                    case "departure_time":
                    case "arrival_time":
                    case "stops":
                        orderClause = " ORDER BY " + sortBy;
                        break;
                }
            }

            // 5) Build date condition
            String dateCondition = flexibleDates
                ? "departure_date BETWEEN DATE_SUB(?, INTERVAL 2 DAY) AND DATE_ADD(?, INTERVAL 2 DAY)"
                : "departure_date = ?";
            String sql = "SELECT *, TIMEDIFF(arrival_time, departure_time) AS duration "
                       + "FROM flights "
                       + "WHERE from_airport = ? AND to_airport = ? AND "
                       + dateCondition
                       + orderClause;

            // 6) Query outbound flights
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, fromAirport);
                ps.setString(2, toAirport);
                ps.setString(3, departureDate);
                if (flexibleDates) {
                    ps.setString(4, departureDate);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String,String> f = new HashMap<>();
                        f.put("flight_id",      rs.getString("flight_id"));
                        f.put("airline",        rs.getString("airline"));
                        f.put("from_airport",   rs.getString("from_airport"));
                        f.put("to_airport",     rs.getString("to_airport"));
                        f.put("departure_date", rs.getString("departure_date"));
                        f.put("departure_time", rs.getString("departure_time"));
                        f.put("arrival_time",   rs.getString("arrival_time"));
                        f.put("price",          rs.getString("price"));
                        f.put("stops",          rs.getString("stops"));
                        f.put("capacity",       rs.getString("capacity"));
                        departureFlights.add(f);
                    }
                }
            }

            // 7) Query return flights if needed
            if (isRoundTrip) {
                try (PreparedStatement ps2 = conn.prepareStatement(sql)) {
                    ps2.setString(1, toAirport);
                    ps2.setString(2, fromAirport);
                    ps2.setString(3, returnDate);
                    if (flexibleDates) {
                        ps2.setString(4, returnDate);
                    }

                    try (ResultSet rs2 = ps2.executeQuery()) {
                        while (rs2.next()) {
                            Map<String,String> f = new HashMap<>();
                            f.put("flight_id",      rs2.getString("flight_id"));
                            f.put("airline",        rs2.getString("airline"));
                            f.put("from_airport",   rs2.getString("from_airport"));
                            f.put("to_airport",     rs2.getString("to_airport"));
                            f.put("departure_date", rs2.getString("departure_date"));
                            f.put("departure_time", rs2.getString("departure_time"));
                            f.put("arrival_time",   rs2.getString("arrival_time"));
                            f.put("price",          rs2.getString("price"));
                            f.put("stops",          rs2.getString("stops"));
                            f.put("capacity",       rs2.getString("capacity"));
                            returnFlights.add(f);
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); }
                catch (SQLException ignore) {}
            }
        }

        // 8) Push to request
        request.setAttribute("tripType",         tripType);
        request.setAttribute("departureFlights", departureFlights);
        request.setAttribute("returnFlights",    returnFlights);
        request.setAttribute("departureDate",    departureDate);
        request.setAttribute("returnDate",       returnDate);

        // 9) Dispatch to correct JSP
        String target = isRoundTrip
                      ? "roundTripResults.jsp"
                      : "flightsResult.jsp";
        RequestDispatcher rd = request.getRequestDispatcher(target);
        rd.forward(request, response);
    }

    private String safeTrim(String input) {
        return (input == null) ? "" : input.trim();
    }
}