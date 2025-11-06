<%@ page import="com.entity.Doctor" %>
<%@ page import="com.dao.AppointmentDao" %>
<%@ page import="java.util.List" %>
<%@ page import="com.entity.Appointment" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="com.dao.PatientDao" %>
<%@ page import="com.entity.Patient" %>
<%@ page import="com.dao.ReviewDao" %> <%-- --- NEW IMPORT --- --%>
<%@ page import="com.entity.DoctorReview" %> <%-- --- NEW IMPORT --- --%>
<%
    // Renamed 'doctor' to 'currentDoctor' for clarity
    Doctor currentDoctor = (Doctor) session.getAttribute("doctorObj");
    if (currentDoctor == null) {
        response.sendRedirect(request.getContextPath() + "/doctor/login.jsp"); // Added context path
        return;
    }

    AppointmentDao appointmentDao = new AppointmentDao();
    List<Appointment> appointments = appointmentDao.getAppointmentsByDoctorId(currentDoctor.getId());
    int[] stats = appointmentDao.getDoctorAppointmentStats(currentDoctor.getId());

    // Get recent appointments (handle potential empty list)
    List<Appointment> recentAppointments = appointments.isEmpty() ?
                                            new java.util.ArrayList<>() :
                                            appointments.subList(0, Math.min(10, appointments.size())); // Increased to 10

    // Variable needed for the sidebar's logout button
    String currentUserRole = "doctor";
    
    // --- NEW: Get Feedback & Rating Data ---
    ReviewDao reviewDao = new ReviewDao();
    List<DoctorReview> reviewList = reviewDao.getReviewsByDoctorId(currentDoctor.getId());
    double averageRating = reviewDao.getAverageRatingByDoctorId(currentDoctor.getId());
    String formattedRating = String.format("%.1f", averageRating); // Format to one decimal place
    int totalReviews = reviewList.size();
    
    PatientDao patientDao = new PatientDao(); // To get patient names for reviews
    // --- END NEW DATA ---
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Care System - Doctor Dashboard</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

     
</head>
<body>
    <button class="mobile-menu-toggle" id="mobileMenuToggle" style="display: none;">
        <i class="fas fa-bars"></i>
    </button>
    
    <div class="sidebar" id="sidebar">
        <!-- ... (Sidebar HTML remains unchanged) ... -->
        <div class="sidebar-sticky">
            <div class="user-section">
                <div class="user-avatar">
                    <i class="fas fa-user-md"></i>
                </div>
                <div class="user-info">
                    <% if (currentDoctor != null) { %>
                    <h6>Dr. <%= currentDoctor.getFullName() %></h6>
                    <span class="badge">Doctor</span>
                    <% } %>
                </div>
            </div>
            
            <div class="nav-main">
                <ul class="nav">
                    <li class="nav-item">
                        <a class="nav-link <%= request.getRequestURI().contains("dashboard.jsp") ? "active" : "" %>" 
                           href="${pageContext.request.contextPath}/doctor/dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <%= request.getRequestURI().contains("profile") ? "active" : "" %>" 
                           href="${pageContext.request.contextPath}/doctor/profile">
                            <i class="fas fa-user"></i>
                            <span>My Profile</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <%= request.getRequestURI().contains("change_password") ? "active" : "" %>" 
                           href="${pageContext.request.contextPath}/doctor/change_password.jsp">
                            <i class="fas fa-key"></i>
                            <span>Change Password</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <%= request.getRequestURI().contains("appointment") ? "active" : "" %>" 
                           href="${pageContext.request.contextPath}/doctor/appointment?action=view">
                            <i class="fas fa-list-alt"></i>
                            <span>My Appointments</span>
                        </a>
                    </li>
                </ul>
            </div>
            
            <div class="nav-bottom">
                 <ul class="nav">
                     <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/index.jsp">
                            <i class="fas fa-home"></i>
                            <span>Back to Home</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link nav-link-logout" href="${pageContext.request.contextPath}/<%= currentUserRole %>/auth?action=logout">
                            <i class="fas fa-sign-out-alt"></i>
                            <span>Logout</span>
                        </a>
                    </li>
                 </ul>
            </div>
        </div>
    </div>
    
    <main class="main-content main-content-flush">
        <div class="dashboard-header">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="h2 mb-2">
                        <i class="fas fa-tachometer-alt me-2"></i>
                        Doctor Dashboard
                    </h1>
                    <p class="mb-0 opacity-75">Welcome to your practice management dashboard</p>
                </div>
                <div>
                    <span class="welcome-badge">
                        <i class="fas fa-user-md me-2"></i>Dr. <%= currentDoctor.getFullName() %>
                    </span>
                </div>
            </div>
        </div>

        <div class="dashboard-body">
            <div class="row mb-4">
                <!-- ... (Stats Cards remain unchanged) ... -->
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-total">
                        <i class="fas fa-calendar-check"></i>
                        <div>
                            <div class="number"><%= stats[0] %></div>
                            <div class="label">Total Appointments</div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-pending">
                        <i class="fas fa-clock"></i>
                         <div>
                            <div class="number"><%= stats[1] %></div>
                            <div class="label">Pending</div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-confirmed">
                        <i class="fas fa-check-circle"></i>
                         <div>
                            <div class="number"><%= stats[2] %></div>
                            <div class="label">Confirmed</div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-completed">
                        <i class="fas fa-calendar-check"></i>
                        <div>
                            <div class="number"><%= stats[3] %></div>
                            <div class="label">Completed</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-8 mb-4">
                    <div class="card card-modern recent-appointments-section"> 
                        <!-- ... (Recent Appointments Card content remains unchanged) ... -->
                        <div class="card-header-modern d-flex justify-content-between align-items-center">
                            <div>
                                <i class="fas fa-list-alt"></i>
                                <span>Recent Appointments</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/doctor/appointment?action=view" class="btn btn-sm btn-primary">
                                <i class="fas fa-eye me-1"></i>View All
                            </a>
                        </div>
                        <div class="card-body p-4">
                            <%
                                if (appointments.isEmpty()) {
                            %>
                                <div class="text-center py-4">
                                    <i class="fas fa-calendar-times fa-3x text-muted mb-3"></i>
                                    <h5 class="text-muted">No Appointments Yet</h5>
                                    <p class="text-muted">You don't have any appointments scheduled.</p>
                                </div>
                            <%
                                } else {
                            %>
                                <div class="table-responsive recent-appointments-table"> <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Patient</th>
                                                <th>Date & Time</th>
                                                <th>Type</th>
                                                <th>Status</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                for (Appointment app : recentAppointments) {
                                                    String status = app.getStatus();
                                                    if (status == null) {
                                                        status = "Pending";
                                                    }
                                                    String statusBadgeClass;
                                                    switch (status) {
                                                        case "Pending": statusBadgeClass = "badge-pending"; break;
                                                        case "Confirmed": statusBadgeClass = "badge-confirmed"; break;
                                                        case "Completed": statusBadgeClass = "badge-completed"; break;
                                                        case "Cancelled": statusBadgeClass = "badge-cancelled"; break;
                                                        default: statusBadgeClass = "badge-secondary"; break;
                                                    }
                                            %>
                                                <tr>
                                                    <td>
                                                        <strong><%= app.getPatientName() %></strong><br>
                                                        <small class="text-muted">ID: PAT<%= app.getPatientId() %></small>
                                                    </td>
                                                    <td>
                                                        <strong><%= app.getAppointmentDate() %></strong><br>
                                                        <small class="text-muted"><%= app.getAppointmentTime() %></small>
                                                    </td>
                                                    <td>
                                                        <span class="badge bg-light text-dark"><%= app.getAppointmentType() %></span>
                                                    </td>
                                                    <td>
                                                        <span class="badge <%= statusBadgeClass %>">
                                                            <%= status %>
                                                        </span>
                                                        <%
                                                            if (app.isFollowUpRequired()) {
                                                        %>
                                                            <br>
                                                            <small class="text-warning d-block mt-1">
                                                                <i class="fas fa-redo me-1"></i>Follow-up
                                                            </small>
                                                        <%
                                                            }
                                                        %>
                                                    </td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/doctor/appointment?action=details&id=<%= app.getId() %>"
                                                           class="btn btn-sm btn-outline-primary">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                    </td>
                                                </tr>
                                            <%
                                                } // End of for loop
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            <%
                                }
                            %>
                        </div>
                    </div>
                    
                    
                    <!-- --- NEW: Patient Feedback List --- -->
                    <div class="card card-modern recent-appointments-section mt-4">
                        <div class="card-header-modern">
                            <i class="fas fa-comments"></i>
                            <span>Recent Patient Feedback</span>
                        </div>
                        <div class="card-body p-4" style="max-height: 400px; overflow-y: auto;">
                            <% if (reviewList.isEmpty()) { %>
                                <div class="text-center py-3">
                                    <i class="fas fa-comment-slash fa-3x text-muted mb-3"></i>
                                    <h5 class="text-muted">No Feedback Yet</h5>
                                    <p class="text-muted mb-0">You have not received any patient feedback.</p>
                                </div>
                            <% } else { 
                                for (DoctorReview review : reviewList) {
                                    Patient reviewPatient = patientDao.getPatientById(review.getPatientId());
                                    String patientName = (reviewPatient != null) ? reviewPatient.getFullName() : "A Patient";
                            %>
                                <div class="d-flex mb-3">
                                    <div class="flex-shrink-0 me-3">
                                        <span class="badge bg-primary fs-5 p-2" style="width: 55px;">
                                            <%= review.getRating() %> <i class="fas fa-star"></i>
                                        </span>
                                    </div>
                                    <div class="flex-grow-1">
                                        <p class="mb-1">"<%= (review.getComment() != null && !review.getComment().isEmpty()) ? review.getComment() : "<i>No comment left.</i>" %>"</p>
                                        <small class="text-muted">
                                            <strong><%= patientName %></strong> on <%= new java.text.SimpleDateFormat("MMM dd, yyyy").format(review.getReviewDate()) %>
                                        </small>
                                    </div>
                                </div>
                                <hr class="my-2">
                            <% 
                                } // end for loop
                            } // end else 
                            %>
                        </div>
                    </div>
                    <!-- --- END NEW FEEDBACK --- -->
                    
                </div>

                <div class="col-lg-4">
                    
                    <!-- --- NEW: Average Rating Card --- -->
                    <div class="card card-modern mb-4">
                        <div class="card-header-modern">
                            <i class="fas fa-star"></i>
                            <span>My Rating</span>
                        </div>
                        <div class="card-body text-center p-4">
                            <div class="display-4 fw-bold text-primary"><%= formattedRating %> <i class="fas fa-star text-warning" style="font-size: 0.8em;"></i></div>
                            <p class="text-muted mb-0">Based on <%= totalReviews %> patient reviews</p>
                        </div>
                    </div>
                    <!-- --- END NEW CARD --- -->
                    
                    <div class="card card-modern mb-4">
                        <div class="card-header-modern">
                            <i class="fas fa-bolt"></i>
                            <span>Quick Actions</span>
                        </div>
                        <div class="card-body p-4">
                            <div class="d-grid gap-2">
                                <a href="${pageContext.request.contextPath}/doctor/appointment?action=view"
                                   class="btn btn-primary-modern btn-modern">
                                    <i class="fas fa-list me-2"></i>View All Appointments
                                </a>
                                <a href="${pageContext.request.contextPath}/doctor/profile"
                                   class="btn btn-outline-primary">
                                    <i class="fas fa-user me-2"></i>Update Profile
                                </a>
                                <a href="${pageContext.request.contextPath}/doctor/change_password.jsp"
                                   class="btn btn-outline-primary">
                                    <i class="fas fa-key me-2"></i>Change Password
                                </a>
                            </div>
                        </div>
                    </div>

                    <div class="card card-modern">
                        <div class="card-header-modern">
                            <i class="fas fa-chart-pie"></i>
                            <span>Appointment Status</span>
                        </div>
                        <div class="card-body p-4">
                            <div class="chart-container">
                                 <canvas id="statusChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row mt-4">
                <div class="col-12">
                    <div class="card card-modern">
                        <div class="card-header-modern">
                            <i class="fas fa-user-md"></i>
                            <span>Profile Summary</span>
                        </div>
                        <div class="card-body p-4">
                            <div class="row">
                                <div class="col-md-3 text-center mb-3 mb-md-0">
                                    <div class="icon-box icon-primary mx-auto mb-2">
                                        <i class="fas fa-stethoscope"></i>
                                    </div>
                                    <h6>Specialization</h6>
                                    <p class="text-muted mb-0"><%= currentDoctor.getSpecialization() %></p>
                                </div>
                                <div class="col-md-3 text-center mb-3 mb-md-0">
                                    <div class="icon-box icon-success mx-auto mb-2">
                                        <i class="fas fa-building"></i>
                                    </div>
                                    <h6>Department</h6>
                                    <p class="text-muted mb-0"><%= currentDoctor.getDepartment() %></p>
                                </div>
                                <div class="col-md-3 text-center mb-3 mb-md-0">
                                    <div class="icon-box icon-warning mx-auto mb-2">
                                        <i class="fas fa-briefcase"></i>
                                    </div>
                                    <h6>Experience</h6>
                                    <p class="text-muted mb-0"><%= currentDoctor.getExperience() %> years</p>
                                </div>
                                <div class="col-md-3 text-center">
                                    <div class="icon-box icon-danger mx-auto mb-2">
                                       <span>&#8377;</span>
                                    </div>
                                    <h6>Fee</h6>
                                    <p class="text-muted mb-0"><span>&#8377;</span><%= currentDoctor.getVisitingCharge() %></p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const mobileMenuToggle = document.getElementById('mobileMenuToggle');
            const sidebar = document.getElementById('sidebar');
            
            function checkScreenSize() {
                if (window.innerWidth <= 768) {
                    mobileMenuToggle.style.display = 'flex';
                    sidebar.classList.remove('mobile-open');
                } else {
                    mobileMenuToggle.style.display = 'none';
                    sidebar.classList.remove('mobile-open');
                }
            }
            
            checkScreenSize();
            window.addEventListener('resize', checkScreenSize);
            
            mobileMenuToggle.addEventListener('click', function() {
                sidebar.classList.toggle('mobile-open');
            });
            
            const navLinks = document.querySelectorAll('.nav-link');
            navLinks.forEach(link => {
                link.addEventListener('click', function() {
                    if (window.innerWidth <= 768) {
                        sidebar.classList.remove('mobile-open');
                    }
                });
            });
        });
    </script>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const canvas = document.getElementById('statusChart');
            if (canvas) {
                 const ctx = canvas.getContext('2d');
                 new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['Pending', 'Confirmed', 'Completed'],
                        datasets: [{
                            data: [<%= stats[1] %>, <%= stats[2] %>, <%= stats[3] %>],
                            backgroundColor: [
                                'rgba(255, 193, 7, 0.8)',
                                'rgba(13, 202, 240, 0.8)', // Swapped colors to match stats cards
                                'rgba(25, 135, 84, 0.8)'
                            ],
                            borderColor: [
                                'rgba(255, 193, 7, 1)',
                                'rgba(13, 202, 240, 1)',
                                'rgba(25, 135, 84, 1)'
                            ],
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'bottom'
                            }
                        },
                         cutout: '60%'
                    }
                 });
            } else {
                console.error("Canvas element with ID 'statusChart' not found.");
            }
        });
    </script>
</body>
</html>