<html>
<head>
    <title>Register</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="container">
    <h2>Register Your Account</h2>

    <form action="registerResult.jsp" method="post">
        <label for="username">Username:</label><br>
        <input type="text" name="username" id="username" required /><br><br>

        <label for="firstName">First Name:</label><br>
        <input type="text" name="firstName" id="firstName" required /><br><br>

        <label for="lastName">Last Name:</label><br>
        <input type="text" name="lastName" id="lastName" required /><br><br>

        <label for="password">Password:</label><br>
        <input type="password" name="password" id="password" required /><br><br>

        <p>Already have an account? <a href="login.jsp">Login here</a></p>
        <input type="submit" value="Register" />
    </form>
</div>
</body>
</html>
