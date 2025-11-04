package com.servlet.admin;

import com.dao.AdminDao;
import com.entity.Admin;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/profile")
public class AdminProfileServlet extends HttpServlet {
    private AdminDao adminDao;

    @Override
    public void init() throws ServletException {
        adminDao = new AdminDao();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        changePassword(request, response);
    }

    // Change admin password
    private void changePassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            HttpSession session = request.getSession();
            Admin admin = (Admin) session.getAttribute("adminObj");

            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            // Verify current password
            if (!admin.getPassword().equals(currentPassword)) {
                request.setAttribute("errorMsg", "Current password is incorrect.");
                request.getRequestDispatcher("profile.jsp").forward(request, response);
                return;
            }

            // Check if new password matches confirmation
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMsg", "New password and confirm password do not match.");
                request.getRequestDispatcher("profile.jsp").forward(request, response);
                return;
            }

            boolean success = adminDao.changePassword(admin.getId(), newPassword);

            if (success) {
                admin.setPassword(newPassword);
                session.setAttribute("adminObj", admin);
                request.setAttribute("successMsg", "Password changed successfully!");
            } else {
                request.setAttribute("errorMsg", "Failed to change password. Please try again.");
            }

            request.getRequestDispatcher("profile.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "An error occurred while changing password.");
            request.getRequestDispatcher("profile.jsp").forward(request, response);
        }
    }
}