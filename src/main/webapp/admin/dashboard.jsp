<%@ page import="com.entity.Admin" %>
<%@ page import="com.dao.AppointmentDao" %>
<%@ page import="com.dao.DoctorDao" %>
<%@ page import="com.dao.PatientDao" %>
<%@ page import="com.dao.ReviewDao" %> <%-- --- NEW IMPORT --- --%>
<%@ page import="java.util.List" %>
<%@ page import="com.entity.Doctor" %>
<%@ page import="com.entity.Patient" %>
<%@ page import="com.entity.Appointment" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>
<%
    Admin currentAdmin = (Admin) session.getAttribute("adminObj");
    if (currentAdmin == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }

    AppointmentDao appointmentDao = new AppointmentDao();
    DoctorDao doctorDao = new DoctorDao();
    PatientDao patientDao = new PatientDao();
    ReviewDao reviewDao = new ReviewDao(); // --- NEW DAO INSTANCE ---

    // Get real data from database
    int[] appointmentStats = appointmentDao.getAppointmentStats();
    int totalDoctors = doctorDao.getTotalDoctors();
    int totalPatients = patientDao.getTotalPatients();
    
    // Get real data for charts from database
    Map<String, Integer> weeklyAppointments = appointmentDao.getWeeklyAppointmentCounts();
    List<Appointment> recentAppointments = appointmentDao.getRecentAppointments(10);
    List<Appointment> todayAppointments = appointmentDao.getTodaysAppointments();
    
    // This map now contains (DoctorID|Name|Specialization, ApptCount)
    Map<String, Integer> doctorAppointmentStats = appointmentDao.getDoctorAppointmentStats();

    String currentUserRole = "admin";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Care System - Admin Dashboard</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <button class="mobile-menu-toggle" id="mobileMenuToggle">
        <i class="fas fa-bars"></i>
    </button>
    
    <!-- --- FIXED: Added Sidebar Overlay --- -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <div class="sidebar" id="sidebar">
        <div class="sidebar-sticky">
            <div class="user-section">
                <div class="user-avatar">
                   <i class="fas fa-user-shield"></i>
                </div>
                <div class="user-info">
                   <% if (currentAdmin != null) { %>
                    <h6><%= currentAdmin.getFullName() %></h6>
                    <span class="badge">Administrator</span>
                   <% } %>
                </div>
            </div>

            <div class="nav-main">
                <ul class="nav">
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/admin/dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin/profile.jsp">
                            <i class="fas fa-user"></i>
                            <span>My Profile</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin/management?action=view&type=doctors">
                            <i class="fas fa-user-md"></i>
                            <span>Manage Doctors</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin/management?action=view&type=patients">
                            <i class="fas fa-users"></i>
                            <span>Manage Patients</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin/management?action=view&type=appointments">
                            <i class="fas fa-calendar-alt"></i>
                            <span>Manage Appointments</span>
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
                        <a class="nav-link nav-link-logout" href="${pageContext.request.contextPath}/admin/auth?action=logout">
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
            <div class="d-flex justify-content-between align-items-center flex-wrap">
                <div class="mb-2 mb-md-0">
                    <h1 class="h2 mb-2">
                        <i class="fas fa-tachometer-alt me-2"></i>
                        Admin Dashboard
                    </h1>
                    <p class="mb-0 opacity-75">Welcome back, <%= currentAdmin.getFullName() %>. Here's what's happening today.</p>
                </div>
                <div>
                    <span class="welcome-badge">
                        <i class="fas fa-user-shield me-2"></i>Administrator
                    </span>
                </div>
            </div>
        </div>

        <div class="main-content-dashboard">
            <%-- Success/Error Messages --%>
            <%
                String successMsg = (String) session.getAttribute("successMsg");
                String errorMsg = (String) session.getAttribute("errorMsg");
                
                if (successMsg != null) {
                    session.removeAttribute("successMsg");
            %>
                <div class="alert alert-success alert-modern alert-dismissible fade show mb-4" role="alert">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-check-circle me-3 fs-5"></i>
                        <div class="flex-grow-1"><%= successMsg %></div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <%
                }
                if (errorMsg != null) {
                    session.removeAttribute("errorMsg");
            %>
                <div class="alert alert-danger alert-modern alert-dismissible fade show mb-4" role="alert">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-exclamation-triangle me-3 fs-5"></i>
                        <div class="flex-grow-1"><%= errorMsg %></div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <%
                }
            %>

            <%-- Stats Cards --%>
            <div class="row mb-4">
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-card-primary">
                        <h4 class="mb-1"><%= appointmentStats[0] %></h4>
                        <small>Total Appointments</small>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-card-success">
                        <h4 class="mb-1"><%= totalDoctors %></h4>
                        <small>Total Doctors</small>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-card-info">
                        <h4 class="mb-1"><%= totalPatients %></h4>
                        <small>Total Patients</small>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-card-warning">
                        <h4 class="mb-1"><%= appointmentStats[1] %></h4>
                        <small>Pending Appointments</small>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-8 mb-4">
                    <div class="card card-modern">
                        <div class="card-header-modern card-header-flex">
                            <div>
                                <i class="fas fa-chart-bar"></i>
                                <span>Appointment Analytics</span>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6 mb-4">
                                    <div class="chart-container">
                                        <h6 class="text-center mb-3">Weekly Appointments</h6>
                                        <canvas id="weeklyChart"></canvas>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-4">
                                    <div class="chart-container">
                                        <h6 class="text-center mb-3">Status Distribution</h6>
                                        <canvas id="statusChart"></canvas>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- --- UPDATED: Top Performing Doctors Table --- -->
                            <div class="mt-4">
                                <h6 class="mb-3">Top Performing Doctors</h6>
                                <div class="table-responsive">
                                    <table class="table table-sm">
                                        <thead>
                                            <tr>
                                                <th>Rank</th>
                                                <th>Doctor</th>
                                                <th>Specialization</th>
                                                <th>Appointments</th>
                                                <th>Rating</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                int rank = 1;
                                                if (doctorAppointmentStats != null && !doctorAppointmentStats.isEmpty()) {
                                                    for (Map.Entry<String, Integer> entry : doctorAppointmentStats.entrySet()) {
                                                        if (rank > 5) break;
                                                        
                                                        // --- NEW: Split the key to get the ID ---
                                                        String[] doctorInfo = entry.getKey().split("\\|");
                                                        int doctorId = Integer.parseInt(doctorInfo[0]);
                                                        String doctorName = doctorInfo[1];
                                                        String specialization = doctorInfo[2];
                                            %>
                                            <tr>
                                                <td><div class="doctor-rank"><%= rank++ %></div></td>
                                                <td><strong><%= doctorName %></strong></td>
                                                <td><%= specialization %></td>
                                                <td><span class="badge bg-primary"><%= entry.getValue() %></span></td>
                                                <td>
                                                    <%
                                                        // --- NEW: Get REAL rating from ReviewDao ---
                                                        double realRating = reviewDao.getAverageRatingByDoctorId(doctorId);
                                                    %>
                                                    <span class="text-warning">
                                                        <i class="fas fa-star"></i> <%= String.format("%.1f", realRating) %>
                                                    </span>
                                                </td>
                                            </tr>
                                            <%
                                                    }
                                                } else {
                                            %>
                                            <tr>
                                                <td colspan="5" class="text-center text-muted py-3">
                                                    <div class="empty-state">
                                                        <i class="fas fa-user-md"></i>
                                                        <p>No doctor data available</p>
                                                    </div>
                                                </td>
                                            </tr>
                                            <%
                                                }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <!-- --- END OF UPDATE --- -->
                            
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card card-modern mb-4">
                        <div class="card-header-modern">
                            <i class="fas fa-bolt"></i>
                            <span>Quick Actions</span>
                        </div>
                        <div class="card-body">
                            <div class="quick-actions-grid">
                                <a href="${pageContext.request.contextPath}/admin/management?action=view&type=doctors"
                                   class="btn btn-primary-modern">
                                    <i class="fas fa-user-md me-2"></i>Manage Doctors
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/management?action=view&type=patients"
                                   class="btn btn-outline-primary">
                                    <i class="fas fa-users me-2"></i>Manage Patients
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/management?action=view&type=appointments"
                                   class="btn btn-outline-primary">
                                    <i class="fas fa-calendar-alt me-2"></i>Manage Appointments
                                </a>
                            </div>
                        </div>
                    </div>

                    <div class="card card-modern mb-4">
                        <div class="card-header-modern">
                            <i class="fas fa-calendar-day"></i>
                            <span>Today's Appointments</span>
                        </div>
                        <div class="card-body">
                            <%
                                if (todayAppointments != null && !todayAppointments.isEmpty()) {
                                    // Limit to 5 appointments for display
                                    int displayCount = Math.min(todayAppointments.size(), 5);
                                    for (int i = 0; i < displayCount; i++) {
                                        Appointment appt = todayAppointments.get(i);
                                        
                                        // Status handling
                                        String statusToday = appt.getStatus();
                                        String badgeClassToday = "badge-secondary";
                                    
                                        if (statusToday == null || "Pending".equals(statusToday)) {
                                            statusToday = "Pending";
                                            badgeClassToday = "badge-warning";
                                        } else if ("Confirmed".equals(statusToday)) {
                                            badgeClassToday = "badge-success";
                                        } else if ("Completed".equals(statusToday)) {
                                            badgeClassToday = "badge-info";
                                        } else if ("Cancelled".equals(statusToday)) {
                                            badgeClassToday = "badge-danger";
                                        }
                            %>
                            <div class="activity-item">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <strong><%= appt.getPatientName() != null ? appt.getPatientName() : "N/A" %></strong>
                                        <br>
                                        <small class="text-muted">With Dr. <%= appt.getDoctorName() != null ? appt.getDoctorName() : "N/A" %></small>
                                        <br>
                                        <small><%= appt.getAppointmentTime() != null ? appt.getAppointmentTime().toString().substring(0, 5) : "N/A" %></small>
                                    </div>
                                    <span class="badge <%= badgeClassToday %>">
                                        <%= statusToday %>
                                    </span>
                                </div>
                            </div>
                            <%
                                    }
                                } else {
                            %>
                            <div class="empty-state">
                                <i class="fas fa-calendar-times"></i>
                                <h6 class="text-muted">No Appointments</h6>
                                <p class="text-muted mb-0">No appointments scheduled for today</p>
                            </div>
                            <%
                                }
                            %>
                        </div>
                    </div>

                    <div class="card card-modern">
                        <div class="card-header-modern">
                            <i class="fas fa-info-circle"></i>
                            <span>System Information</span>
                        </div>
                        <div class="card-body">
                            <div class="system-info-list">
                                <div class="list-group list-group-flush">
                                    <div class="list-group-item d-flex justify-content-between align-items-center px-0">
                                        <span class="text-muted">System Version</span>
                                        <strong>v1.0.0</strong>
                                    </div>
                                    <div class="list-group-item d-flex justify-content-between align-items-center px-0">
                                        <span class="text-muted">Last Backup</span>
                                        <strong><%= new SimpleDateFormat("MMM dd, yyyy").format(new Date()) %></strong>
                                    </div>
                                    <div class="list-group-item d-flex justify-content-between align-items-center px-0">
                                        <span class="text-muted">Active Users</span>
                                        <strong><%= totalDoctors + totalPatients %></strong>
                                    </div>
                                    <div class="list-group-item d-flex justify-content-between align-items-center px-0">
                                        <span class="text-muted">System Status</span>
                                        <span class="badge badge-success">Online</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row mt-4">
                <div class="col-12">
                    <div class="card card-modern">
                        <div class="card-header-modern card-header-flex">
                            <div>
                                <i class="fas fa-history"></i>
                                <span>Recent Activity</span>
                            </div>
                            <small class="text-muted">Latest 10 activities</small>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table table-sm table-hover">
                                    <thead>
                                        <tr>
                                            <th>Date & Time</th>
                                            <th>Patient</th>
                                            <th>Doctor</th>
                                            <th>Status</th>
                                            <th>Details</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            if (recentAppointments != null && !recentAppointments.isEmpty()) {
                                                for (Appointment appt : recentAppointments) {
                                                    
                                                    // Status handling
                                                    String statusRecent = appt.getStatus();
                                                    String badgeClassRecent = "badge-secondary";
                                                
                                                    if (statusRecent == null || "Pending".equals(statusRecent)) {
                                                        statusRecent = "Pending";
                                                        badgeClassRecent = "badge-warning";
                                                    } else if ("Confirmed".equals(statusRecent)) {
                                                        badgeClassRecent = "badge-success";
                                                    } else if ("Completed".equals(statusRecent)) {
                                                        badgeClassRecent = "badge-info";
                                                    } else if ("Cancelled".equals(statusRecent)) {
                                                        badgeClassRecent = "badge-danger";
                                                    }
                                        %>
                                        <tr>
                                            <td>
                                                <small><%= appt.getAppointmentDate() != null ? appt.getAppointmentDate() : "N/A" %></small>
                                                <br>
                                                <small class="text-muted"><%= appt.getAppointmentTime() != null ? appt.getAppointmentTime().toString().substring(0, 5) : "N/A" %></small>
                                            </td>
                                            <td><%= appt.getPatientName() != null ? appt.getPatientName() : "N/A" %></td>
                                            <td>Dr. <%= appt.getDoctorName() != null ? appt.getDoctorName() : "N/A" %></td>
                                            <td>
                                                <span class="badge <%= badgeClassRecent %>">
                                                    <%= statusRecent %>
                                                </span>
                                            </td>
                                            <td>
                                                <small class="text-muted"><%= appt.getDoctorSpecialization() != null ? appt.getDoctorSpecialization() : "General" %></small>
                                            </td>
                                        </tr>
                                        <%
                                                }
                                            } else {
                                        %>
                                        <tr>
                                            <td colspan="5" class="text-center text-muted py-3">
                                                <div class="empty-state">
                                                    <i class="fas fa-inbox"></i>
                                                    <h6 class="text-muted">No Recent Activity</h6>
                                                    <p class="text-muted mb-0">No recent appointments found</p>
                                                </div>
                                            </td>
                                        </tr>
                                        <%
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- --- FIXED: Replaced entire script block --- -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Mobile menu toggle
            const mobileMenuToggle = document.getElementById('mobileMenuToggle');
            const sidebar = document.getElementById('sidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay'); // --- ADDED ---

            function checkScreenSize() {
                if (window.innerWidth <= 768) {
                    if (mobileMenuToggle) mobileMenuToggle.style.display = 'flex';
                    if (sidebar) sidebar.classList.remove('mobile-open');
                    if (sidebarOverlay) sidebarOverlay.classList.remove('active'); // --- ADDED ---
                } else {
                    if (mobileMenuToggle) mobileMenuToggle.style.display = 'none';
                    if (sidebar) sidebar.classList.remove('mobile-open');
                    if (sidebarOverlay) sidebarOverlay.classList.remove('active'); // --- ADDED ---
                }
            }

            checkScreenSize();
            window.addEventListener('resize', checkScreenSize);

            if (mobileMenuToggle) {
                mobileMenuToggle.addEventListener('click', function() {
                    if (sidebar) sidebar.classList.toggle('mobile-open');
                    if (sidebarOverlay) sidebarOverlay.classList.toggle('active'); // --- ADDED ---
                });
            }

            // --- NEW: Add overlay click listener ---
            if (sidebarOverlay) {
                sidebarOverlay.addEventListener('click', function() {
                    if (sidebar) sidebar.classList.remove('mobile-open');
                    if (sidebarOverlay) sidebarOverlay.classList.remove('active');
                });
            }

            // Auto-hide alerts
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                setTimeout(() => {
                    if (alert && alert.classList.contains('show')) {
                        const bsAlert = new bootstrap.Alert(alert);
                        bsAlert.close();
                    }
                }, 5000);
            });

            // Weekly Appointments Chart - USING REAL DATA
            const weeklyCtx = document.getElementById('weeklyChart');
            if(weeklyCtx) {
                new Chart(weeklyCtx, {
                    type: 'line',
                    data: {
                        labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                        datasets: [{
                            label: 'Appointments',
                            data: [
                                <%= weeklyAppointments.getOrDefault("Monday", 0) %>,
                                <%= weeklyAppointments.getOrDefault("Tuesday", 0) %>,
                                <%= weeklyAppointments.getOrDefault("Wednesday", 0) %>,
                                <%= weeklyAppointments.getOrDefault("Thursday", 0) %>,
                                <%= weeklyAppointments.getOrDefault("Friday", 0) %>,
                                <%= weeklyAppointments.getOrDefault("Saturday", 0) %>,
                                <%= weeklyAppointments.getOrDefault("Sunday", 0) %>
                            ],
                            backgroundColor: 'rgba(67, 97, 238, 0.1)',
                            borderColor: 'rgba(67, 97, 238, 1)',
                            borderWidth: 2,
                            tension: 0.4,
                            fill: true
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                grid: { color: 'rgba(0,0,0,0.1)' }
                            },
                            x: {
                                grid: { display: false }
                            }
                        }
                    }
                });
            }

            // Status Distribution Chart - USING REAL DATA
            const statusCtx = document.getElementById('statusChart');
            if (statusCtx) {
                new Chart(statusCtx, {
                    type: 'doughnut',
                    data: {
                        labels: ['Pending', 'Confirmed', 'Completed', 'Cancelled'],
                        datasets: [{
                            data: [
                                <%= appointmentStats[1] %>,
                                <%= appointmentStats[2] %>,
                                <%= appointmentStats[3] %>,
                                <%= appointmentStats[4] %>
                            ],
                            backgroundColor: [
                                'rgba(255, 193, 7, 0.8)',
                                'rgba(25, 135, 84, 0.8)',
                                'rgba(13, 202, 240, 0.8)',
                                'rgba(108, 117, 125, 0.8)'
                            ],
                            borderColor: '#fff',
                            borderWidth: 2
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
            }
        });
    </script>
</body>
</html>