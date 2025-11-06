package com.servlet.patient;

import com.dao.AppointmentDao;
import com.dao.DoctorDao;
import com.dao.PrescriptionDao; 
import com.dao.ReviewDao; // --- NEW IMPORT ---
import com.entity.Appointment;
import com.entity.Patient;
import com.entity.Prescription; 
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.HashMap; 
import java.util.HashSet; // --- NEW IMPORT ---
import java.util.List;
import java.util.Map; 
import java.util.Set; // --- NEW IMPORT ---

@WebServlet("/patient/appointment")
public class PatientAppointmentServlet extends HttpServlet {
    private AppointmentDao appointmentDao;
    private DoctorDao doctorDao;
    private PrescriptionDao prescriptionDao; 
    private ReviewDao reviewDao; // --- NEW DAO ---

    @Override
    public void init() throws ServletException {
        appointmentDao = new AppointmentDao();
        doctorDao = new DoctorDao();
        prescriptionDao = new PrescriptionDao(); 
        reviewDao = new ReviewDao(); // --- NEW DAO ---
    }

    private Patient checkPatientSession(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        Patient patient = (Patient) session.getAttribute("patientObj");
        
        if (patient == null) {
            session.setAttribute("errorMsg", "You must be logged in to access this page.");
            response.sendRedirect(request.getContextPath() + "/patient/login.jsp");
            return null;
        }
        return patient; 
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Patient patient = checkPatientSession(request, response);
        if (patient == null) {
            return; 
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "view"; 
        }

        switch (action) {
            case "view":
                viewAppointments(request, response, patient);
                break;
            case "book":
                showBookAppointmentForm(request, response);
                break;
            case "edit":
                showEditAppointmentForm(request, response, patient);
                break;
            case "details":
                showAppointmentDetails(request, response, patient); // This is for your existing page
                break;
            case "prescription": 
                showPrescriptionDetails(request, response, patient);
                break;
            default:
                viewAppointments(request, response, patient);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Patient patient = checkPatientSession(request, response);
        if (patient == null) {
            return; 
        }
        
        String action = request.getParameter("action");

        switch (action) {
            case "book":
                bookAppointment(request, response, patient);
                break;
            case "update":
                updateAppointment(request, response, patient);
                break;
            case "cancel":
                cancelAppointment(request, response, patient);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
                break;
        }
    }

    // --- THIS METHOD IS UPDATED ---
    private void viewAppointments(HttpServletRequest request, HttpServletResponse response, Patient patient)
            throws ServletException, IOException {

        // 1. Get appointments
        List<Appointment> appointments = appointmentDao.getAppointmentsByPatientId(patient.getId());
        
        // 2. Get prescriptions for completed appointments
        Map<Integer, Prescription> prescriptionMap = new HashMap<>();
        
        // 3. --- NEW: Get set of reviewed appointment IDs ---
        Set<Integer> reviewedAppointmentIds = new HashSet<>();
        
        for (Appointment appt : appointments) {
            if ("Completed".equals(appt.getStatus())) {
                // Check for prescription
                Prescription p = prescriptionDao.getPrescriptionByAppointmentId(appt.getId());
                if (p != null) {
                    prescriptionMap.put(appt.getId(), p);
                }
                
                // --- NEW: Check if reviewed ---
                if (reviewDao.hasPatientReviewed(appt.getId())) {
                    reviewedAppointmentIds.add(appt.getId());
                }
            }
        }
        
        // 4. Pass all data to the JSP
        request.setAttribute("appointments", appointments);
        request.setAttribute("prescriptionMap", prescriptionMap); 
        request.setAttribute("reviewedIds", reviewedAppointmentIds); // --- NEW ATTRIBUTE ---
        
        request.getRequestDispatcher("view_appointments.jsp").forward(request, response);
    }

    private void showBookAppointmentForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setAttribute("doctors", doctorDao.getAllDoctors());
        request.getRequestDispatcher("book_appointment.jsp").forward(request, response);
    }

    private void showEditAppointmentForm(HttpServletRequest request, HttpServletResponse response, Patient patient)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int appointmentId = Integer.parseInt(request.getParameter("id"));
            Appointment appointment = appointmentDao.getAppointmentById(appointmentId);

            if (appointment == null) {
                session.setAttribute("errorMsg", "Appointment not found.");
                response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
                return;
            }

            if (appointment.getPatientId() != patient.getId()) {
                session.setAttribute("errorMsg", "Access denied. You can only edit your own appointments.");
                response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
                return;
            }

            String status = appointment.getStatus();
            if (status == null) status = "Pending"; 
            
            if (!status.equalsIgnoreCase("Pending")) {
                session.setAttribute("errorMsg", "This appointment is already " + status + " and cannot be edited.");
                response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
                return;
            }

