<html>
<head><title>Login</title></head>
<body>

    <h2>Login</h2>
    <%
    String logout = request.getParameter("logout");
    String user = request.getParameter("user");
    if ("true".equals(logout) && user != null) {
%>
    <div id="popup" align="center">
        <table border="1" cellpadding="10" cellspacing="0">
            <tr>
                <td>
                    <b>Successfully logged out user: <%= user %></b><br/><br/>
                    <form>
                        <input type="button" value="Continue" onclick="document.getElementById('popup').style.display='none';" />
                    </form>
                </td>
            </tr>
        </table>
    </div>
<%
    }
%>
    
    <form action="home.jsp" method="post">
        Username: <input type="text" name="username" /><br/>
        Password: <input type="password" name="password" /><br/>
        <p>Don't have an account? <a href="register.jsp">Register here</a></p>
        <input type="submit" value="Login" />
    </form>
</body>
</html>
