<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%
    String username = (String) session.getAttribute("username");
    if (username != null) {
        session.invalidate(); 
        response.sendRedirect("login.jsp?logout=true&user=" + username);
    } else {
        response.sendRedirect("login.jsp");
    }
%>
