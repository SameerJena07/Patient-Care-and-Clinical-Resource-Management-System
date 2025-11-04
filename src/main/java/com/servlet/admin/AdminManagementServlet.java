package com.servlet.admin;

import com.dao.AppointmentDao;
import com.dao.DoctorDao;
import com.dao.PatientDao;
import com.entity.Appointment;
import com.entity.Doctor;
import com.entity.Patient;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;

@WebServlet("/admin/management")
public class AdminManagementServlet extends HttpServlet {
    private DoctorDao doctorDao;
    private PatientDao patientDao;
    private AppointmentDao appointmentDao;

    @Override
    public void init() throws ServletException {
        doctorDao = new DoctorDao();
        patientDao = new PatientDao();
        appointmentDao = new AppointmentDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String type = request.getParameter("type");

        if ("view".equals(action)) {
            if ("doctors".equals(type)) {
                viewDoctors(request, response);
            } else if ("patients".equals(type)) {
                viewPatients(request, response);
            } else if ("appointments".equals(type)) {
                viewAppointments(request, response);
            }
        } else if ("edit".equals(action)) {
            showEditForm(request, response);
        } else if ("view_details".equals(action) && "patient".equals(type)) {
            viewPatientDetails(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String type = request.getParameter("type");

        if ("add".equals(action)) {
            if ("doctor".equals(type)) {
                addDoctor(request, response);
            }
        } else if ("update".equals(action)) {
            if ("doctor".equals(type)) {
                updateDoctor(request, response);
            } else if ("patient".equals(type)) {
                updatePatient(request, response);
            } else if ("appointment".equals(type)) {
                updateAppointment(request, response);
            }

        } else if ("delete".equals(action)) {
            if ("doctor".equals(type)) {
                deleteDoctor(request, response);
            } else if ("patient".equals(type)) {
                deletePatient(request, response);
            } else if ("appointment".equals(type)) {
                deleteAppointment(request, response);
            }
        }
        // ▼▼▼ NEW APPROVAL BLOCK ▼▼▼
        else if ("approve".equals(action)) {
            if ("doctor".equals(type)) {
                approveDoctor(request, response);
            }
        }
        // ▲▲▲ END NEW APPROVAL BLOCK ▲▲▲
    }

    private void viewDoctors(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("doctors", doctorDao.getAllDoctors());
        request.getRequestDispatcher("/admin/manage_doctors.jsp").forward(request, response);
    }

    private void viewPatients(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("patients", patientDao.getAllPatients());
        request.getRequestDispatcher("/admin/manage_patients.jsp").forward(request, response);
    }

    private void viewAppointments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("appointments", appointmentDao.getAllAppointments()); // Assuming you have this method
        request.getRequestDispatcher("/admin/manage_appointments.jsp").forward(request, response);
    }

    private void viewPatientDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int patientId = Integer.parseInt(request.getParameter("id"));
            Patient patient = patientDao.getPatientById(patientId);

            if (patient != null) {
                request.setAttribute("patient", patient);
                RequestDispatcher rd = request.getRequestDispatcher("/admin/patient_details.jsp");
                rd.forward(request, response);
            } else {
                request.getSession().setAttribute("errorMsg", "Patient not found.");
                response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=patients");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Invalid Patient ID.");
            response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=patients");
        }
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int doctorId = Integer.parseInt(request.getParameter("id"));
            Doctor doctor = doctorDao.getDoctorById(doctorId);

