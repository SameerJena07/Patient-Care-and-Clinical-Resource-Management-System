package com.servlet.patient;

import com.dao.ReviewDao;
import com.entity.DoctorReview;
import com.entity.Patient;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/patient/addReview")
public class AddReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        HttpSession session = req.getSession();
        Patient patient = (Patient) session.getAttribute("patientObj");
        
        if (patient == null) {
            session.setAttribute("errorMsg", "You must be logged in to leave a review.");
            resp.sendRedirect(req.getContextPath() + "/patient/login.jsp");
            return;
        }

        try {
            int appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
            int doctorId = Integer.parseInt(req.getParameter("doctorId"));
            int rating = Integer.parseInt(req.getParameter("rating"));
            String comment = req.getParameter("comment");
            
            DoctorReview review = new DoctorReview();
            review.setAppointmentId(appointmentId);
            review.setDoctorId(doctorId);
            review.setPatientId(patient.getId());
            review.setRating(rating);
            review.setComment(comment);
            
            ReviewDao dao = new ReviewDao();
            
            // Check if they already reviewed this appointment
            if (dao.hasPatientReviewed(appointmentId)) {
                session.setAttribute("errorMsg", "You have already submitted a review for this appointment.");
            } else {
                boolean f = dao.addReview(review);
                if (f) {
                    session.setAttribute("successMsg", "Thank you! Your feedback has been submitted.");
                } else {
                    session.setAttribute("errorMsg", "An error occurred. Please try again.");
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "An error occurred.");
        }
        
        resp.sendRedirect(req.getContextPath() + "/patient/appointment?action=view");
    }
}