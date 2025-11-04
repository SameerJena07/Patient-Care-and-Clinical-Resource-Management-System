package com.servlet.admin;

import com.dao.AdminDao;
import com.entity.Admin;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/auth")
public class AdminAuthServlet extends HttpServlet {
    private AdminDao adminDao;

    // 1. Initialization: Instantiates the DAO once when the servlet starts.
    @Override
    public void init() throws ServletException {
        // Instantiate the DAO using the no-argument constructor
        adminDao = new AdminDao();
    }

    // 2. Handles POST requests (Login, Logout)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("login".equalsIgnoreCase(action)) {
            loginAdmin(request, response);
        } else if ("logout".equalsIgnoreCase(action)) {
            logoutAdmin(request, response);
        } else {
            // Default action if an unknown POST request comes in
            response.sendRedirect("login.jsp");
        }
    }

    // 3. Handles GET requests (primarily for Logout)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("logout".equalsIgnoreCase(action)) {
            logoutAdmin(request, response);
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    // Admin login logic
    private void loginAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            // Calls the correct login(String, String) method from the Dao
            Admin admin = adminDao.login(email, password);

            if (admin != null) {
                HttpSession session = request.getSession();
                session.setAttribute("adminObj", admin);
                response.sendRedirect("dashboard.jsp"); // Success redirect
            } else {
                // Failure: Set error message and forward back to login page
                request.setAttribute("errorMsg", "Invalid email or password");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            // Catch any unexpected exceptions (e.g., from DBConnect failure)
            e.printStackTrace();
            request.setAttribute("errorMsg", "An unexpected error occurred during login. Check server logs.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    // Admin logout logic
    private void logoutAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get existing session without creating a new one (false)
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate(); // Destroy the session
        }
        // Redirect to the context root (e.g., /PatientCareSystem/index.jsp)
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
}