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
            response.getWriter().println("No booking selected for cancellation.");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            // Step 1: Get booking group and check ticket class
            String groupId = null;
            String ticketClass = null;
            int userId = -1;

            PreparedStatement groupStmt = conn.prepareStatement("SELECT booking_group_id, ticket_class, user_id FROM bookings WHERE booking_id = ?");
            groupStmt.setInt(1, bookingId);
            ResultSet rsGroup = groupStmt.executeQuery();
            if (rsGroup.next()) {
                groupId = rsGroup.getString("booking_group_id");
                ticketClass = rsGroup.getString("ticket_class");
                userId = rsGroup.getInt("user_id");
            }
            rsGroup.close();
            groupStmt.close();

            if (ticketClass == null || "economy".equalsIgnoreCase(ticketClass)) {
                conn.close();
                request.getSession().setAttribute("message", "❌ Economy class tickets are non-refundable and cannot be cancelled.");
                response.sendRedirect("viewBookings?filter=upcoming");
                return;
            }

            // Step 2: Get all booking_ids in the group
            List<Integer> bookingIds = new ArrayList<>();
            if (groupId != null && !groupId.isEmpty()) {
                PreparedStatement allGroup = conn.prepareStatement("SELECT booking_id FROM bookings WHERE booking_group_id = ?");
                allGroup.setString(1, groupId);
                ResultSet rs = allGroup.executeQuery();
                while (rs.next()) {
                    bookingIds.add(rs.getInt("booking_id"));
                }
                rs.close();
                allGroup.close();
            } else {
                bookingIds.add(bookingId);
            }

            for (int id : bookingIds) {
                // Get detailed info
                PreparedStatement getInfo = conn.prepareStatement(
                    "SELECT b.user_id, b.flight_id, b.ticket_class, f.flight_number, t.seat_number, t.purchase_date, t.total_fare, t.customer_first_name, t.customer_last_name " +
                    "FROM bookings b " +
                    "JOIN flights f ON b.flight_id = f.flight_id " +
                    "JOIN ticket t ON t.user_id = b.user_id AND t.flight_number = f.flight_number " +
                    "WHERE b.booking_id = ?");
                getInfo.setInt(1, id);
                ResultSet rs = getInfo.executeQuery();

                if (rs.next()) {
                    int flightId = rs.getInt("flight_id");
                    String classType = rs.getString("ticket_class");
                    String seatNumber = rs.getString("seat_number");
                    java.sql.Date purchaseDate = rs.getDate("purchase_date");  // FIXED HERE
                    double totalFare = rs.getDouble("total_fare");
                    String firstName = rs.getString("customer_first_name");
                    String lastName = rs.getString("customer_last_name");

                    // Insert into canceled_bookings
                    PreparedStatement insertCancel = conn.prepareStatement(
                        "INSERT INTO canceled_bookings (booking_id, user_id, flight_id, ticket_class, seat_number, purchase_date, total_fare, customer_first_name, customer_last_name, cancel_date) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                    insertCancel.setInt(1, id);
                    insertCancel.setInt(2, userId);
                    insertCancel.setInt(3, flightId);
                    insertCancel.setString(4, classType);
                    insertCancel.setString(5, seatNumber);
                    insertCancel.setDate(6, purchaseDate);
                    insertCancel.setDouble(7, totalFare);
                    insertCancel.setString(8, firstName);
                    insertCancel.setString(9, lastName);
                    insertCancel.setTimestamp(10, new Timestamp(System.currentTimeMillis()));
                    insertCancel.executeUpdate();
                    insertCancel.close();

                    // Delete from bookings
                    PreparedStatement deleteBooking = conn.prepareStatement("DELETE FROM bookings WHERE booking_id = ?");
                    deleteBooking.setInt(1, id);
                    deleteBooking.executeUpdate();
                    deleteBooking.close();

                    // Delete from ticket
                    PreparedStatement deleteTicket = conn.prepareStatement(
                        "DELETE FROM ticket WHERE user_id = ? AND flight_number = ?");
                    deleteTicket.setInt(1, userId);
                    deleteTicket.setString(2, rs.getString("flight_number"));
                    deleteTicket.executeUpdate();
                    deleteTicket.close();

                    // Notify waitlist
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
                rs.close();
                getInfo.close();
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
