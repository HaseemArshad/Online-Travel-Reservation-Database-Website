<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<html>
<head><title>Registration Result</title></head>
<body>
<%
//This is what happens when the register is complete. 
//We are going to synch into the sql database and insert to store it
    String username = request.getParameter("username");
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String password = request.getParameter("password");
//establish connection
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    //first make (using query)if the username already exists inside
    PreparedStatement psCheck = con.prepareStatement("SELECT * FROM users WHERE username=?");
    psCheck.setString(1, username);
    ResultSet rsCheck = psCheck.executeQuery();

    if (rsCheck.next()) {
    	
%>

<!-- if the user name already exists then the user should try again
	or they should login to pre-existing account they have  -->
<div align="center">
    <table border="1" cellpadding="9" cellspacing="0">
        <tr>
            <td>
                <b>Error:</b> The username '<%= username %>' already exists!<br/><br/>
                <table align="center">
                    <tr>
                        <td>
                            <form action="register.jsp" method="post">
                                <input type="submit" value="Try Again" />
                            </form>
                        </td>
                        <td>
                            <form action="login.jsp" method="post">
                                <input type="submit" value="Login Instead" />
                            </form>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>

<%
    
    } else {
        //using sql we can insert into the database now, each are stored as string for now
        PreparedStatement psInsert = con.prepareStatement("INSERT INTO users (username, first_name, last_name, password) VALUES (?, ?, ?, ?)");
        psInsert.setString(1, username);
        psInsert.setString(2, firstName);
        psInsert.setString(3, lastName);
        psInsert.setString(4, password);
        int rowsAffected = psInsert.executeUpdate();

        if (rowsAffected > 0) {
            // goign back to login page where it will welcome user
            response.sendRedirect("login.jsp");
        } else {
        	//other error, unknown error
            out.println("Unknown error occured during registration. Please try again.");
        }
    }

    con.close();
%>
</body>
</html>