package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class ViewBookingsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (session == null) ? null : (Integer) session.getAttribute("userId");

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

            String sql;
            if ("canceled".equals(filter)) {
                sql = ""
                  + "SELECT cb.booking_id, cb.ticket_class, cb.cancel_date, "
                  + "       f.flight_number, f.airline, f.from_airport, f.to_airport, "
                  + "       f.departure_date, f.departure_time, f.arrival_date, f.arrival_time "
                  + "FROM canceled_bookings cb "
                  + "  JOIN flights f ON cb.flight_id = f.flight_id "
                  + "WHERE cb.user_id = ? "
                  + "ORDER BY cb.cancel_date DESC";
            } else {
                // upcoming or past: join bookings → flights twice for round‑trip
                sql = ""
                  + "SELECT b.booking_id, b.ticket_class, b.booking_date, "
                  + "       f1.flight_number AS out_num, f1.airline AS out_airline, f1.from_airport AS out_from, f1.to_airport AS out_to, "
                  + "       f1.departure_date AS out_dep_date, f1.departure_time AS out_dep_time, "
                  + "       f1.arrival_date   AS out_arr_date, f1.arrival_time   AS out_arr_time, "
                  + "       f2.flight_number AS ret_num, f2.airline AS ret_airline, f2.from_airport AS ret_from, f2.to_airport AS ret_to, "
                  + "       f2.departure_date AS ret_dep_date, f2.departure_time AS ret_dep_time, "
                  + "       f2.arrival_date   AS ret_arr_date, f2.arrival_time   AS ret_arr_time "
                  + "FROM bookings b "
                  + "  JOIN flights f1 ON b.outbound_flight_id = f1.flight_id "
                  + "  LEFT JOIN flights f2 ON b.return_flight_id   = f2.flight_id "
                  + "WHERE b.user_id = ? "
                  + (filter.equals("past")
                        ? "AND f1.departure_date < CURDATE() "
                        : "AND f1.departure_date >= CURDATE() ")
                  + "ORDER BY f1.departure_date ASC";
            }

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, String> booking = new HashMap<>();

                if ("canceled".equals(filter)) {
                    booking.put("booking_id",   rs.getString("booking_id"));
                    booking.put("ticket_class", rs.getString("ticket_class"));
                    booking.put("cancel_date",  rs.getString("cancel_date"));
                    booking.put("flight_number",rs.getString("flight_number"));
                    booking.put("airline",      rs.getString("airline"));
                    booking.put("from_airport", rs.getString("from_airport"));
                    booking.put("to_airport",   rs.getString("to_airport"));
                    booking.put("departure_date",rs.getString("departure_date"));
                    booking.put("departure_time",rs.getString("departure_time"));
                    booking.put("arrival_date",  rs.getString("arrival_date"));
                    booking.put("arrival_time",  rs.getString("arrival_time"));
                } else {
                    booking.put("booking_id",    rs.getString("booking_id"));
                    booking.put("ticket_class",  rs.getString("ticket_class"));
                    booking.put("booking_date",  rs.getString("booking_date"));

                    // outbound leg
                    booking.put("out_num",       rs.getString("out_num"));
                    booking.put("out_airline",   rs.getString("out_airline"));
                    booking.put("out_from",      rs.getString("out_from"));
                    booking.put("out_to",        rs.getString("out_to"));
                    booking.put("out_dep_date",  rs.getString("out_dep_date"));
                    booking.put("out_dep_time",  rs.getString("out_dep_time"));
                    booking.put("out_arr_date",  rs.getString("out_arr_date"));
                    booking.put("out_arr_time",  rs.getString("out_arr_time"));

                    // return leg (may be null)
                    booking.put("ret_num",       rs.getString("ret_num"));
                    booking.put("ret_airline",   rs.getString("ret_airline"));
                    booking.put("ret_from",      rs.getString("ret_from"));
                    booking.put("ret_to",        rs.getString("ret_to"));
                    booking.put("ret_dep_date",  rs.getString("ret_dep_date"));
                    booking.put("ret_dep_time",  rs.getString("ret_dep_time"));
                    booking.put("ret_arr_date",  rs.getString("ret_arr_date"));
                    booking.put("ret_arr_time",  rs.getString("ret_arr_time"));
                }

                bookingsList.add(booking);
            }

            rs.close();
            ps.close();
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
