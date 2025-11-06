package com.servlet.doctor;

import com.dao.AppointmentDao;
import com.dao.PrescriptionDao;
import com.entity.Doctor;
import com.entity.Prescription;
import com.entity.PrescriptionMedication;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;

@WebServlet("/doctor/addPrescription")
public class AddPrescriptionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        HttpSession session = req.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctorObj");
        
        if (doctor == null) {
            session.setAttribute("errorMsg", "You must be logged in as a doctor.");
            resp.sendRedirect(req.getContextPath() + "/doctor/login.jsp");
            return;
        }

        try {
            // --- FIX for NumberFormatException ---
            String appointmentIdStr = req.getParameter("appointmentId");
            if (appointmentIdStr == null || appointmentIdStr.trim().isEmpty()) {
                throw new NumberFormatException("Appointment ID was missing or empty.");
            }
            int appointmentId = Integer.parseInt(appointmentIdStr);
            // --- END FIX ---
            
            String diagnosis = req.getParameter("diagnosis");
            String adviceNotes = req.getParameter("adviceNotes");
            
            Date followUpDate = null;
            String followUpDateStr = req.getParameter("followUpDate");
            if (followUpDateStr != null && !followUpDateStr.isEmpty()) {
                followUpDate = Date.valueOf(followUpDateStr);
            }

            String[] medicineNames = req.getParameterValues("medicineName");
            String[] dosages = req.getParameterValues("dosage");
            String[] frequencies = req.getParameterValues("frequency");
            String[] durations = req.getParameterValues("duration");

            AppointmentDao apptDao = new AppointmentDao();
            PrescriptionDao prescriptionDao = new PrescriptionDao();

            // First, mark the appointment as "Completed"
            boolean apptSuccess = apptDao.updateAppointmentStatus(appointmentId, "Completed");

            if (apptSuccess) {
                // Create and save the main prescription
                Prescription prescription = new Prescription();
                prescription.setAppointmentId(appointmentId);
                prescription.setDiagnosis(diagnosis);
                prescription.setAdviceNotes(adviceNotes);
                prescription.setFollowUpDate(followUpDate);
                
                int prescriptionId = prescriptionDao.addPrescription(prescription);

                if (prescriptionId != -1) {
                    boolean allMedsSuccess = true;
                    if (medicineNames != null && medicineNames.length > 0) {
                        for (int i = 0; i < medicineNames.length; i++) {
                            if (medicineNames[i] != null && !medicineNames[i].trim().isEmpty()) {
                                PrescriptionMedication med = new PrescriptionMedication();
                                med.setPrescriptionId(prescriptionId);
                                med.setMedicineName(medicineNames[i]);
                                med.setDosage(dosages[i]);
                                med.setFrequency(frequencies[i]);
                                med.setDuration(durations[i]);
                                
                                if (!prescriptionDao.addMedication(med)) {
                                    allMedsSuccess = false; 
                                }
                            }
                        }
                    }

                    if (allMedsSuccess) {
                        session.setAttribute("successMsg", "Appointment completed and prescription saved!");
                    } else {
                        session.setAttribute("errorMsg", "Appointment completed, but an error occurred saving medications.");
                    }
                    
                } else {
                    session.setAttribute("errorMsg", "Appointment status updated, but failed to create prescription record.");
                }
            } else {
                session.setAttribute("errorMsg", "Failed to update appointment status.");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Error: Form was submitted without a valid Appointment ID.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "An error occurred: " + e.getMessage());
        }
        
        resp.sendRedirect(req.getContextPath() + "/doctor/appointment?action=view");
    }
}