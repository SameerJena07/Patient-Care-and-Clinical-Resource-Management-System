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
