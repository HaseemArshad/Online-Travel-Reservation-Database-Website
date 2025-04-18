<%@ page language="java" %>
<% // functionality for the logout system
    String username = (String) session.getAttribute("username");
    if (username != null) {
    	//if the username exists, then we can terminate the session
        session.invalidate(); 
        // once logout is pressed-> open the login.jsp file which 
        //has the next banner for a logout screen
        response.sendRedirect("login.jsp?logout=true&user=" + username);
    } else {
        response.sendRedirect("login.jsp");
    }
%>
