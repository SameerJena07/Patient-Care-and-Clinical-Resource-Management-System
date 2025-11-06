package com.dao;

import com.db.DBConnect;
import com.entity.DoctorReview;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ReviewDao {

    public ReviewDao() {
        super();
    }

    /**
     * Saves a new review to the database.
     */
    public boolean addReview(DoctorReview review) {
        boolean f = false;
        String sql = "INSERT INTO doctor_reviews(appointment_id, patient_id, doctor_id, rating, comment) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, review.getAppointmentId());
            ps.setInt(2, review.getPatientId());
            ps.setInt(3, review.getDoctorId());
            ps.setInt(4, review.getRating());
            ps.setString(5, review.getComment());
            
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
     * Checks if a patient has already reviewed a specific appointment.
     * This prevents duplicate reviews.
     */
    public boolean hasPatientReviewed(int appointmentId) {
        boolean exists = false;
        String sql = "SELECT review_id FROM doctor_reviews WHERE appointment_id = ?";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    exists = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return exists;
    }

    /**
     * Gets all reviews for a specific doctor.
     */
    public List<DoctorReview> getReviewsByDoctorId(int doctorId) {
        List<DoctorReview> list = new ArrayList<>();
        String sql = "SELECT * FROM doctor_reviews WHERE doctor_id = ? ORDER BY review_date DESC";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DoctorReview r = new DoctorReview();
                    r.setReviewId(rs.getInt("review_id"));
                    r.setAppointmentId(rs.getInt("appointment_id"));
                    r.setPatientId(rs.getInt("patient_id"));
                    r.setDoctorId(rs.getInt("doctor_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setComment(rs.getString("comment"));
                    r.setReviewDate(rs.getTimestamp("review_date"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Calculates the average rating for a specific doctor.
     */
     public double getAverageRatingByDoctorId(int doctorId) {
        double avg = 0.0;
        String sql = "SELECT AVG(rating) FROM doctor_reviews WHERE doctor_id = ?";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    avg = rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return avg;
     }
}