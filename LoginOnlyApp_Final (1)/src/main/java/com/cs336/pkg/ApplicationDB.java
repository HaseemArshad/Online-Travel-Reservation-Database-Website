package com.cs336.pkg;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.sql.PreparedStatement;


public class ApplicationDB {
	
	public ApplicationDB(){
		
	}

	public Connection getConnection(){
		
		//connecting to our project_schema database, local
		String connectionUrl = "jdbc:mysql://localhost:3306/project_schema";
		Connection connection = null;
		
		try {
			//loading the jdbc driver first
			Class.forName("com.mysql.jdbc.Driver").newInstance();
		} catch (InstantiationException e) {
			//catch 
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			//catch 
			e.printStackTrace();
		} catch (ClassNotFoundException e) { 
			//catch 
			e.printStackTrace();
		}
		try {
			//making sure the MYSQL credentials are root, root (for our group)
			connection = DriverManager.getConnection(connectionUrl,"root", "root");
		} catch (SQLException e) {
			//catch 
			e.printStackTrace();
		}
		
		return connection;
		
	}
	
	
	public void closeConnection(Connection connection){
		try {
			connection.close();
		} catch (SQLException e) {
			//catch 
			e.printStackTrace();
		}
	}
	
	public boolean isUserWaitlisted(int userId, int flightId) throws SQLException {
	    Connection con = getConnection();
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    boolean isWaitlisted = false;

	    try {
	    	String sql = "SELECT * FROM waiting_list WHERE user_id = ? AND flight_id = ?";
	        ps = con.prepareStatement(sql);
	        ps.setInt(1, userId);
	        ps.setInt(2, flightId);
	        rs = ps.executeQuery();

	        if (rs.next()) {
	            isWaitlisted = true;
	        }
	    } finally {
	        if (rs != null) rs.close();
	        if (ps != null) ps.close();
	        con.close();
	    }

	    return isWaitlisted;
	}
	public boolean flightHasSeatAvailable(int flightId) throws SQLException {
	    Connection con = getConnection();
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    boolean available = false;

	    try {
	        // Get capacity and number of bookings
	        String sql = "SELECT capacity, " +
	                     "(SELECT COUNT(*) FROM bookings WHERE flight_id = ?) AS booked " +
	                     "FROM flights WHERE flight_id = ?";
	        ps = con.prepareStatement(sql);
	        ps.setInt(1, flightId);
	        ps.setInt(2, flightId);
	        rs = ps.executeQuery();

	        if (rs.next()) {
	            int capacity = rs.getInt("capacity");
	            int booked = rs.getInt("booked");
	            available = booked < capacity;
	        }
	    } finally {
	        if (rs != null) rs.close();
	        if (ps != null) ps.close();
	        con.close();
	    }

	    return available;
	}
	
	public Integer notifyNextWaitlistedUser(int flightId) throws SQLException {
	    Connection con = getConnection();
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    Integer movedUserId = null;

	    try {
	        // Find the first user on the waitlist for this flight
	        String sql = "SELECT user_id FROM waiting_list WHERE flight_id = ? ORDER BY waitlistTime ASC LIMIT 1";
	        ps = con.prepareStatement(sql);
	        ps.setInt(1, flightId);
	        rs = ps.executeQuery();

	        if (rs.next()) {
	            int userId = rs.getInt("user_id");
	            movedUserId = userId;

	            // Add the user into the bookings table
	            String insertSql = "INSERT INTO bookings (user_id, flight_id, ticket_class) VALUES (?, ?, 'Economy')";
	            PreparedStatement insertPs = con.prepareStatement(insertSql);
	            insertPs.setInt(1, userId);
	            insertPs.setInt(2, flightId);
	            insertPs.executeUpdate();
	            insertPs.close();

	            // Remove the user from waiting list
	            String deleteSql = "DELETE FROM waiting_list WHERE flight_id = ? AND user_id = ?";
	            PreparedStatement deletePs = con.prepareStatement(deleteSql);
	            deletePs.setInt(1, flightId);
	            deletePs.setInt(2, userId);
	            deletePs.executeUpdate();
	            deletePs.close();
	        }
	    } finally {
	        if (rs != null) rs.close();
	        if (ps != null) ps.close();
	        if (con != null) con.close();
	    }

	    return movedUserId; 
	}
	public List<Integer> getWaitlistedUsers(int flightId) throws SQLException {
	    Connection con = getConnection();
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    List<Integer> waitlistedUserIds = new ArrayList<>();

	    try {
	        String sql = "SELECT user_id FROM waiting_list WHERE flight_id = ?";
	        ps = con.prepareStatement(sql);
	        ps.setInt(1, flightId);
	        rs = ps.executeQuery();

	        while (rs.next()) {
	            waitlistedUserIds.add(rs.getInt("user_id"));
	        }
	    } finally {
	        if (rs != null) rs.close();
	        if (ps != null) ps.close();
	        if (con != null) con.close();
	    }

	    return waitlistedUserIds;
	}
	
	
	public static void main(String[] args) {
		ApplicationDB dao = new ApplicationDB();
		Connection connection = dao.getConnection();
		
		System.out.println(connection);		
		dao.closeConnection(connection);
	}
	
	

}
