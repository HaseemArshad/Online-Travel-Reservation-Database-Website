package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/RepBookFlightServlet")
public class RepBookFlightServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String flightNumber = request.getParameter("flightNumber");
        String seatClass = request.getParameter("seatClass");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            // Get user ID and name
            ps = con.prepareStatement("SELECT id, first_name, last_name FROM users WHERE username = ?");
            ps.setString(1, username);
            rs = ps.executeQuery();

            if (!rs.next()) {
                request.setAttribute("message", " Error: User not found.");
                request.getRequestDispatcher("repBookFlight.jsp").forward(request, response);
                return;
            }
            int userId = rs.getInt("id");
            String firstName = rs.getString("first_name");
            String lastName = rs.getString("last_name");
            rs.close();
            ps.close();

            // Get flight info
            ps = con.prepareStatement("SELECT * FROM flights WHERE flight_number = ?");
            ps.setString(1, flightNumber);
            rs = ps.executeQuery();

            if (!rs.next()) {
                request.setAttribute("message", " Error: Flight number " + flightNumber + " does not exist.");
                request.getRequestDispatcher("repBookFlight.jsp").forward(request, response);
                return;
            }
            int flightId = rs.getInt("flight_id");
            String airline = rs.getString("airline");
            Date depDate = rs.getDate("departure_date");
            Time depTime = rs.getTime("departure_time");
            Date arrDate = rs.getDate("arrival_date");
            Time arrTime = rs.getTime("arrival_time");
            double basePrice = rs.getDouble("price");
            rs.close();
            ps.close();

            // Insert into bookings
            ps = con.prepareStatement("INSERT INTO bookings (user_id, flight_id, ticket_class, booking_group_id) VALUES (?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, userId);
            ps.setInt(2, flightId);
            ps.setString(3, seatClass);
            ps.setNull(4, Types.INTEGER);
            ps.executeUpdate();

            ResultSet keys = ps.getGeneratedKeys();
            int bookingId = -1;
            if (keys.next()) {
                bookingId = keys.getInt(1);
            }
            ps.close();

            if (bookingId != -1) {
                // Update booking_group_id
                ps = con.prepareStatement("UPDATE bookings SET booking_group_id = ? WHERE booking_id = ?");
                ps.setInt(1, bookingId);
                ps.setInt(2, bookingId);
                ps.executeUpdate();
                ps.close();
            }

            // Assign seat number
            ps = con.prepareStatement("SELECT COUNT(*) AS seat_count FROM ticket WHERE flight_number = ? AND airline_code = ?");
            ps.setString(1, flightNumber);
            ps.setString(2, airline);
            rs = ps.executeQuery();
            rs.next();
            String seatNumber = "Seat " + (rs.getInt("seat_count") + 1);
            rs.close();
            ps.close();

            // Calculate prices
            double classFee = "Business".equalsIgnoreCase(seatClass) ? 100 : "First".equalsIgnoreCase(seatClass) ? 200 : 0;
            double totalFare = basePrice + classFee;
            double bookingFee = totalFare * 0.10;
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

            // Insert ticket
            ps = con.prepareStatement("INSERT INTO ticket (user_id, purchase_date, flight_number, airline_code, departure_date, departure_time, arrival_date, arrival_time, seat_number, customer_first_name, customer_last_name, total_fare, booking_fee, class, booking_group_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            ps.setInt(1, userId);
            ps.setDate(2, today);
            ps.setString(3, flightNumber);
            ps.setString(4, airline);
            ps.setDate(5, depDate);
            ps.setTime(6, depTime);
            ps.setDate(7, arrDate);
            ps.setTime(8, arrTime);
            ps.setString(9, seatNumber);
            ps.setString(10, firstName);
            ps.setString(11, lastName);
            ps.setDouble(12, totalFare);
            ps.setDouble(13, bookingFee);
            ps.setString(14, seatClass.toLowerCase());
            ps.setInt(15, bookingId);
            ps.executeUpdate();
            ps.close();

            request.setAttribute("message", " Successfully booked flight " + flightNumber + " for user " + username);
            request.getRequestDispatcher("repBookFlight.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Database error: " + e.getMessage(), e);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
