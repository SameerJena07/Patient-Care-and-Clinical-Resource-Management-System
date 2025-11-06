package com.dao;

import com.db.DBConnect; // Make sure this points to your DB connection class
import com.entity.Prescription;
import com.entity.PrescriptionMedication;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PrescriptionDao {

    // Removed the "private Connection conn;"
    
    public PrescriptionDao() {
        super();
        // The constructor is now empty.
    }

    /**
     * Adds a new prescription to the database.
     * @param prescription The Prescription object (without medications).
     * @return The newly generated prescription_id, or -1 if failed.
     */
    public int addPrescription(Prescription prescription) {
        int prescriptionId = -1;
        String sql = "INSERT INTO prescriptions(appointment_id, diagnosis, advice_notes, follow_up_date) VALUES (?, ?, ?, ?)";
        
        // This now gets a fresh connection, just like your AppointmentDao
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, prescription.getAppointmentId());
            ps.setString(2, prescription.getDiagnosis());
            ps.setString(3, prescription.getAdviceNotes());
            ps.setDate(4, prescription.getFollowUpDate()); // Can be null

            int i = ps.executeUpdate();
            if (i == 1) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        prescriptionId = rs.getInt(1); // Get the new prescription_id
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return prescriptionId;
    }

    /**
     * Adds a single medication to the prescription_medications table.
     * @param medication The PrescriptionMedication object.
     * @return true if successful, false otherwise.
     */
    public boolean addMedication(PrescriptionMedication medication) {
        boolean f = false;
        String sql = "INSERT INTO prescription_medications(prescription_id, medicine_name, dosage, frequency, duration) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, medication.getPrescriptionId());
            ps.setString(2, medication.getMedicineName());
            ps.setString(3, medication.getDosage());
            ps.setString(4, medication.getFrequency());
            ps.setString(5, medication.getDuration());
            
            int i = ps.executeUpdate();
            if (i == 1) {
                f = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }

    /**
     * Gets the main prescription details for a given appointment.
     * @param appointmentId The ID of the appointment.
     * @return A Prescription object, or null if not found.
     */
    public Prescription getPrescriptionByAppointmentId(int appointmentId) {
        Prescription p = null;
        String sql = "SELECT * FROM prescriptions WHERE appointment_id = ?";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Prescription();
                    p.setPrescriptionId(rs.getInt("prescription_id"));
                    p.setAppointmentId(rs.getInt("appointment_id"));
                    p.setDiagnosis(rs.getString("diagnosis"));
                    p.setAdviceNotes(rs.getString("advice_notes"));
                    p.setFollowUpDate(rs.getDate("follow_up_date"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return p;
    }
    
    /**
     * Gets a prescription by its own ID.
     * @param prescriptionId The ID of the prescription.
     * @return A Prescription object, or null if not found.
     */
    public Prescription getPrescriptionById(int prescriptionId) {
        Prescription p = null;
        String sql = "SELECT * FROM prescriptions WHERE prescription_id = ?";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, prescriptionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = new Prescription();
                    p.setPrescriptionId(rs.getInt("prescription_id"));
                    p.setAppointmentId(rs.getInt("appointment_id"));
                    p.setDiagnosis(rs.getString("diagnosis"));
                    p.setAdviceNotes(rs.getString("advice_notes"));
                    p.setFollowUpDate(rs.getDate("follow_up_date"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return p;
    }


    /**
     * Gets the list of all medications for a specific prescription.
     * @param prescriptionId The ID of the prescription.
     * @return A List of PrescriptionMedication objects.
     */
    public List<PrescriptionMedication> getMedicationsByPrescriptionId(int prescriptionId) {
        List<PrescriptionMedication> list = new ArrayList<>();
        String sql = "SELECT * FROM prescription_medications WHERE prescription_id = ?";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, prescriptionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PrescriptionMedication m = new PrescriptionMedication();
                    m.setMedicationId(rs.getInt("medication_id"));
                    m.setPrescriptionId(rs.getInt("prescription_id"));
                    m.setMedicineName(rs.getString("medicine_name"));
                    m.setDosage(rs.getString("dosage"));
                    m.setFrequency(rs.getString("frequency"));
                    m.setDuration(rs.getString("duration"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}