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

        List<Map<String, String>> bookingsList = new ArrayList<>();

        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            String sql = "";

            if ("canceled".equals(filter)) {
                sql = "SELECT cb.booking_id, f.airline, f.from_airport, f.to_airport, f.departure_date, f.departure_time, f.price, cb.cancel_date, cb.ticket_class, f.flight_id " +
                      "FROM canceled_bookings cb JOIN flights f ON cb.flight_id = f.flight_id " +
                      "WHERE cb.user_id = ? ORDER BY cb.cancel_date DESC";
            } else {
                sql = "SELECT t.*, b.booking_id, f.from_airport, f.to_airport " +
                      "FROM ticket t " +
                      "JOIN bookings b ON t.user_id = b.user_id AND t.flight_number = " +
                      "  (SELECT flight_number FROM flights WHERE flight_id = b.flight_id) " +
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

            while (rs.next()) {
                Map<String, String> booking = new HashMap<>();

                if ("canceled".equals(filter)) {
                    booking.put("booking_id", rs.getString("booking_id"));
                    booking.put("airline", rs.getString("airline"));
                    booking.put("from_airport", rs.getString("from_airport"));
                    booking.put("to_airport", rs.getString("to_airport"));
                    booking.put("departure_date", rs.getString("departure_date"));
                    booking.put("departure_time", rs.getString("departure_time"));
                    double basePrice = rs.getDouble("price");
                    String ticketClass = rs.getString("ticket_class");
                    double adjustment = 0.0;

                    if ("business".equalsIgnoreCase(ticketClass)) {
                        adjustment = 100.0;
                    } else if ("first".equalsIgnoreCase(ticketClass)) {
                        adjustment = 200.0;
                    }

                    double finalPrice = basePrice + adjustment;
                    booking.put("price", String.format("%.2f", finalPrice));
                    booking.put("ticket_class", ticketClass);
                    booking.put("flight_id", rs.getString("flight_id"));
                    booking.put("cancel_date", rs.getString("cancel_date"));
                } else {
                	booking.put("ticket_id", rs.getString("ticket_id"));
                    booking.put("flight_number", rs.getString("flight_number"));
                    booking.put("airline", rs.getString("airline_code"));
                    booking.put("from_airport", rs.getString("from_airport"));
                    booking.put("to_airport", rs.getString("to_airport"));
                    booking.put("departure_date", rs.getString("departure_date"));
                    booking.put("departure_time", rs.getString("departure_time"));
                    booking.put("arrival_date", rs.getString("arrival_date"));
                    booking.put("arrival_time", rs.getString("arrival_time"));
                    booking.put("seat_number", rs.getString("seat_number"));
                    booking.put("class", rs.getString("class"));
                    booking.put("first_name", rs.getString("customer_first_name"));
                    booking.put("last_name", rs.getString("customer_last_name"));
                    booking.put("user_id", String.valueOf(userId));
                    booking.put("total_fare", rs.getString("total_fare"));
                    booking.put("purchase_date", rs.getString("purchase_date"));
                    booking.put("booking_id", rs.getString("booking_id"));
                }

                bookingsList.add(booking);
            }

            // Check waitlist availability
            Map<Integer, Boolean> seatAvailableMap = new HashMap<>();

            PreparedStatement psWaitlist = conn.prepareStatement(
                "SELECT flight_id FROM waiting_list WHERE user_id = ?");
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
