package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class FlightSearchServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String tripType = safeTrim(request.getParameter("tripType"));
        String fromAirport = safeTrim(request.getParameter("fromAirport")).toUpperCase();
        String toAirport = safeTrim(request.getParameter("toAirport")).toUpperCase();
        String departureDate = safeTrim(request.getParameter("departureDate"));
        String returnDate = safeTrim(request.getParameter("returnDate"));
        String sortBy = safeTrim(request.getParameter("sortBy"));
        boolean flexibleDates = "true".equalsIgnoreCase(request.getParameter("flexibleDates"));

        List<Map<String, String>> departureFlights = new ArrayList<>();
        List<Map<String, String>> returnFlights = new ArrayList<>();

        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            String orderClause = "";
            if (sortBy != null && !sortBy.isEmpty()) {
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

            String dateCondition = flexibleDates
                ? "departure_date BETWEEN DATE_SUB(?, INTERVAL 2 DAY) AND DATE_ADD(?, INTERVAL 2 DAY)"
                : "departure_date = ?";
            String sql = "SELECT *, TIMEDIFF(arrival_time, departure_time) AS duration FROM flights WHERE from_airport = ? AND to_airport = ? AND " + dateCondition + orderClause;

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, fromAirport);
            stmt.setString(2, toAirport);
            stmt.setString(3, departureDate);
            if (flexibleDates) stmt.setString(4, departureDate);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, String> flight = new HashMap<>();
                flight.put("flight_id", rs.getString("flight_id"));
                flight.put("airline", rs.getString("airline"));
                flight.put("from_airport", rs.getString("from_airport"));
                flight.put("to_airport", rs.getString("to_airport"));
                flight.put("departure_date", rs.getString("departure_date"));
                flight.put("departure_time", rs.getString("departure_time"));
                flight.put("arrival_time", rs.getString("arrival_time"));
                flight.put("price", rs.getString("price"));
                flight.put("stops", rs.getString("stops"));
                flight.put("capacity", rs.getString("capacity"));
                departureFlights.add(flight);
            }

            // 👇 Load return flights only if roundtrip
            if ("roundtrip".equalsIgnoreCase(tripType) && !returnDate.isEmpty()) {
                PreparedStatement returnStmt = conn.prepareStatement(sql);
                returnStmt.setString(1, toAirport);
                returnStmt.setString(2, fromAirport);
                returnStmt.setString(3, returnDate);
                if (flexibleDates) returnStmt.setString(4, returnDate);

                ResultSet rsReturn = returnStmt.executeQuery();
                while (rsReturn.next()) {
                    Map<String, String> flight = new HashMap<>();
                    flight.put("flight_id", rsReturn.getString("flight_id"));
                    flight.put("airline", rsReturn.getString("airline"));
                    flight.put("from_airport", rsReturn.getString("from_airport"));
                    flight.put("to_airport", rsReturn.getString("to_airport"));
                    flight.put("departure_date", rsReturn.getString("departure_date"));
                    flight.put("departure_time", rsReturn.getString("departure_time"));
                    flight.put("arrival_time", rsReturn.getString("arrival_time"));
                    flight.put("price", rsReturn.getString("price"));
                    flight.put("stops", rsReturn.getString("stops"));
                    flight.put("capacity", rsReturn.getString("capacity"));
                    returnFlights.add(flight);
                }
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // ✅ Always set these for JSP use
        request.setAttribute("departureFlights", departureFlights);
        request.setAttribute("returnFlights", returnFlights);
        request.setAttribute("tripType", tripType);
        request.setAttribute("fromAirport", fromAirport);
        request.setAttribute("toAirport", toAirport);
        request.setAttribute("departureDate", departureDate);
        request.setAttribute("returnDate", returnDate);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("flexibleDates", flexibleDates ? "true" : "false");

        RequestDispatcher rd = request.getRequestDispatcher("flightsResult.jsp");
        rd.forward(request, response);
    }

    private String safeTrim(String input) {
        return input == null ? "" : input.trim();
    }
}
