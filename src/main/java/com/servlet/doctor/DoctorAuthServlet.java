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

            Doctor doctor = new Doctor(fullName, email, password, phone, specialization,
                    department, qualification, experience, visitingCharge);

            boolean success = doctorDao.registerDoctor(doctor);

            if (success) {
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

    // Doctor login
    private void loginDoctor(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String rememberMe = request.getParameter("rememberMe");

            Doctor doctor = doctorDao.login(email, password);

            if (doctor != null) {
                HttpSession session = request.getSession();
                session.setAttribute("doctorObj", doctor);

                // Remember Me cookies
                if ("on".equals(rememberMe)) {
                    Cookie emailCookie = new Cookie("doctorEmail", email);
                    Cookie passwordCookie = new Cookie("doctorPassword", password);
                    emailCookie.setMaxAge(7 * 24 * 60 * 60);
                    passwordCookie.setMaxAge(7 * 24 * 60 * 60);
                    response.addCookie(emailCookie);
                    response.addCookie(passwordCookie);
                } else {
                    Cookie emailCookie = new Cookie("doctorEmail", "");
                    Cookie passwordCookie = new Cookie("doctorPassword", "");
                    emailCookie.setMaxAge(0);
                    passwordCookie.setMaxAge(0);
                    response.addCookie(emailCookie);
                    response.addCookie(passwordCookie);
                }

                response.sendRedirect("dashboard.jsp");
            } else {
                request.setAttribute("errorMsg", "Invalid email or password");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "An error occurred during login.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    // Doctor logout 
    private void logoutDoctor(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute("doctorObj");
            session.invalidate();
        }

        // Clear cookies
        Cookie emailCookie = new Cookie("doctorEmail", "");
        Cookie passwordCookie = new Cookie("doctorPassword", "");
        emailCookie.setMaxAge(0);
        passwordCookie.setMaxAge(0);
        response.addCookie(emailCookie);
        response.addCookie(passwordCookie);
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
}
