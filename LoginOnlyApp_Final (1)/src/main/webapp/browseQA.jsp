<%@ page import="java.sql.*, java.util.*" %>
<html>
<head>
    <title>Browse & Search FAQs</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h2>Frequently Asked Questions (FAQ)</h2>

    <form method="get">
        <label for="keyword">Search:</label>
        <input type="text" name="keyword" id="keyword" placeholder="Enter keyword">
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
    %>
                <div style="margin-bottom: 30px;">
                    <strong>Q: <%= rs.getString("question") %></strong><br>
                    <%
                        String answer = rs.getString("answer");
                        if (answer != null) {
                    %>
                        A: <%= answer %><br>
                    <% } else { %>
                        <i>No answer yet.</i><br>
                    <% } %>
                </div>
    <%
            }

            if (!found) {
    %>
                <p>No results found for '<strong><%= keyword %></strong>'</p>
    <%
            }

            conn.close();
        } catch(Exception e) {
    %>
            <p style="color:red;">Error loading FAQ.</p>
    <%
            e.printStackTrace();
        }
    %>

    <hr>
    <h3>Have a Question? Ask Below:</h3>

    <form method="post" action="postQuestion">
        <textarea name="questionText" rows="4" cols="50" placeholder="Type your question here..." required></textarea><br>
        <input type="submit" value="Submit Question">
    </form>

    <br>
    <a href="home.jsp"> Back to Home</a>
</div>
</body>
</html>
