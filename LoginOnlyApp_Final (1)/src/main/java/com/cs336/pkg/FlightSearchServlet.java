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
        String tripType = request.getParameter("tripType");
        String fromAirport = request.getParameter("fromAirport").trim().toUpperCase();
        String toAirport = request.getParameter("toAirport").trim().toUpperCase();
        String departureDate = request.getParameter("departureDate").trim();
        String returnDate = request.getParameter("returnDate") != null ? request.getParameter("returnDate").trim() : "";
        String sortBy = request.getParameter("sortBy");

        List<Map<String, String>> departureFlights = new ArrayList<>();
        List<Map<String, String>> returnFlights = new ArrayList<>();

        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            String orderClause = "";
            if (sortBy != null) {
                if (sortBy.equals("duration")) {
                    orderClause = " ORDER BY TIMEDIFF(arrival_time, departure_time)";
                } else if (sortBy.equals("price") || sortBy.equals("departure_time") || sortBy.equals("arrival_time")) {
                    orderClause = " ORDER BY " + sortBy;
                }
            }

            String sql = "SELECT *, TIMEDIFF(arrival_time, departure_time) AS duration FROM flights WHERE from_airport = ? AND to_airport = ? AND departure_date = ?" + orderClause;
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, fromAirport);
            stmt.setString(2, toAirport);
            stmt.setString(3, departureDate);

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

            if ("roundtrip".equals(tripType) && !returnDate.isEmpty()) {
                PreparedStatement returnStmt = conn.prepareStatement(sql);
                returnStmt.setString(1, toAirport);
                returnStmt.setString(2, fromAirport);
                returnStmt.setString(3, returnDate);

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
                    flight.put("capacity", rs.getString("capacity"));
                    returnFlights.add(flight);
                }
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("departureFlights", departureFlights);
        request.setAttribute("returnFlights", returnFlights);
        request.setAttribute("tripType", tripType);
        request.setAttribute("fromAirport", fromAirport);
        request.setAttribute("toAirport", toAirport);
        request.setAttribute("departureDate", departureDate);
        request.setAttribute("returnDate", returnDate);

        RequestDispatcher rd = request.getRequestDispatcher("flightsResult.jsp");
        rd.forward(request, response);
    }
}
