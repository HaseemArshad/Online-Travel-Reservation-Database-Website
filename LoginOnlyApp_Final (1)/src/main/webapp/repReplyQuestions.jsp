<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<html>
<head>
    <title>Reply to Questions</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ccc;
            vertical-align: top;
            text-align: left;
        }
        textarea {
            width: 100%;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Unanswered User Questions</h2>

    <% String msg = (String) request.getAttribute("message");
       if (msg != null) { %>
        <p><strong><%= msg %></strong></p>
    <% } %>

    <table>
        <tr>
            <th>ID</th>
            <th>Question</th>
            <th>Your Answer</th>
        </tr>
    <%
        List<Map<String, String>> questions = (List<Map<String, String>>) request.getAttribute("unansweredQuestions");
        if (questions != null) {
            for (Map<String, String> q : questions) {
    %>
        <tr>
            <td><%= q.get("qa_id") %></td>
            <td><%= q.get("question") %></td>
            <td>
                <form action="QuestionServlet" method="post">
                    <input type="hidden" name="action" value="answer">
                    <input type="hidden" name="qa_id" value="<%= q.get("qa_id") %>">
                    <textarea name="answer" rows="3" required></textarea><br><br>
                    <input type="submit" value="Submit Answer">
                </form>
            </td>
        </tr>
    <%
            }
        }
    %>
    </table>

    <br>
    <form action="representativehome.jsp" method="get">
        <input type="submit" value="⬅ Back to Representative Dashboard">
    </form>
</div>
</body>
</html>