            request.setAttribute("appointment", appointment);
            request.setAttribute("doctors", doctorDao.getAllDoctors());
            request.getRequestDispatcher("edit_appointment.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Invalid appointment ID.");
            response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
        }
    }

    private void showAppointmentDetails(HttpServletRequest request, HttpServletResponse response, Patient patient)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int appointmentId = Integer.parseInt(request.getParameter("id"));
            Appointment appointment = appointmentDao.getAppointmentById(appointmentId);

            if (appointment == null) {
                session.setAttribute("errorMsg", "Appointment not found.");
                response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
                return;
            }
            
            if (appointment.getPatientId() != patient.getId()) {
                session.setAttribute("errorMsg", "Access denied. You can only view your own appointments.");
                response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
                return;
            }

            request.setAttribute("appointment", appointment);
            request.getRequestDispatcher("appointment_details.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Invalid appointment ID.");
            response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
        }
    }

    private void showPrescriptionDetails(HttpServletRequest request, HttpServletResponse response, Patient patient)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int appointmentId = Integer.parseInt(request.getParameter("id"));
            Appointment appointment = appointmentDao.getAppointmentById(appointmentId);
            Prescription prescription = prescriptionDao.getPrescriptionByAppointmentId(appointmentId);

            if (appointment == null || prescription == null || appointment.getPatientId() != patient.getId()) {
                session.setAttribute("errorMsg", "Prescription not found or access denied.");
                response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
                return;
            }
            
            // Also get the list of medicines
            prescription.setMedications(prescriptionDao.getMedicationsByPrescriptionId(prescription.getPrescriptionId()));
            
            request.setAttribute("appointment", appointment);
            request.setAttribute("prescription", prescription);
            
            // This points to the new prescription details page
            request.getRequestDispatcher("prescription_details.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Invalid ID.");
            response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
        }
    }


    private void bookAppointment(HttpServletRequest request, HttpServletResponse response, Patient patient)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int doctorId = Integer.parseInt(request.getParameter("doctorId"));
            Date appointmentDate = Date.valueOf(request.getParameter("appointmentDate"));
            Time appointmentTime = Time.valueOf(request.getParameter("appointmentTime") + ":00");
            String appointmentType = request.getParameter("appointmentType");
            String reason = request.getParameter("reason");
            String notes = request.getParameter("notes");

            Appointment appointment = new Appointment(patient.getId(), doctorId, appointmentDate,
                    appointmentTime, appointmentType, reason, notes);

            boolean success = appointmentDao.bookAppointment(appointment);

            if (success) {
                session.setAttribute("successMsg", "Appointment booked successfully!");
            } else {
                session.setAttribute("errorMsg", "Failed to book appointment. Please try again.");
            }
            response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "An error occurred while booking appointment.");

            response.sendRedirect(request.getContextPath() + "/patient/appointment?action=book");
        }
    }

    private void updateAppointment(HttpServletRequest request, HttpServletResponse response, Patient patient)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));

            Appointment existingAppointment = appointmentDao.getAppointmentById(appointmentId);
            if (existingAppointment == null || existingAppointment.getPatientId() != patient.getId()) {
                session.setAttribute("errorMsg", "Security error: You do not have permission to update this appointment.");
                response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
                return;
            }

            Date appointmentDate = Date.valueOf(request.getParameter("appointmentDate"));
            Time appointmentTime = Time.valueOf(request.getParameter("appointmentTime") + ":00");
            String appointmentType = request.getParameter("appointmentType");
            String reason = request.getParameter("reason");
            String notes = request.getParameter("notes");
            
            // Re-fetch the existing appointment to ensure we don't overwrite status
            Appointment appointmentToUpdate = appointmentDao.getAppointmentById(appointmentId);
            
            // Only update fields the patient is allowed to change
            appointmentToUpdate.setAppointmentDate(appointmentDate);
            appointmentToUpdate.setAppointmentTime(appointmentTime);
            appointmentToUpdate.setAppointmentType(appointmentType);
            appointmentToUpdate.setReason(reason);
            appointmentToUpdate.setNotes(notes);

            boolean success = appointmentDao.updateAppointment(appointmentToUpdate); 

            if (success) {
                session.setAttribute("successMsg", "Appointment updated successfully!");
            } else {
                session.setAttribute("errorMsg", "Failed to update appointment. Please try again.");
            }
            response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "An error occurred while updating appointment.");
            String apptId = request.getParameter("appointmentId");
            response.sendRedirect(request.getContextPath() + "/patient/appointment?action=edit&id=" + apptId);
        }
    }

    private void cancelAppointment(HttpServletRequest request, HttpServletResponse response, Patient patient)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        try {
            int appointmentId = Integer.parseInt(request.getParameter("id"));

            Appointment existingAppointment = appointmentDao.getAppointmentById(appointmentId);
            if (existingAppointment == null || existingAppointment.getPatientId() != patient.getId()) {
                session.setAttribute("errorMsg", "Security error: You do not have permission to cancel this appointment.");
                response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
                return;
            }
            
            boolean success = appointmentDao.cancelAppointment(appointmentId);

            if (success) {
                session.setAttribute("successMsg", "Appointment cancelled successfully!");
            } else {
                session.setAttribute("errorMsg", "Failed to cancel appointment. Please try again.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "An error occurred while cancelling appointment.");
        }

        response.sendRedirect(request.getContextPath() + "/patient/appointment?action=view");
    }
}