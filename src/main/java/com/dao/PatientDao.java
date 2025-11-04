package com.dao;

import com.db.DBConnect;
import com.entity.Patient;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PatientDao {
    
    // --- Helper method to map ResultSet to Patient object (kept for completeness) ---
    private void mapPatientFromResultSet(Patient patient, ResultSet rs) throws SQLException {
        patient.setId(rs.getInt("id"));
        patient.setFullName(rs.getString("full_name"));
        patient.setEmail(rs.getString("email"));
        patient.setPassword(rs.getString("password"));
        patient.setPhone(rs.getString("phone"));
        patient.setAddress(rs.getString("address"));
        patient.setGender(rs.getString("gender"));
        patient.setBloodGroup(rs.getString("blood_group"));
        patient.setDateOfBirth(rs.getDate("date_of_birth"));
        patient.setEmergencyContact(rs.getString("emergency_contact"));
        patient.setMedicalHistory(rs.getString("medical_history"));
        patient.setCreatedAt(rs.getTimestamp("created_at"));
    }
    
    // --- CREATE/REGISTER ---
    public boolean registerPatient(Patient patient) {
        boolean success = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "INSERT INTO patients(full_name, email, password, phone, address, gender, blood_group, date_of_birth, emergency_contact, medical_history) VALUES(?,?,?,?,?,?,?,?,?,?)")) {
            
            ps.setString(1, patient.getFullName());
            ps.setString(2, patient.getEmail());
            ps.setString(3, patient.getPassword());
            ps.setString(4, patient.getPhone());
            ps.setString(5, patient.getAddress());
            ps.setString(6, patient.getGender());
            ps.setString(7, patient.getBloodGroup());
            ps.setDate(8, patient.getDateOfBirth());
            ps.setString(9, patient.getEmergencyContact());
            ps.setString(10, patient.getMedicalHistory());
            success = ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }

    // --- READ/LOGIN ---
    public Patient login(String email, String password) {
        Patient patient = null;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT * FROM patients WHERE email = ? AND password = ?")) {
            
            ps.setString(1, email);
            ps.setString(2, password);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    patient = new Patient();
                    mapPatientFromResultSet(patient, rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return patient;
    }

    // --- READ BY ID ---
    public Patient getPatientById(int id) {
        Patient patient = null;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT * FROM patients WHERE id = ?")) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    patient = new Patient();
                    mapPatientFromResultSet(patient, rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return patient;
    }
    
    // --- READ ALL ---
    public List<Patient> getAllPatients() {
        List<Patient> patients = new ArrayList<>();
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT * FROM patients ORDER BY created_at DESC");
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Patient patient = new Patient();
                mapPatientFromResultSet(patient, rs);
                patients.add(patient);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return patients;
    }
    
    // --- READ COUNT ---
    public int getTotalPatients() {
        int count = 0;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT COUNT(*) FROM patients");
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }
    
    // --- READ EXISTS ---
    public boolean isEmailExists(String email) {
        boolean exists = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT id FROM patients WHERE email = ?")) {
            
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                exists = rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return exists;
    }

    // --- UPDATE PROFILE ---
    public boolean updatePatient(Patient patient) {
        boolean success = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE patients SET full_name=?, phone=?, address=?, gender=?, blood_group=?, date_of_birth=?, emergency_contact=?, medical_history=? WHERE id=?")) {
            
            ps.setString(1, patient.getFullName());
            ps.setString(2, patient.getPhone());
            ps.setString(3, patient.getAddress());
            ps.setString(4, patient.getGender());
            ps.setString(5, patient.getBloodGroup());
            ps.setDate(6, patient.getDateOfBirth());
            ps.setString(7, patient.getEmergencyContact());
            ps.setString(8, patient.getMedicalHistory());
            ps.setInt(9, patient.getId());
            success = ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }

    // --- UPDATE PASSWORD ---
    public boolean changePassword(int patientId, String newPassword) {
        boolean success = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE patients SET password=? WHERE id=?")) {
            
            ps.setString(1, newPassword);
            ps.setInt(2, patientId);
            success = ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }

    // --- DELETE ACCOUNT PERMANENTLY (Transactional Update) ---
    /**
     * Deletes a patient permanently, including all associated appointments, using a SQL transaction.
     * @param patientId The ID of the patient to delete.
     * @return true if the patient record was successfully deleted.
     * @throws SQLException If a database error occurs, the transaction is rolled back.
     */
    public boolean deletePatient(int patientId) throws SQLException {
        boolean success = false;
        Connection conn = null;
        
        try {
            conn = DBConnect.getConn();
            if (conn == null) return false; // Fail if connection is null

            // 1. Start Transaction
            conn.setAutoCommit(false);

            // 2. Delete dependent records first (Appointments)
            // ASSUMPTION: 'appointments' is the table, 'patient_id' is the foreign key
            try (PreparedStatement psAppointments = conn.prepareStatement(
                "DELETE FROM appointments WHERE patient_id = ?")) {
                
                psAppointments.setInt(1, patientId);
                psAppointments.executeUpdate(); // No need to check rows affected here
            }

            // 3. Delete the main patient record
            try (PreparedStatement psPatient = conn.prepareStatement(
                "DELETE FROM patients WHERE id = ?")) {
                
                psPatient.setInt(1, patientId);
                int rowsAffected = psPatient.executeUpdate();
                success = rowsAffected > 0;
            }

            // 4. Commit Transaction
            if (success) {
                conn.commit();
            } else {
                conn.rollback();
            }
            
        } catch (SQLException e) {
            // 5. Rollback on Error
            if (conn != null) {
                conn.rollback();
            }
            e.printStackTrace();
            throw e; // Re-throw to allow calling servlet to handle the error
        } finally {
            // Reset auto commit and close connection
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { e.printStackTrace(); }
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return success;
    }
}