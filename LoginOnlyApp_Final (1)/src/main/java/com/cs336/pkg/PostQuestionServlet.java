package com.cs336.pkg;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class PostQuestionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String questionText = request.getParameter("questionText");

        if (questionText == null || questionText.trim().isEmpty()) {
            request.setAttribute("message", "❌ Question cannot be empty.");
        } else {
            try {
                ApplicationDB db = new ApplicationDB();
                Connection conn = db.getConnection();

                PreparedStatement ps = conn.prepareStatement("INSERT INTO questions_answers (question) VALUES (?)");
                ps.setString(1, questionText);
                ps.executeUpdate();

                conn.close();
                request.setAttribute("message", "✅ Your question has been submitted!");
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("message", "⚠️ Error submitting your question.");
            }
        }

        RequestDispatcher rd = request.getRequestDispatcher("browseQA.jsp");
        rd.forward(request, response);
    }
}
