package com.servlet.patient;

import com.dao.PatientDao;
import com.entity.Patient;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;

@WebServlet("/patient/auth")
public class PatientAuthServlet extends HttpServlet {
    private PatientDao patientDao;

    @Override
    public void init() throws ServletException {
        // Assume patientDao is correctly initialized here (e.g., gets a database connection)
        // Note: You should be initializing this with a connection/factory if not done in the constructor.
        // For the sake of the example, we keep the initialization as is.
        patientDao = new PatientDao();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("logout".equals(action)) {
            logoutPatient(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "This action is not supported via GET.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("register".equals(action)) {
            registerPatient(request, response);
        } else if ("login".equals(action)) {
            loginPatient(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action specified.");
        }
    }

    // Patient registration (No changes needed here based on the issue description)
    private void registerPatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String gender = request.getParameter("gender");
            String bloodGroup = request.getParameter("bloodGroup");
            Date dateOfBirth = Date.valueOf(request.getParameter("dateOfBirth"));
            String emergencyContact = request.getParameter("emergencyContact");
            String medicalHistory = request.getParameter("medicalHistory");

        
            if (patientDao.isEmailExists(email)) {
                request.setAttribute("errorMsg", "Email already exists. Please use a different email.");
        
                request.getRequestDispatcher("/patient/register.jsp").forward(request, response);
                return;
            }

            Patient patient = new Patient(fullName, email, password, phone, address,
                    gender, bloodGroup, dateOfBirth, emergencyContact, medicalHistory);

            boolean success = patientDao.registerPatient(patient);

            if (success) {
                HttpSession session = request.getSession();
                session.setAttribute("successMsg", "Registration Successful!");
                
                response.sendRedirect(request.getContextPath() + "/patient/login.jsp");
            } else {
                request.setAttribute("errorMsg", "Registration failed. Please try again.");
                request.getRequestDispatcher("/patient/register.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "An error occurred during registration: " + e.getMessage());
            request.getRequestDispatcher("/patient/register.jsp").forward(request, response);
        }
    }

    // *** FIX APPLIED HERE for successful redirection ***
    private void loginPatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String rememberMe = request.getParameter("rememberMe");

            Patient patient = patientDao.login(email, password);

            if (patient != null) {
                HttpSession session = request.getSession();
                // 1. Set the authenticated user object in the session
                session.setAttribute("patientObj", patient);
                
                // Handle "Remember Me" cookie (Adjusted for best practice: only store email)
                if ("on".equals(rememberMe)) {
                    // Set email cookie
                    Cookie emailCookie = new Cookie("patientEmail", email);
                    emailCookie.setMaxAge(7 * 24 * 60 * 60); // 7 days
                    emailCookie.setPath(request.getContextPath() + "/");
                    response.addCookie(emailCookie);
                    
                    // Clear the old password cookie if it exists
                    Cookie passwordCookie = new Cookie("patientPassword", "");
                    passwordCookie.setMaxAge(0);
                    passwordCookie.setPath(request.getContextPath() + "/");
                    response.addCookie(passwordCookie);
                } else {
                    // Clear both remember me cookies if 'rememberMe' is not checked
                    Cookie emailCookie = new Cookie("patientEmail", "");
                    Cookie passwordCookie = new Cookie("patientPassword", "");
                    emailCookie.setMaxAge(0);
                    passwordCookie.setMaxAge(0);
                    emailCookie.setPath(request.getContextPath() + "/");
                    passwordCookie.setPath(request.getContextPath() + "/");
                    response.addCookie(emailCookie);
                    response.addCookie(passwordCookie);
                }

                // 2. Correctly redirect to the patient dashboard
                // This line is essential for the redirection to happen.
                response.sendRedirect(request.getContextPath() + "/patient/dashboard.jsp"); 
            } else {
                request.setAttribute("errorMsg", "Invalid email or password");
                request.getRequestDispatcher("/patient/login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "An error occurred during login: " + e.getMessage());
            request.getRequestDispatcher("/patient/login.jsp").forward(request, response);
        }
    }

    // Patient logout (No changes needed here)
    private void logoutPatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            HttpSession session = request.getSession(false); 
            if (session != null) {
                session.removeAttribute("patientObj"); 
                session.invalidate(); 
            }

            Cookie emailCookie = new Cookie("patientEmail", "");
            Cookie passwordCookie = new Cookie("patientPassword", "");
            emailCookie.setMaxAge(0);
            passwordCookie.setMaxAge(0);
            emailCookie.setPath(request.getContextPath() + "/");
            passwordCookie.setPath(request.getContextPath() + "/");
            response.addCookie(emailCookie);
            response.addCookie(passwordCookie);

            response.sendRedirect(request.getContextPath() + "/index.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred during logout.");
        }
    }
}