package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class CancelBookingServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String bookingIdStr = request.getParameter("bookingId");

        if (bookingIdStr == null) {
            request.getSession().setAttribute("message", "❌ No booking selected for cancellation.");
            response.sendRedirect("viewBookings?filter=upcoming");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            Integer bookingGroupId = null;
            int userId = -1;

            // Step 1: Get booking group ID and user ID
            PreparedStatement getGroupStmt = conn.prepareStatement(
                "SELECT booking_group_id, user_id FROM bookings WHERE booking_id = ?");
            getGroupStmt.setInt(1, bookingId);
            ResultSet rsGroup = getGroupStmt.executeQuery();

            if (rsGroup.next()) {
                bookingGroupId = rsGroup.getObject("booking_group_id") != null ? rsGroup.getInt("booking_group_id") : null;
                userId = rsGroup.getInt("user_id");
            } else {
                conn.close();
                request.getSession().setAttribute("message", "❌ Booking not found.");
                response.sendRedirect("viewBookings?filter=upcoming");
                return;
            }
            rsGroup.close();
            getGroupStmt.close();

            // Step 2: Get all bookings in the group
            PreparedStatement getAllInfo = conn.prepareStatement(
                "SELECT b.booking_id, b.user_id, b.flight_id, b.ticket_class, b.booking_group_id, " +
                "f.flight_number, t.seat_number, t.purchase_date, t.total_fare, " +
                "t.customer_first_name, t.customer_last_name " +
                "FROM bookings b " +
                "JOIN flights f ON b.flight_id = f.flight_id " +
                "JOIN ticket t ON t.user_id = b.user_id AND t.booking_group_id = b.booking_group_id AND t.flight_number = f.flight_number " +
                "WHERE b.booking_group_id = ?"
            );
            getAllInfo.setInt(1, bookingGroupId != null ? bookingGroupId : bookingId);
            ResultSet rs = getAllInfo.executeQuery();

            List<Integer> bookingIdsToDelete = new ArrayList<>();
            Set<Integer> flightIdsToNotify = new HashSet<>();
            String classType = null;

            while (rs.next()) {
                int id = rs.getInt("booking_id");
                int flightId = rs.getInt("flight_id");
                classType = rs.getString("ticket_class");

                if ("economy".equalsIgnoreCase(classType)) {
                    conn.close();
                    request.getSession().setAttribute("message", "❌ Only Business and First class bookings can be canceled.");
                    response.sendRedirect("viewBookings?filter=upcoming");
                    return;
                }

                bookingIdsToDelete.add(id);
                flightIdsToNotify.add(flightId);

                // Insert into canceled_bookings
                PreparedStatement insertCancel = conn.prepareStatement(
                    "INSERT INTO canceled_bookings (booking_id, user_id, flight_id, ticket_class, seat_number, purchase_date, total_fare, customer_first_name, customer_last_name, cancel_date) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                insertCancel.setInt(1, id);
                insertCancel.setInt(2, rs.getInt("user_id"));
                insertCancel.setInt(3, flightId);
                insertCancel.setString(4, classType);
                insertCancel.setString(5, rs.getString("seat_number"));
                insertCancel.setDate(6, rs.getDate("purchase_date"));
                insertCancel.setDouble(7, rs.getDouble("total_fare"));
                insertCancel.setString(8, rs.getString("customer_first_name"));
                insertCancel.setString(9, rs.getString("customer_last_name"));
                insertCancel.setTimestamp(10, new Timestamp(System.currentTimeMillis()));
                insertCancel.executeUpdate();
                insertCancel.close();
            }
            rs.close();
            getAllInfo.close();

            // Step 3: Delete all bookings and tickets in the group
            PreparedStatement deleteBookings = conn.prepareStatement("DELETE FROM bookings WHERE booking_group_id = ?");
            deleteBookings.setInt(1, bookingGroupId != null ? bookingGroupId : bookingId);
            deleteBookings.executeUpdate();
            deleteBookings.close();

            PreparedStatement deleteTickets = conn.prepareStatement("DELETE FROM ticket WHERE user_id = ? AND booking_group_id = ?");
            deleteTickets.setInt(1, userId);
            deleteTickets.setInt(2, bookingGroupId != null ? bookingGroupId : bookingId);
            deleteTickets.executeUpdate();
            deleteTickets.close();

            // Step 4: Notify next user on waitlist for each flight
            for (int flightId : flightIdsToNotify) {
                PreparedStatement waitlist = conn.prepareStatement(
                    "SELECT user_id FROM waiting_list WHERE flight_id = ? AND notified = FALSE ORDER BY added_time ASC LIMIT 1");
                waitlist.setInt(1, flightId);
                ResultSet rsWait = waitlist.executeQuery();
                if (rsWait.next()) {
                    int nextUserId = rsWait.getInt("user_id");
                    PreparedStatement notify = conn.prepareStatement(
                        "UPDATE waiting_list SET notified = TRUE WHERE user_id = ? AND flight_id = ?");
                    notify.setInt(1, nextUserId);
                    notify.setInt(2, flightId);
                    notify.executeUpdate();
                    notify.close();
                }
                rsWait.close();
                waitlist.close();
            }

            conn.close();
            request.getSession().setAttribute("message", "✅ Booking(s) cancelled.");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("message", "❌ Error cancelling booking.");
        }

        response.sendRedirect("viewBookings?filter=upcoming");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.getWriter().println("❌ Use POST to cancel a booking.");
    }
}
