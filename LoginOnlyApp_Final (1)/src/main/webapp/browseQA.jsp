<%@ page import="java.sql.*, java.util.*" %>
<html>
<head>
    <title>Browse & Search FAQs</title>
</head>
<body>
    <h2>Frequently Asked Questions (FAQ)</h2>

    <!-- Search Form -->
    <form method="get">
        Search: <input type="text" name="keyword">
        <input type="submit" value="Search">
    </form>
    <br>

    <%
        String keyword = request.getParameter("keyword");
        Connection conn = null;
        try {
            com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB();
            conn = db.getConnection();

            String query = "SELECT * FROM questions_answers";
            if (keyword != null && !keyword.trim().isEmpty()) {
                query += " WHERE question LIKE ? OR answer LIKE ?";
            }

            PreparedStatement ps = conn.prepareStatement(query);

            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword + "%";
                ps.setString(1, searchPattern);
                ps.setString(2, searchPattern);
            }

            ResultSet rs = ps.executeQuery();

            boolean found = false;
            while (rs.next()) {
                found = true;
                out.println("<b>Q: " + rs.getString("question") + "</b><br>");
                String answer = rs.getString("answer");
                if (answer != null) {
                    out.println("A: " + answer + "<br><br>");
                } else {
                    out.println("<i>No answer yet.</i><br><br>");
                }
            }

            if (!found) {
                out.println("<p>No results found for '<b>" + keyword + "</b>'</p>");
            }

            conn.close();
        } catch(Exception e) {
            out.println("Error loading FAQ.");
            e.printStackTrace();
        }
    %>
<!-- Add this below your existing FAQ display -->
<hr>
<h3>Have a Question? Ask Below:</h3>

<form method="post" action="postQuestion">
    <textarea name="questionText" rows="4" cols="50" placeholder="Type your question here..." required></textarea><br>
    <input type="submit" value="Submit Question">
</form>

<a href="home.jsp">Back to Home</a>

    <a href="home.jsp">Back to Home</a>
</body>
</html>
