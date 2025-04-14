<%@ page language="java" %>
<%
    String username = (String) session.getAttribute("username");
    if (username != null) {
        session.invalidate();  // Destroy the session
        // Redirect back to login.jsp with a logout flag and username
        response.sendRedirect("login.jsp?logout=true&user=" + username);
    } else {
        response.sendRedirect("login.jsp");
    }
%>
