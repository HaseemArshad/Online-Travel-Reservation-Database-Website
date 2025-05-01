<html>
<head>
    <title>Login</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        #popup {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #e7f3fe;
            border: 1px solid #b3d4fc;
            border-radius: 6px;
            text-align: center;
        }
        form input[type="text"],
        form input[type="password"] {
            width: 300px;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Login to Online Reservation System</h2>

    <%
    String logout = request.getParameter("logout");
    String user = request.getParameter("user");
    if ("true".equals(logout) && user != null) {
    %> 
        <div id="popup">
            <p><strong>Successfully logged out user: <%= user %></strong></p>
            <form>
                <input type="button" value="Continue" onclick="document.getElementById('popup').style.display='none';" />
            </form>
        </div>
    <%
    }
    %>

    <form action="home.jsp" method="post">
        <label for="username">Username:</label><br>
        <input type="text" name="username" id="username" required /><br><br>

        <label for="password">Password:</label><br>
        <input type="password" name="password" id="password" required /><br><br>

        <p>If you don't have an account, <a href="register.jsp">Click to Register!</a></p>
        <input type="submit" value="Login" />
    </form>
</div>
</body>
</html>
