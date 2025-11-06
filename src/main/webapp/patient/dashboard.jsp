<%@ page import="com.entity.Patient" %>
<%@ page import="com.dao.AppointmentDao" %>
<%@ page import="java.util.List" %>
<%@ page import="com.entity.Appointment" %>

<%
    // Use unique variable name
    Patient currentPatient = (Patient) session.getAttribute("patientObj");
    if (currentPatient == null) {
        response.sendRedirect(request.getContextPath() + "/patient/login.jsp");
        return;
    }
    
    AppointmentDao appointmentDao = new AppointmentDao();
    List<Appointment> appointments = appointmentDao.getAppointmentsByPatientId(currentPatient.getId());
    
    // Count appointments by status
    int totalAppointments = appointments.size();
    int pendingAppointments = 0;
    int confirmedAppointments = 0;
    int completedAppointments = 0;
    
    // --- START OF FIX 1 ---
    // This loop now treats null status as "Pending"
    for (Appointment app : appointments) {
        String status = app.getStatus();
        if (status == null) {
            status = "Pending"; // Treat null as Pending
        }
        
        switch (status) {
            case "Pending": pendingAppointments++; break;
            case "Confirmed": confirmedAppointments++; break;
            case "Completed": completedAppointments++; break;
        }
    }
    // --- END OF FIX 1 ---
%>
                <%
                    // This block is now correct and will set the variable
                    // for your logout link
                    String currentUserRole = "";
                    if (session.getAttribute("patientObj") != null) {
                        currentUserRole = "patient";
                    } else if (session.getAttribute("doctorObj") != null) {
                        currentUserRole = "doctor";
                    } else if (session.getAttribute("adminObj") != null) {
                        currentUserRole = "admin";
                    }
                %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Care System - Patient Dashboard</title>
    
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    
    <style>
        /* This is the fix for your status badges (Completed, Pending, etc.) */
        .badge {
            width: auto !important; /* Forces the badge to fit its content */
            white-space: nowrap;   /* Prevents text from wrapping */
        }
    
        /* This is the fix for the "Patient" badge in your sidebar */
        .user-info .badge {
            width: auto !important; /* Forces the badge to fit its content */
        }
    </style>
    </head>
