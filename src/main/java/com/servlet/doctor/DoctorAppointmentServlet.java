package com.servlet.doctor;

import com.dao.AppointmentDao;
import com.entity.Appointment;
import com.entity.Doctor;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/doctor/appointment")
public class DoctorAppointmentServlet extends HttpServlet {
    private AppointmentDao appointmentDao;

    @Override
    public void init() throws ServletException {
        appointmentDao = new AppointmentDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("view".equals(action)) {
            viewAppointments(request, response);
        } else if ("details".equals(action)) {
            showAppointmentDetails(request, response);
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


    // View all appointments for doctor
    private void viewAppointments(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctorObj");
        
        List<Appointment> appointments = appointmentDao.getAppointmentsByDoctorId(doctor.getId());
        request.setAttribute("appointments", appointments);
        
        request.getRequestDispatcher("view_appointments.jsp").forward(request, response);
    }

    // Show appointment details
    private void showAppointmentDetails(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int appointmentId = Integer.parseInt(request.getParameter("id"));
            Appointment appointment = appointmentDao.getAppointmentById(appointmentId);
            
            if (appointment != null) {
                request.setAttribute("appointment", appointment);
                request.getRequestDispatcher("appointment_details.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMsg", "Appointment not found.");
                viewAppointments(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "Invalid appointment ID.");
            viewAppointments(request, response);
        }
    }
