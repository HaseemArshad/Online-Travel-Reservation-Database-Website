package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class ViewBookingsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.getWriter().println("You must be logged in to view bookings.");
            return;
        }

        String filter = request.getParameter("filter");
        if (filter == null) filter = "upcoming";

        List<Map<String, Object>> bookingsList = new ArrayList<>();

        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            String sql;
            if ("canceled".equals(filter)) {
                sql = "SELECT cb.booking_id, cb.cancel_date, cb.ticket_class, cb.seat_number, cb.purchase_date, " +
                      "cb.total_fare, cb.customer_first_name, cb.customer_last_name, " +
                      "f.flight_number, f.airline, f.from_airport, f.to_airport, " +
                      "f.departure_date, f.departure_time, f.arrival_date, f.arrival_time " +
                      "FROM canceled_bookings cb " +
                      "JOIN flights f ON cb.flight_id = f.flight_id " +
                      "WHERE cb.user_id = ? " +
                      "ORDER BY cb.cancel_date DESC";
            } else {
                sql = "SELECT t.*, b.booking_id, b.booking_group_id, f.from_airport, f.to_airport " +
                      "FROM ticket t " +
                      "JOIN bookings b ON t.user_id = b.user_id AND t.flight_number = (SELECT flight_number FROM flights WHERE flight_id = b.flight_id) " +
                      "JOIN flights f ON t.flight_number = f.flight_number AND t.airline_code = f.airline " +
                      "WHERE t.user_id = ? ";

                if ("upcoming".equals(filter)) {
                    sql += "AND f.departure_date >= CURDATE() ";
                } else if ("past".equals(filter)) {
                    sql += "AND f.departure_date < CURDATE() ";
                }

                sql += "ORDER BY f.departure_date ASC";
            }

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            Map<String, List<Map<String, String>>> groupedFlights = new LinkedHashMap<>();

            while (rs.next()) {
                String groupKey = "canceled".equals(filter)
                        ? rs.getString("booking_id")
                        : (rs.getString("booking_group_id") != null && !rs.getString("booking_group_id").isEmpty())
                            ? rs.getString("booking_group_id")
                            : rs.getString("ticket_id");

                Map<String, String> flight = new HashMap<>();

                if ("canceled".equals(filter)) {
                    flight.put("booking_id", rs.getString("booking_id"));
                    flight.put("flight_number", rs.getString("flight_number"));
                    flight.put("airline_code", rs.getString("airline"));
                    flight.put("from_airport", rs.getString("from_airport"));
                    flight.put("to_airport", rs.getString("to_airport"));
                    flight.put("departure_date", rs.getString("departure_date"));
                    flight.put("departure_time", rs.getString("departure_time"));
                    flight.put("arrival_date", rs.getString("arrival_date"));
                    flight.put("arrival_time", rs.getString("arrival_time"));
                    flight.put("ticket_class", rs.getString("ticket_class"));
                    flight.put("seat_number", rs.getString("seat_number"));
                    flight.put("purchase_date", rs.getString("purchase_date"));
                    flight.put("customer_first_name", rs.getString("customer_first_name"));
                    flight.put("customer_last_name", rs.getString("customer_last_name"));
                    flight.put("total_fare", rs.getString("total_fare"));
                    flight.put("cancel_date", rs.getString("cancel_date"));
                } else {
                    flight.put("ticket_id", rs.getString("ticket_id"));
                    flight.put("flight_number", rs.getString("flight_number"));
                    flight.put("airline_code", rs.getString("airline_code"));
                    flight.put("from_airport", rs.getString("from_airport"));
                    flight.put("to_airport", rs.getString("to_airport"));
                    flight.put("departure_date", rs.getString("departure_date"));
                    flight.put("departure_time", rs.getString("departure_time"));
                    flight.put("arrival_date", rs.getString("arrival_date"));
                    flight.put("arrival_time", rs.getString("arrival_time"));
                    flight.put("seat_number", rs.getString("seat_number"));
                    flight.put("class", rs.getString("class"));
                    flight.put("customer_first_name", rs.getString("customer_first_name"));
                    flight.put("customer_last_name", rs.getString("customer_last_name"));
                    flight.put("total_fare", rs.getString("total_fare"));
                    flight.put("purchase_date", rs.getString("purchase_date"));
                    flight.put("booking_id", rs.getString("booking_id"));
                }

                groupedFlights.computeIfAbsent(groupKey, k -> new ArrayList<>()).add(flight);
            }

            for (List<Map<String, String>> flightGroup : groupedFlights.values()) {
                Map<String, Object> bookingEntry = new HashMap<>();
                bookingEntry.put("flights", flightGroup);
                bookingsList.add(bookingEntry);
            }

            // Waitlist seat availability notifications
            Map<Integer, Boolean> seatAvailableMap = new HashMap<>();
            PreparedStatement psWaitlist = conn.prepareStatement("SELECT flight_id FROM waiting_list WHERE user_id = ?");
            psWaitlist.setInt(1, userId);
            ResultSet rsWaitlist = psWaitlist.executeQuery();

            while (rsWaitlist.next()) {
                int flightId = rsWaitlist.getInt("flight_id");
                if (db.flightHasSeatAvailable(flightId)) {
                    seatAvailableMap.put(flightId, true);
                }
            }

            if (!seatAvailableMap.isEmpty()) {
                request.setAttribute("seatAvailableMap", seatAvailableMap);
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("bookingsList", bookingsList);
        request.setAttribute("currentFilter", filter);
        RequestDispatcher rd = request.getRequestDispatcher("viewBookings.jsp");
        rd.forward(request, response);
    }
}
