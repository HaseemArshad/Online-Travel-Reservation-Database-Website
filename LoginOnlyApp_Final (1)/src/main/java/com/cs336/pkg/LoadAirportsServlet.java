package com.cs336.pkg;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.RequestDispatcher;

import java.io.IOException;
import java.sql.*;
import java.util.Set;
import java.util.TreeSet;

@WebServlet("/loadAirports")
public class LoadAirportsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Set<String> airportSet = new TreeSet<>(); 

        try {
            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();

            String sql = "SELECT DISTINCT from_airport AS airport FROM flights " +
                         "UNION " +
                         "SELECT DISTINCT to_airport AS airport FROM flights";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                airportSet.add(rs.getString("airport"));
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("airports", airportSet);
        RequestDispatcher dispatcher = request.getRequestDispatcher("searchFlights.jsp");
        dispatcher.forward(request, response);
    }
}