<body>
    <button class="mobile-menu-toggle" id="mobileMenuToggle">
        <i class="fas fa-bars"></i>
    </button>
    
    <div class="sidebar" id="sidebar">
        <div class="sidebar-sticky">
            <div class="user-section">
                <div class="user-avatar">
                    <i class="fas fa-user-circle"></i>
                </div>
                <div class="user-info">
                    <%
                        if (currentPatient != null) {
                    %>
                    <h6><%= currentPatient.getFullName() %></h6>
                    <span class="badge">Patient</span>
                    <% } %>
                </div>
            </div>
            
            <div class="nav-main">
                <ul class="nav">
                    <li class="nav-item">
                        <a class="nav-link active" 
                           href="${pageContext.request.contextPath}/patient/dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" 
                           href="${pageContext.request.contextPath}/patient/profile">
                            <i class="fas fa-user"></i>
                            <span>My Profile</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" 
                           href="${pageContext.request.contextPath}/patient/change_password.jsp">
                            <i class="fas fa-key"></i>
                            <span>Change Password</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" 
                           href="${pageContext.request.contextPath}/patient/appointment?action=book">
                            <i class="fas fa-calendar-plus"></i>
                            <span>Book Appointment</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" 
                           href="${pageContext.request.contextPath}/patient/appointment?action=view">
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
    
    <main class="main-content">
        <div class="page-header">
            <h1 class="page-title">
                <i class="fas fa-tachometer-alt"></i>
                Patient Dashboard
            </h1>
            <div class="user-welcome">
                <i class="fas fa-user-circle"></i>
                <span>Welcome, <%= currentPatient.getFullName() %></span>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stats-card stats-total">
                <i class="fas fa-calendar-check"></i>
                <div class="stats-card-content">
                    <div class="number"><%= totalAppointments %></div>
                    <div class="label">Total Appointments</div>
                </div>
            </div>
            <div class="stats-card stats-pending">
                <i class="fas fa-clock"></i>
                <div class="stats-card-content">
                    <div class="number"><%= pendingAppointments %></div>
                    <div class="label">Pending</div>
                </div>
            </div>
            <div class="stats-card stats-confirmed">
                <i class="fas fa-check-circle"></i>
                <div class="stats-card-content">
                    <div class="number"><%= confirmedAppointments %></div>
                    <div class="label">Confirmed</div>
                </div>
            </div>
            <div class="stats-card stats-completed">
                <i class="fas fa-calendar-check"></i>
                <div class="stats-card-content">
                    <div class="number"><%= completedAppointments %></div>
                    <div class="label">Completed</div>
                </div>
            </div>
        </div>

        <div class="content-grid">
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">
                        <i class="fas fa-list-alt"></i>
                        Recent Appointments
                    </h2>
                    <a href="${pageContext.request.contextPath}/patient/appointment?action=view" class="btn btn-primary btn-sm">
                        <i class="fas fa-eye"></i>
                        View All
                    </a>
                </div>
                <div class="card-body">
                    <%
                        if (appointments.isEmpty()) {
                    %>
                            <div class="empty-state">
                                <i class="fas fa-calendar-times"></i>
                                <h5>No Appointments Yet</h5>
                                <p>You haven't booked any appointments yet.</p>
                                <a href="${pageContext.request.contextPath}/patient/appointment?action=book" class="btn btn-primary">
                                    <i class="fas fa-calendar-plus"></i>
                                    Book Your First Appointment
                                </a>
                            </div>
                    <%
                        } else {
                            List<Appointment> recentAppointments = appointments.subList(0, Math.min(5, appointments.size()));
                    %>
                            <div class="table-responsive">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Doctor</th>
                                            <th>Date & Time</th>
                                            <th>Type</th>
                                            <th>Status</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        // --- START OF FIX 2 ---
                                        for (Appointment app : recentAppointments) {
                                            String statusBadgeClass = "";
                                            String status = app.getStatus(); 
                                            if (status == null) {
                                                status = "Pending"; // Treat null as Pending
                                            }

                                            switch (status) { 
                                                case "Pending": statusBadgeClass = "badge-pending"; break;
                                                case "Confirmed": statusBadgeClass = "badge-confirmed"; break;
                                                case "Completed": statusBadgeClass = "badge-completed"; break;
                                                case "Cancelled": statusBadgeClass = "badge-cancelled"; break;
                                                default: statusBadgeClass = "badge-light"; break;
                                            }
                                    %>
                                        <tr>
                                            <td>
                                                <div class="appointment-doctor">
                                                    <div class="doctor-avatar">
                                                        <i class="fas fa-user-md"></i>
                                                    </div>
                                                    <div class="doctor-info">
                                                        <div class="doctor-name"><%= app.getDoctorName() %></div>
                                                        <div class="doctor-specialty"><%= app.getDoctorSpecialization() %></div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="appointment-time"><%= app.getAppointmentTime() %></div>
                                                <div class="appointment-date"><%= app.getAppointmentDate() %></div>
                                            </td>
                                            <td>
                                                <span class="badge badge-light"><%= app.getAppointmentType() %></span>
                                            </td>
                                            <td>
                                                <span class="badge <%= statusBadgeClass %>"><%= status %></span>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/patient/appointment?action=details&id=<%= app.getId() %>" 
                                                   class="btn btn-outline-primary btn-sm">
                                                    <i class="fas fa-eye"></i>
                                                    View
                                                </a>
                                            </td>
                                        </tr>
                                    <%
                                        }
                                        // --- END OF FIX 2 ---
                                    %>
                                    </tbody>
                                </table>
                            </div>
                    <%
                        }
                    %>
                </div>
            </div>

            <div>
                                            <div class="card" >
                    <div class="card-header">
                        <h2 class="card-title">
                            <i class="fas fa-chart-pie"></i>
                            Appointment Status
                        </h2>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="statusChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="card" style="margin-top: 1.5rem;">
                
                    <div class="card-header" >
                        <h2 class="card-title">
                            <i class="fas fa-bolt"></i>
                            Quick Actions
                        </h2>
                    </div>
                    <div class="card-body" >
                        <div class="actions-grid">
                            <a href="${pageContext.request.contextPath}/patient/appointment?action=book" 
                               class="quick-action-card quick-action-primary">
                                <div class="quick-action-icon">
                                    <i class="fas fa-calendar-plus"></i>
                                </div>
                                <h4>Book Appointment</h4>
                                <p>Schedule a new appointment with a doctor</p>
                            </a>
                            
                            <a href="${pageContext.request.contextPath}/patient/profile" 
                               class="quick-action-card quick-action-secondary">
                                <div class="quick-action-icon">
                                    <i class="fas fa-user-edit"></i>
                                </div>
                                <h4>Update Profile</h4>
                                <p>Manage your personal information</p>
                            </a>
                            
                            <a href="${pageContext.request.contextPath}/patient/appointment?action=view" 
                               class="quick-action-card quick-action-tertiary">
                                <div class="quick-action-icon">
                                    <i class="fas fa-list"></i>
                                </div>
                                <h4>View Appointments</h4>
                                <p>See all your scheduled appointments</p>
                            </a>
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
            if (document.getElementById('statusChart')) {
                const ctx = document.getElementById('statusChart').getContext('2d');
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['Pending', 'Confirmed', 'Completed'],
                        datasets: [{
                            data: [<%= pendingAppointments %>, <%= confirmedAppointments %>, <%= completedAppointments %>],
                            backgroundColor: [
                                'rgba(245, 158, 11, 0.8)',
                                'rgba(16, 185, 129, 0.8)',
                                'rgba(14, 165, 233, 0.8)'
                            ],
                            borderColor: [
                                'rgba(245, 158, 11, 1)',
                                'rgba(16, 185, 129, 1)',
                                'rgba(14, 165, 233, 1)'
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
            }
        });
    </script>
</body>
</html>