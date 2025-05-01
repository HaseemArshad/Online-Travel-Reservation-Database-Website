<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<html>
<head><title>Reply to Questions</title></head>
<body>

<h2>Unanswered User Questions</h2>

<% String msg = (String) request.getAttribute("message");
   if (msg != null) { %>
   <p><b><%= msg %></b></p>
<% } %>

<table border="1">
<tr>
    <th>ID</th><th>Question</th><th>Your Answer</th>
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
            <textarea name="answer" rows="2" cols="40" required></textarea><br>
            <input type="submit" value="Submit Answer">
        </form>
    </td>
</tr>
<% }} %>
</table>

<br>
<form action="representativehome.jsp" method="get">
    <input type="submit" value="Back to Representative Dashboard">
</form>
</body>
</html>
