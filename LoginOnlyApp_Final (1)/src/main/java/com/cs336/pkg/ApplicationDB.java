package com.cs336.pkg;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

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
	
	
	
	
	
	public static void main(String[] args) {
		ApplicationDB dao = new ApplicationDB();
		Connection connection = dao.getConnection();
		
		System.out.println(connection);		
		dao.closeConnection(connection);
	}
	
	

}
