package com.dao;

import com.db.DBConnect;
import com.entity.Admin;
import java.sql.*;

public class AdminDao {

    public AdminDao() {
        // Initialization can be minimal as connection is managed per method call
    }

    // Helper method to map ResultSet to Admin object (Good practice)
    private Admin mapAdminFromResultSet(ResultSet rs) throws SQLException {
        Admin admin = new Admin();
        admin.setId(rs.getInt("id"));
        admin.setFullName(rs.getString("full_name"));
        admin.setEmail(rs.getString("email"));
        admin.setPassword(rs.getString("password"));
        admin.setCreatedAt(rs.getTimestamp("created_at"));
        // NOTE: Ensure your Admin entity class has these setters.
        return admin;
    }

    /**
     * Attempts to log in an Admin using email and password.
     * @param email The admin's email.
     * @param password The admin's password.
     * @return The Admin object if credentials are valid, otherwise null.
     */
    public Admin login(String email, String password) {
        Admin admin = null;
        // Using try-with-resources for automatic closing of Connection, PreparedStatement, and ResultSet
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT id, full_name, email, password, created_at FROM admins WHERE email = ? AND password = ?")) {
            
            ps.setString(1, email);
            ps.setString(2, password);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    admin = mapAdminFromResultSet(rs);
                }
            }
        } catch (Exception e) {
            // Log the connection or SQL error for debugging
            System.err.println("Error executing Admin login query:");
            e.printStackTrace();
        }
        return admin;
    }

    /**
     * Changes the password for a specific Admin.
     */
    public boolean changePassword(int adminId, String newPassword) {
        boolean success = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE admins SET password=? WHERE id=?")) {
            
            ps.setString(1, newPassword);
            ps.setInt(2, adminId);
            success = ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            System.err.println("Error changing Admin password:");
            e.printStackTrace();
        }
        return success;
    }

    /**
     * Retrieves an Admin by their ID.
     */
    public Admin getAdminById(int id) {
        Admin admin = null;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement("SELECT id, full_name, email, password, created_at FROM admins WHERE id = ?")) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    admin = mapAdminFromResultSet(rs);
                }
            }
        } catch (Exception e) {
            System.err.println("Error retrieving Admin by ID:");
            e.printStackTrace();
        }
        return admin;
    }

    /**
     * Checks if an email already exists in the admin table.
     */
    public boolean isEmailExists(String email) {
        boolean exists = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT id FROM admins WHERE email = ?")) {
            
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                exists = rs.next();
            }
        } catch (Exception e) {
            System.err.println("Error checking if Admin email exists:");
            e.printStackTrace();
        }
        return exists;
    }
}