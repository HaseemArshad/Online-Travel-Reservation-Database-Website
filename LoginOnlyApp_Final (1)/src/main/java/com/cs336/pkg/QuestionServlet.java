package com.cs336.pkg;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/QuestionServlet")
public class QuestionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        Connection con = null;
        PreparedStatement ps = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            if ("answer".equals(action)) {
                String sql = "UPDATE questions_answers SET answer = ? WHERE qa_id = ?";
                ps = con.prepareStatement(sql);
                ps.setString(1, request.getParameter("answer"));
                ps.setInt(2, Integer.parseInt(request.getParameter("qa_id")));
                int rows = ps.executeUpdate();
                request.setAttribute("message", (rows > 0) ? "Answer submitted." : "Update failed.");
            } else if ("view".equals(action)) {
                request.setAttribute("message", "Reply to the questions below.");
            }

        } catch (Exception e) {
            request.setAttribute("message", "Error: " + e.getMessage());
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        }

        try (PreparedStatement fetch = con.prepareStatement("SELECT * FROM questions_answers WHERE answer IS NULL");
             ResultSet rs = fetch.executeQuery()) {

            List<Map<String, String>> list = new ArrayList<>();
            while (rs.next()) {
                Map<String, String> q = new HashMap<>();
                q.put("qa_id", rs.getString("qa_id"));
                q.put("question", rs.getString("question"));
                list.add(q);
            }
            request.setAttribute("unansweredQuestions", list);
        } catch (Exception ignored) {}

        try { if (con != null) con.close(); } catch (Exception ignored) {}

        request.getRequestDispatcher("repReplyQuestions.jsp").forward(request, response);
    }
}
