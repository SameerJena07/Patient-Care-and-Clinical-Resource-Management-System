package com.dao;

import com.db.DBConnect;
import com.entity.Appointment;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AppointmentDao {
    
	public boolean bookAppointment(Appointment appointment) {
        boolean success = false;
        
        // 1. We added 'status' to the query
        String sql = "INSERT INTO appointments(patient_id, doctor_id, appointment_date, " +
                     "appointment_time, appointment_type, reason, notes, status) " + 
                     "VALUES(?,?,?,?,?,?,?,?)"; 
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, appointment.getPatientId());
            ps.setInt(2, appointment.getDoctorId());
            ps.setDate(3, appointment.getAppointmentDate());
            ps.setTime(4, appointment.getAppointmentTime());
            ps.setString(5, appointment.getAppointmentType());
            ps.setString(6, appointment.getReason());
            ps.setString(7, appointment.getNotes());
            
            // 2. We now set the status to 'Pending' by default for every new booking
            ps.setString(8, "Pending"); 
            
            success = ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }

    public Appointment getAppointmentById(int id) {
        Appointment appointment = null;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT a.*, p.full_name as patient_name, d.full_name as doctor_name, d.specialization as doctor_specialization " +
                 "FROM appointments a " +
                 "JOIN patients p ON a.patient_id = p.id " +
                 "JOIN doctors d ON a.doctor_id = d.id " +
                 "WHERE a.id = ?")) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    appointment = new Appointment();
                    mapAppointmentFromResultSet(appointment, rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return appointment;
    }

    public List<Appointment> getAppointmentsByPatientId(int patientId) {
        List<Appointment> appointments = new ArrayList<>();
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT a.*, p.full_name as patient_name, d.full_name as doctor_name, d.specialization as doctor_specialization " +
                 "FROM appointments a " +
                 "JOIN patients p ON a.patient_id = p.id " +
                 "JOIN doctors d ON a.doctor_id = d.id " +
                 "WHERE a.patient_id = ? ORDER BY a.appointment_date DESC, a.appointment_time DESC")) {
            
            ps.setInt(1, patientId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment appointment = new Appointment();
                    mapAppointmentFromResultSet(appointment, rs);
                    appointments.add(appointment);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return appointments;
    }

    public List<Appointment> getAppointmentsByDoctorId(int doctorId) {
        List<Appointment> appointments = new ArrayList<>();
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT a.*, p.full_name as patient_name, d.full_name as doctor_name, d.specialization as doctor_specialization " +
                 "FROM appointments a " +
                 "JOIN patients p ON a.patient_id = p.id " +
                 "JOIN doctors d ON a.doctor_id = d.id " +
                 "WHERE a.doctor_id = ? ORDER BY a.appointment_date DESC, a.appointment_time DESC")) {
            
            ps.setInt(1, doctorId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment appointment = new Appointment();
                    mapAppointmentFromResultSet(appointment, rs);
                    appointments.add(appointment);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return appointments;
    }

    public List<Appointment> getAllAppointments() {
        List<Appointment> appointments = new ArrayList<>();
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT a.*, p.full_name as patient_name, d.full_name as doctor_name, d.specialization as doctor_specialization " +
                 "FROM appointments a " +
                 "JOIN patients p ON a.patient_id = p.id " +
                 "JOIN doctors d ON a.doctor_id = d.id " +
                 "ORDER BY a.appointment_date DESC, a.appointment_time DESC");
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Appointment appointment = new Appointment();
                mapAppointmentFromResultSet(appointment, rs);
                appointments.add(appointment);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return appointments;
    }

    public boolean updateAppointmentStatus(int appointmentId, String status) {
        boolean success = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE appointments SET status = ? WHERE id = ?")) {
            
            ps.setString(1, status);
            ps.setInt(2, appointmentId);
            success = ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }

    public boolean updateAppointment(Appointment appointment) {
        boolean success = false;
        String sql = "UPDATE appointments SET appointment_date=?, appointment_time=?, " +
                     "appointment_type=?, reason=?, notes=?, status=?, follow_up_required=? " +
                     "WHERE id=?";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, appointment.getAppointmentDate());
            ps.setTime(2, appointment.getAppointmentTime());
            ps.setString(3, appointment.getAppointmentType());
            ps.setString(4, appointment.getReason());
            ps.setString(5, appointment.getNotes());
            ps.setString(6, appointment.getStatus());
            ps.setBoolean(7, appointment.isFollowUpRequired());
            ps.setInt(8, appointment.getId()); 
            
            success = ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }

    public boolean cancelAppointment(int appointmentId) {
        boolean success = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE appointments SET status = 'Cancelled' WHERE id = ?")) {
            
            ps.setInt(1, appointmentId);
            success = ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }

    public boolean deleteAppointment(int appointmentId) {
        boolean success = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "DELETE FROM appointments WHERE id = ?")) {
            
            ps.setInt(1, appointmentId);
            success = ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }

    public boolean markFollowUpRequired(int appointmentId, boolean followUpRequired) {
        boolean success = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE appointments SET follow_up_required = ? WHERE id = ?")) {
            
            ps.setBoolean(1, followUpRequired);
            ps.setInt(2, appointmentId);
            success = ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }

    public int getTotalAppointments() {
        int count = 0;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT COUNT(*) FROM appointments");
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }
    
    public List<Appointment> getRecentAppointments(int limit) {
        List<Appointment> list = new ArrayList<>();
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT a.*, p.full_name as patient_name, d.full_name as doctor_name, d.specialization as doctor_specialization " +
                 "FROM appointments a " +
                 "JOIN patients p ON a.patient_id = p.id " +
                 "JOIN doctors d ON a.doctor_id = d.id " +
                 "ORDER BY a.created_at DESC LIMIT ?")) {
            
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment app = new Appointment();
                    mapAppointmentFromResultSet(app, rs);
                    list.add(app);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public int[] getAppointmentStats() {
        int[] stats = new int[5]; 
        try (Connection conn = DBConnect.getConn()) {
            
            String[] sqls = {
                "SELECT COUNT(*) FROM appointments",
                "SELECT COUNT(*) FROM appointments WHERE status = 'Pending'",
                "SELECT COUNT(*) FROM appointments WHERE status = 'Confirmed'",
                "SELECT COUNT(*) FROM appointments WHERE status = 'Completed'",
                "SELECT COUNT(*) FROM appointments WHERE status = 'Cancelled'"
            };
            
            for (int i = 0; i < sqls.length; i++) {
                try (PreparedStatement ps = conn.prepareStatement(sqls[i]);
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stats[i] = rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }
    
    // Get appointment statistics for admin dashboard
    public int[] getAdminAppointmentStats() {
        int[] stats = new int[5]; 
        try (Connection conn = DBConnect.getConn()) {
            
            String[] sqls = {
                "SELECT COUNT(*) FROM appointments",
                "SELECT COUNT(*) FROM appointments WHERE status = 'Pending'",
                "SELECT COUNT(*) FROM appointments WHERE status = 'Confirmed'",
                "SELECT COUNT(*) FROM appointments WHERE status = 'Completed'",
                "SELECT COUNT(*) FROM appointments WHERE status = 'Cancelled'"
            };
            
            for (int i = 0; i < sqls.length; i++) {
                try (PreparedStatement ps = conn.prepareStatement(sqls[i]);
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stats[i] = rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    // Get weekly appointment counts for dashboard charts
    public Map<String, Integer> getWeeklyAppointmentCounts() {
        Map<String, Integer> weeklyData = new LinkedHashMap<>();
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT DAYNAME(appointment_date) as day_name, COUNT(*) as count " +
                 "FROM appointments " +
                 "WHERE appointment_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 DAY) AND CURDATE() " +
                 "GROUP BY DAYNAME(appointment_date), DAYOFWEEK(appointment_date) " +
                 "ORDER BY DAYOFWEEK(appointment_date)")) {
            
            try (ResultSet rs = ps.executeQuery()) {
                // Initialize with all days in order
                String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};
                for (String day : days) {
                    weeklyData.put(day, 0);
                }
                
                // Update with actual data
                while (rs.next()) {
                    String dayName = rs.getString("day_name");
                    int count = rs.getInt("count");
                    weeklyData.put(dayName, count);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return weeklyData;
    }

    // Get today's appointments
    public List<Appointment> getTodaysAppointments() {
        List<Appointment> list = new ArrayList<>();
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT a.*, p.full_name as patient_name, d.full_name as doctor_name, d.specialization as doctor_specialization " +
                 "FROM appointments a " +
                 "JOIN patients p ON a.patient_id = p.id " +
                 "JOIN doctors d ON a.doctor_id = d.id " +
                 "WHERE DATE(a.appointment_date) = CURDATE() " +
                 "ORDER BY a.appointment_time ASC")) {
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment app = new Appointment();
                    mapAppointmentFromResultSet(app, rs);
                    list.add(app);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    
    public int[] getDoctorAppointmentStats(int doctorId) {
        int[] stats = new int[4]; 

        String sqlTotal = "SELECT COUNT(*) FROM appointments WHERE doctor_id = ?";
        String sqlPending = "SELECT COUNT(*) FROM appointments WHERE doctor_id = ? AND status = 'Pending'";
        String sqlConfirmed = "SELECT COUNT(*) FROM appointments WHERE doctor_id = ? AND status = 'Confirmed'";
        String sqlCompleted = "SELECT COUNT(*) FROM appointments WHERE doctor_id = ? AND status = 'Completed'";

        try (Connection conn = DBConnect.getConn()) {
            
            // 1. Get Total
            try (PreparedStatement ps = conn.prepareStatement(sqlTotal)) {
                ps.setInt(1, doctorId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stats[0] = rs.getInt(1);
                    }
                }
            }
            
            // 2. Get Pending
            try (PreparedStatement ps = conn.prepareStatement(sqlPending)) {
                ps.setInt(1, doctorId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stats[1] = rs.getInt(1);
                    }
                }
            }

            // 3. Get Confirmed
            try (PreparedStatement ps = conn.prepareStatement(sqlConfirmed)) {
                ps.setInt(1, doctorId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stats[2] = rs.getInt(1);
                    }
                }
            }

            // 4. Get Completed
            try (PreparedStatement ps = conn.prepareStatement(sqlCompleted)) {
                ps.setInt(1, doctorId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stats[3] = rs.getInt(1);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return stats;
    }


    // Get doctor appointment statistics for dashboard (This is your original method for the admin panel)
    public Map<String, Integer> getDoctorAppointmentStats() {
        Map<String, Integer> doctorStats = new LinkedHashMap<>();
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT d.full_name, d.specialization, COUNT(a.id) as appointment_count " +
                 "FROM doctors d " +
                 "LEFT JOIN appointments a ON d.id = a.doctor_id " +
                 "GROUP BY d.id, d.full_name, d.specialization " +
                 "ORDER BY appointment_count DESC " +
                 "LIMIT 5")) {
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String doctorInfo = rs.getString("full_name") + "|" + rs.getString("specialization");
                    int count = rs.getInt("appointment_count");
                    doctorStats.put(doctorInfo, count);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return doctorStats;
    }
    
    // Check if appointment time is available for doctor (ADDED FROM FILE 1)
    public boolean isAppointmentTimeAvailable(int doctorId, Date date, Time time) {
        boolean available = true;
        String sql = "SELECT id FROM appointments WHERE doctor_id = ? AND appointment_date = ? AND appointment_time = ? AND status IN ('Pending', 'Confirmed')";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, doctorId);
            ps.setDate(2, date);
            ps.setTime(3, time);
            
            try (ResultSet rs = ps.executeQuery()) {
                available = !rs.next(); 
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return available;
    }
    
    // Helper method to map ResultSet to Appointment object
    private void mapAppointmentFromResultSet(Appointment appointment, ResultSet rs) throws SQLException {
        appointment.setId(rs.getInt("id"));
        appointment.setPatientId(rs.getInt("patient_id"));
        appointment.setDoctorId(rs.getInt("doctor_id"));
        appointment.setAppointmentDate(rs.getDate("appointment_date"));
        appointment.setAppointmentTime(rs.getTime("appointment_time"));
        appointment.setAppointmentType(rs.getString("appointment_type"));
        appointment.setReason(rs.getString("reason"));
        appointment.setNotes(rs.getString("notes"));
        appointment.setStatus(rs.getString("status"));
        appointment.setFollowUpRequired(rs.getBoolean("follow_up_required"));
        appointment.setCreatedAt(rs.getTimestamp("created_at"));
        
        // These columns come from the JOINs
        if (rs.getMetaData().getColumnCount() > 12) {
            appointment.setPatientName(rs.getString("patient_name"));
            appointment.setDoctorName(rs.getString("doctor_name"));
            appointment.setDoctorSpecialization(rs.getString("doctor_specialization"));
        }
    }
}