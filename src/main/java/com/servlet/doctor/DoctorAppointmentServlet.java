package com.servlet.doctor;

import com.dao.AppointmentDao;
import com.dao.PrescriptionDao; 
import com.entity.Appointment;
import com.entity.Doctor;
import com.entity.Prescription; 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashMap; 
import java.util.List;
import java.util.Map; 

@WebServlet("/doctor/appointment")
public class DoctorAppointmentServlet extends HttpServlet {
    private AppointmentDao appointmentDao;
    private PrescriptionDao prescriptionDao; // --- NEW DAO ---

    @Override
    public void init() throws ServletException {
        appointmentDao = new AppointmentDao();
        prescriptionDao = new PrescriptionDao(); // --- NEW DAO ---
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("view".equals(action)) {
            viewAppointments(request, response);
        } else if ("details".equals(action)) {
            showAppointmentDetails(request, response);
        } else if ("prescription".equals(action)) { // --- NEW ACTION ---
            showPrescriptionDetails(request, response);
        } else {
            viewAppointments(request, response); // Default action
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("updateStatus".equals(action)) {
            updateAppointmentStatus(request, response);
        } else if ("updateFollowUp".equals(action)) {
            updateFollowUpStatus(request, response);
        }
    }

    private void viewAppointments(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctorObj");
        
        if (doctor == null) {
            session.setAttribute("errorMsg", "Session expired. Please login again.");
            response.sendRedirect(request.getContextPath() + "/doctor/login.jsp");
            return;
        }

        List<Appointment> appointments = appointmentDao.getAppointmentsByDoctorId(doctor.getId());
        
        Map<Integer, Prescription> prescriptionMap = new HashMap<>();
        for (Appointment appt : appointments) {
            if ("Completed".equals(appt.getStatus())) {
                Prescription p = prescriptionDao.getPrescriptionByAppointmentId(appt.getId());
                if (p != null) {
                    prescriptionMap.put(appt.getId(), p);
                }
            }
        }
        
        request.setAttribute("appointments", appointments);
        request.setAttribute("prescriptionMap", prescriptionMap); 
        
        request.getRequestDispatcher("view_appointments.jsp").forward(request, response);
    }

    // --- THIS IS YOUR ORIGINAL METHOD, NOW FIXED ---
    private void showAppointmentDetails(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int appointmentId = Integer.parseInt(request.getParameter("id"));
            Appointment appointment = appointmentDao.getAppointmentById(appointmentId);
            
            if (appointment != null) {
                request.setAttribute("appointment", appointment);
                // This correctly points to your existing details page
                request.getRequestDispatcher("appointment_details.jsp").forward(request, response);
            } else {
                session.setAttribute("errorMsg", "Appointment not found.");
                response.sendRedirect(request.getContextPath() + "/doctor/appointment?action=view");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Invalid appointment ID.");
            response.sendRedirect(request.getContextPath() + "/doctor/appointment?action=view");
        }
    }

    // --- NEW METHOD FOR PRESCRIPTION ---
    private void showPrescriptionDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int appointmentId = Integer.parseInt(request.getParameter("id"));
            Appointment appointment = appointmentDao.getAppointmentById(appointmentId);
            Prescription prescription = prescriptionDao.getPrescriptionByAppointmentId(appointmentId);

            if (appointment != null && prescription != null) {
                // Also get the list of medicines
                prescription.setMedications(prescriptionDao.getMedicationsByPrescriptionId(prescription.getPrescriptionId()));
                
                request.setAttribute("appointment", appointment);
                request.setAttribute("prescription", prescription);
                
                // This points to the new prescription details page
                request.getRequestDispatcher("prescription_details.jsp").forward(request, response);
            } else {
                session.setAttribute("errorMsg", "Prescription not found.");
                response.sendRedirect(request.getContextPath() + "/doctor/appointment?action=view");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Invalid ID.");
            response.sendRedirect(request.getContextPath() + "/doctor/appointment?action=view");
        }
    }


    private void updateAppointmentStatus(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            String status = request.getParameter("status");
            
            if ("Completed".equals(status)) {
                 session.setAttribute("errorMsg", "Please use the 'Mark as Completed' button to add a prescription.");
                 response.sendRedirect(request.getContextPath() + "/doctor/appointment?action=view");
                 return;
            }
            
            boolean success = appointmentDao.updateAppointmentStatus(appointmentId, status);
            
            if (success) {
                session.setAttribute("successMsg", "Appointment status updated successfully!");
            } else {
                session.setAttribute("errorMsg", "Failed to update appointment status.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "An error occurred while updating appointment status.");
        }
        
        response.sendRedirect(request.getContextPath() + "/doctor/appointment?action=view");
    }

    private void updateFollowUpStatus(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            boolean followUpRequired = "on".equals(request.getParameter("followUpRequired"));
            
            boolean success = appointmentDao.markFollowUpRequired(appointmentId, followUpRequired);
            
            if (success) {
                session.setAttribute("successMsg", "Follow-up status updated successfully!");
            } else {
                session.setAttribute("errorMsg", "Failed to update follow-up status.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "An error occurred while updating follow-up status.");
        }
        
        response.sendRedirect(request.getContextPath() + "/doctor/appointment?action=view");
    }
}