            if (doctor != null) {
                request.setAttribute("doctor", doctor);
                request.getRequestDispatcher("/admin/edit_doctor.jsp").forward(request, response);
            } else {
                request.getSession().setAttribute("errorMsg", "Doctor not found.");
                response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=doctors");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Invalid doctor ID.");
            response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=doctors");
        }
    }

    private void addDoctor(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String phone = request.getParameter("phone");
            String specialization = request.getParameter("specialization");
            String department = request.getParameter("department");
            String qualification = request.getParameter("qualification");
            int experience = Integer.parseInt(request.getParameter("experience"));
            double visitingCharge = Double.parseDouble(request.getParameter("visitingCharge"));

            if (doctorDao.isEmailExists(email)) {
                request.getSession().setAttribute("errorMsg", "Email already exists. Please use a different email.");
                response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=doctors");
                return;
            }

            Doctor doctor = new Doctor(fullName, email, password, phone, specialization,
                    department, qualification, experience, visitingCharge);

            boolean success = doctorDao.registerDoctor(doctor);

            if (success) {
                // Doctor is registered but still requires approval
                request.getSession().setAttribute("successMsg", "Doctor registration received. Pending approval.");
            } else {
                request.getSession().setAttribute("errorMsg", "Failed to add doctor. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "An error occurred while adding doctor.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=doctors");
    }

    // ▼▼▼ NEW METHOD TO APPROVE A DOCTOR ▼▼▼
    private void approveDoctor(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int doctorId = Integer.parseInt(request.getParameter("id"));
            boolean success = doctorDao.approveDoctor(doctorId); // Assume this method exists in DoctorDao

            if (success) {
                request.getSession().setAttribute("successMsg", "Doctor successfully approved and allowed to log in.");
            } else {
                request.getSession().setAttribute("errorMsg", "Failed to approve doctor. Please try again.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Invalid doctor ID for approval.");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "An error occurred during doctor approval.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=doctors");
    }
    // ▲▲▲ END NEW METHOD ▲▲▲

    private void updateDoctor(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int doctorId = Integer.parseInt(request.getParameter("doctorId"));
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String specialization = request.getParameter("specialization");
            String department = request.getParameter("department");
            String qualification = request.getParameter("qualification");
            int experience = Integer.parseInt(request.getParameter("experience"));
            double visitingCharge = Double.parseDouble(request.getParameter("visitingCharge"));

            boolean availability = "true".equals(request.getParameter("availability"));

            Doctor doctor = doctorDao.getDoctorById(doctorId);
            if (doctor != null) {
                doctor.setFullName(fullName);
                doctor.setPhone(phone);
                doctor.setSpecialization(specialization);
                doctor.setDepartment(department);
                doctor.setQualification(qualification);
                doctor.setExperience(experience);
                doctor.setVisitingCharge(visitingCharge);
                doctor.setAvailability(availability);

                boolean success = doctorDao.updateDoctor(doctor);

                if (success) {
                    request.getSession().setAttribute("successMsg", "Doctor updated successfully!");
                } else {
                    request.getSession().setAttribute("errorMsg", "Failed to update doctor. Please try again.");
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Doctor not found.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "An error occurred while updating doctor.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=doctors");
    }

    private void updatePatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int patientId = Integer.parseInt(request.getParameter("patientId"));
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String gender = request.getParameter("gender");
            String address = request.getParameter("address");
            String bloodGroup = request.getParameter("bloodGroup");
            String dobString = request.getParameter("dateOfBirth");
            String emergencyContact = request.getParameter("emergencyContact");
            String medicalHistory = request.getParameter("medicalHistory");

            java.sql.Date dateOfBirth = null;
            if (dobString != null && !dobString.isEmpty()) {
                dateOfBirth = java.sql.Date.valueOf(dobString);
            }

            Patient patient = patientDao.getPatientById(patientId);

            if (patient != null) {
                patient.setFullName(fullName);
                patient.setPhone(phone);
                patient.setGender(gender);
                patient.setAddress(address);
                patient.setBloodGroup(bloodGroup);
                patient.setDateOfBirth(dateOfBirth);
                patient.setEmergencyContact(emergencyContact);
                patient.setMedicalHistory(medicalHistory);

                boolean success = patientDao.updatePatient(patient);

                if (success) {
                    // ▼▼▼ THIS IS THE LINE YOU REQUESTED TO CHANGE ▼▼▼
                    request.getSession().setAttribute("successMsg", "Updated successful!");
                } else {
                    request.getSession().setAttribute("errorMsg", "Failed to update patient. Please try again.");
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Patient not found.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "An error occurred while updating patient.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=patients");
    }

    private void updateAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");
            String appointmentType = request.getParameter("appointmentType");
            String dateString = request.getParameter("appointmentDate");
            String timeString = request.getParameter("appointmentTime");
            String reason = request.getParameter("reason");
            String notes = request.getParameter("notes");
            boolean followUpRequired = "on".equals(request.getParameter("followUpRequired"));

            Date appointmentDate = null;
            if (dateString != null && !dateString.isEmpty()) {
                appointmentDate = Date.valueOf(dateString);
            }

            Time appointmentTime = null;
            if (timeString != null && !timeString.isEmpty()) {
                if (timeString.length() == 5) {
                    timeString += ":00";
                }
                appointmentTime = Time.valueOf(timeString);
            }

            Appointment appt = appointmentDao.getAppointmentById(id);

            if (appt != null) {
                appt.setStatus(status);
                appt.setAppointmentType(appointmentType);
                appt.setAppointmentDate(appointmentDate);
                appt.setAppointmentTime(appointmentTime);
                appt.setReason(reason);
                appt.setNotes(notes);
                appt.setFollowUpRequired(followUpRequired);

                boolean success = appointmentDao.updateAppointment(appt);

                if (success) {
                    request.getSession().setAttribute("successMsg", "Appointment #" + id + " updated successfully!");
                } else {
                    request.getSession().setAttribute("errorMsg", "Failed to update appointment. Please try again.");
                }
            } else {
                request.getSession().setAttribute("errorMsg", "Appointment not found.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg",
                    "An error occurred while updating appointment. Check date/time format.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=appointments");
    }

    private void deleteDoctor(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int doctorId = Integer.parseInt(request.getParameter("id"));
            boolean success = doctorDao.deleteDoctor(doctorId);

            if (success) {
                request.getSession().setAttribute("successMsg", "Doctor deleted successfully!");
            } else {
                request.getSession().setAttribute("errorMsg", "Failed to delete doctor. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "An error occurred while deleting doctor.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=doctors");
    }

    private void deletePatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int patientId = Integer.parseInt(request.getParameter("id"));

            // --- SAFETY STUB ---
            // Deleting patients can be dangerous due to foreign key constraints
            // (e.g., appointments). This stub prevents accidental deletion.
            // To implement, you would need to handle (or cascade) deleting
            // all related appointments first.

            // boolean success = patientDao.deletePatient(patientId);
            // if(success) ...

            request.getSession().setAttribute("errorMsg", "Patient deletion is not enabled for safety reasons.");

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "An error occurred while processing request.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=patients");
    }

    private void deleteAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int appointmentId = Integer.parseInt(request.getParameter("id"));
            boolean success = appointmentDao.deleteAppointment(appointmentId);

            if (success) {
                request.getSession().setAttribute("successMsg", "Appointment deleted successfully!");
            } else {
                request.getSession().setAttribute("errorMsg", "Failed to delete appointment. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "An error occurred while deleting appointment.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/management?action=view&type=appointments");
    }
}