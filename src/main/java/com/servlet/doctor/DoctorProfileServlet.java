package com.servlet.doctor;

import com.dao.DoctorDao;
import com.entity.Doctor;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/doctor/profile")
public class DoctorProfileServlet extends HttpServlet {
    private DoctorDao doctorDao;

    @Override
    public void init() throws ServletException {
        doctorDao = new DoctorDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Doctor doctor = (Doctor) session.getAttribute("doctorObj");
        
        if (doctor != null) {
            try {
                Doctor freshDoctor = doctorDao.getDoctorById(doctor.getId());
                session.setAttribute("doctorObj", freshDoctor);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");

        if ("update".equals(action)) {
            updateProfile(request, response); 
            
        } else if ("changePassword".equals(action)) {
            changePassword(request, response);
            
        } else {
            request.setAttribute("errorMsg", "Unknown action specified.");
            request.getRequestDispatcher("profile.jsp").forward(request, response);
        }
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            HttpSession session = request.getSession();
            Doctor doctor = (Doctor) session.getAttribute("doctorObj");
            
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String specialization = request.getParameter("specialization");
            String department = request.getParameter("department");
            String qualification = request.getParameter("qualification");
            int experience = Integer.parseInt(request.getParameter("experience"));
            double visitingCharge = Double.parseDouble(request.getParameter("visitingCharge"));
            boolean availability = "on".equals(request.getParameter("availability"));

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
                session.setAttribute("doctorObj", doctor);
                
                request.setAttribute("successMsg", "Profile updated successfully!");
            } else {
                request.setAttribute("errorMsg", "Failed to update profile. Please try again.");
            }

            request.getRequestDispatcher("profile.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "An error occurred while updating profile.");
            request.getRequestDispatcher("profile.jsp").forward(request, response);
        }
    }
