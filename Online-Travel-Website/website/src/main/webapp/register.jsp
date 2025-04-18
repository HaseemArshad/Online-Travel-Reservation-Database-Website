<html>
<head><title>Register</title></head>
<body>
	   <!-- Creating the account,asks for username,firstname,lastname,password-->
	
    <h2>Register Your Account!</h2>
    <form action="registerResult.jsp" method="post">
        Username: <input type="text" name="username" required /><br/>
        First Name: <input type="text" name="firstName" required /><br/>
        Last Name: <input type="text" name="lastName" required /><br/>
        Password: <input type="password" name="password" required /><br/>
        <p>Already have an account? <a href="login.jsp">Login here</a></p>
        <input type="submit" value="Register" />
    </form>
</body>
</html> 