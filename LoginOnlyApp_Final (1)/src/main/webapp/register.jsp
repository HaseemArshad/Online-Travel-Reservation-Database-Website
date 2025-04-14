<html>
<head><title>Register</title></head>
<body>
    <h2>Register</h2>
    <form action="registerResult.jsp" method="post">
        Username: <input type="text" name="username" required /><br/>
        First Name: <input type="text" name="firstName" required /><br/>
        Last Name: <input type="text" name="lastName" required /><br/>
        Password: <input type="password" name="password" required /><br/>
        <p>Have an account? <a href="login.jsp">Login here</a></p>
        <input type="submit" value="Register" />
    </form>
</body>
</html>