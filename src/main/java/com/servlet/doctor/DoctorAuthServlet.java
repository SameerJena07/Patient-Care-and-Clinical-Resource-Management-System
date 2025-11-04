package com.servlet.doctor;

import com.dao.DoctorDao;
import com.entity.Doctor;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/doctor/auth")
public class DoctorAuthServlet extends HttpServlet {
    private DoctorDao doctorDao;

    @Override
    public void init() throws ServletException {
        doctorDao = new DoctorDao();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("register".equals(action)) {
            registerDoctor(request, response);
        } else if ("login".equals(action)) {
            loginDoctor(request, response);
        } else if ("logout".equals(action)) {
            logoutDoctor(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("logout".equals(action)) {
            logoutDoctor(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/doctor/login.jsp");
        }
    }
    // Doctor registration
    private void registerDoctor(HttpServletRequest request, HttpServletResponse response)
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

            // Check if email already exists
            if (doctorDao.isEmailExists(email)) {
                request.setAttribute("errorMsg", "Email already exists. Please use a different email.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            // Note: Doctor object constructor automatically sets isApproved=false (from Doctor.java)
            Doctor doctor = new Doctor(fullName, email, password, phone, specialization,
                    department, qualification, experience, visitingCharge);

            boolean success = doctorDao.registerDoctor(doctor);

            if (success) {
                // Set a message for the user after successful registration
                request.getSession().setAttribute("successMsg", "Registration successful. Your account is pending admin approval to Login");
                response.sendRedirect("login.jsp");
            } else {
                request.setAttribute("errorMsg", "Registration failed. Please try again.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "An error occurred during registration.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }