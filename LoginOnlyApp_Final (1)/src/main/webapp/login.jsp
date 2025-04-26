<html>
<head><title>Login</title></head>
<body>

    <h2>Login to Online Reservation System!</h2>
    <%
    String logout = request.getParameter("logout");
    String user = request.getParameter("user");
    if ("true".equals(logout) && user != null) {
    	//When the logout button is hit, creates a popup banner for the logout functionality:
%> 
    <div id="popup" align="center">
        <table border="1" cellpadding="10" cellspacing="0">
            <tr>
                <td>
                	<!-- Banner for logout confirmation with button -->
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
   <!-- connecting back to home.jsp after its done -->
    
    <form action="home.jsp" method="post">
        Username: <input type="text" name="username" /><br/>
        Password: <input type="password" name="password" /><br/>
        <p>If you dont have an account: <a href="register.jsp">Click to Register!</a></p>
        <input type="submit" value="Login" />
    </form>
</body>
</html>
