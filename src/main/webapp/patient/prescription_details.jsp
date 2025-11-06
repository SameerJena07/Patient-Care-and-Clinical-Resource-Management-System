<%@ page import="com.entity.Patient" %>
<%@ page import="com.entity.Appointment" %>
<%@ page import="com.entity.Prescription" %>
<%@ page import="com.entity.PrescriptionMedication" %>
<%@ page import="java.util.List" %>
<%
    Patient currentPatient = (Patient) session.getAttribute("patientObj");
    if (currentPatient == null) {
        response.sendRedirect(request.getContextPath() + "/patient/login.jsp"); 
        return;
    }

    // These attributes are sent by 'PatientAppointmentServlet' (action=details)
    Appointment appointment = (Appointment) request.getAttribute("appointment");
    Prescription prescription = (Prescription) request.getAttribute("prescription");
    
    String currentUserRole = "patient";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prescription Details</title>
    
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https.cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        .prescription-card {
            border-left: 5px solid #0d6efd;
            background-color: #f8f9fa;
        }
        .prescription-section {
            margin-top: 1.5rem;
        }
        .prescription-section h5 {
            color: #0d6efd;
            border-bottom: 1px solid #ccc;
            padding-bottom: 5px;
            font-weight: 600;
        }
        .med-table {
            font-size: 0.9rem;
        }
        
        /* --- NEW CSS FOR PRINTING --- */
        @media print {
            /* Hide everything that is NOT the prescription */
            .sidebar, .page-header, .mobile-menu-toggle, .sidebar-overlay {
                display: none !important;
            }
            
            /* Make the prescription content take up the full page */
            .main-content {
                margin-left: 0 !important;
                padding: 0 !important;
            }
            
            .container-fluid {
                padding: 0 !important;
            }
            
            /* Ensure cards look good on paper */
            .card {
                box-shadow: none !important;
                border: 1px solid #dee2e6 !important;
            }
            
            .prescription-card {
                 /* This helps browsers render the border color */
                -webkit-print-color-adjust: exact; 
                print-color-adjust: exact;
            }
            
            /* Make sure text is black (browsers sometimes force this) */
            body {
                color: #000 !important;
                background-color: #fff !important;
            }
        }
        /* --- END NEW CSS --- */
    </style>
</head>
<body>
    <button class="mobile-menu-toggle" id="mobileMenuToggle" style="display: none;">
        <i class="fas fa-bars"></i>
    </button>
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <div class="sidebar" id="sidebar">
        <!-- (Paste your full sidebar HTML here) -->
        <div class="sidebar-sticky">
            <div class="user-section">
                <div class="user-avatar">
                    <i class="fas fa-user-circle"></i>
                </div>
                <div class="user-info">
                    <h6><%= currentPatient.getFullName() %></h6>
                    <span class="badge">Patient</span>
                </div>
            </div>
            <div class="nav-main">
                <ul class="nav">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/patient/dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i> <span>Dashboard</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/patient/profile">
                            <i class="fas fa-user"></i> <span>My Profile</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/patient/change_password.jsp">
                            <i class="fas fa-key"></i> <span>Change Password</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/patient/appointment?action=book">
                            <i class="fas fa-calendar-plus"></i> <span>Book Appointment</span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/patient/appointment?action=view">
                            <i class="fas fa-list-alt"></i> <span>My Appointments</span>
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
                            <i class="fas fa-sign-out-alt"></i> <span>Logout</span>
                        </a>
                    </li>
                 </ul>
            </div>
        </div>
    </div>
    
    <main class="main-content">
        
        <!-- --- UPDATED: Page Header now has a Print Button --- -->
        <div class="page-header">
            <div>
                <h1 class="page-title">
                    <i class="fas fa-receipt"></i>
                    Prescription Details
                </h1>
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/patient/appointment?action=view" class="btn btn-outline-primary">
                    <i class="fas fa-arrow-left me-2"></i>Back
                </a>
                <button type="button" class="btn btn-primary" id="printButton">
                    <i class="fas fa-print me-2"></i>Print / Download
                </button>
            </div>
        </div>
        <!-- --- END OF UPDATE --- -->

        <div class="container-fluid py-4">
            <% if (appointment == null) { %>
                <div class="alert alert-danger">Error: Appointment details could not be loaded.</div>
            <% } else { %>
                
                <!-- This 'printableArea' is for the CSS to target -->
                <div id="printableArea">
                    <div class="row">
                        <!-- Appointment Details Card -->
                        <div class="col-lg-4">
                            <div class="card h-100">
                                <div class="card-header">
                                    <h5 class="card-title mb-0">
                                        <i class="fas fa-calendar-check me-2"></i>Appointment Info
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <ul class="list-group list-group-flush">
                                        <li class="list-group-item d-flex justify-content-between">
                                            <strong>Doctor:</strong>
                                            <span>Dr. <%= appointment.getDoctorName() %></span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between">
                                            <strong>Specialization:</strong>
                                            <span><%= appointment.getDoctorSpecialization() %></span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between">
                                            <strong>Date:</strong>
                                            <span><%= appointment.getAppointmentDate() %></span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between">
                                            <strong>Time:</strong>
                                            <span><%= appointment.getAppointmentTime() %></span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between">
                                            <strong>Type:</strong>
                                            <span><%= appointment.getAppointmentType() %></span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between">
                                            <strong>Status:</strong>
                                            <span><%= appointment.getStatus() %></span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <!-- Prescription Details Card -->
                        <div class="col-lg-8">
                            <div class="card h-100 prescription-card">
                                <div class="card-header bg-transparent">
                                    <h5 class="card-title mb-0">
                                        <i class="fas fa-file-medical me-2"></i>Doctor's Prescription
                                    </h5>
                                </div>
                                <div class="card-body">
                                    <% if (prescription != null) { %>
                                        <!-- Diagnosis Section -->
                                        <div class="prescription-section">
                                            <h5><i class="fas fa-stethoscope me-2"></i>Diagnosis</h5>
                                            <p class="card-text"><%= (prescription.getDiagnosis() != null && !prescription.getDiagnosis().isEmpty()) ? prescription.getDiagnosis() : "N/A" %></p>
                                        </div>

                                        <!-- Medications Section -->
                                        <div class="prescription-section">
                                            <h5><i class="fas fa-pills me-2"></i>Medications (Rx)</h5>
                                            <div class="table-responsive">
                                                <table class="table table-sm table-bordered med-table">
                                                    <thead class="table-light">
                                                        <tr>
                                                            <th>Medicine</th>
                                                            <th>Dosage</th>
                                                            <th>Frequency</th>
                                                            <th>Duration</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <% 
                                                            List<PrescriptionMedication> meds = prescription.getMedications();
                                                            if (meds != null && !meds.isEmpty()) {
                                                                for (PrescriptionMedication med : meds) { 
                                                        %>
                                                                    <tr>
                                                                        <td><%= med.getMedicineName() %></td>
                                                                        <td><%= (med.getDosage() != null && !med.getDosage().isEmpty()) ? med.getDosage() : "N/A" %></td>
                                                                        <td><%= (med.getFrequency() != null && !med.getFrequency().isEmpty()) ? med.getFrequency() : "N/A" %></td>
                                                                        <td><%= (med.getDuration() != null && !med.getDuration().isEmpty()) ? med.getDuration() : "N/A" %></td>
                                                                    </tr>
                                                        <% 
                                                                }
                                                            } else {
                                                        %>
                                                            <tr>
                                                                <td colspan="4" class="text-center text-muted">No medications prescribed.</td>
                                                            </tr>
                                                        <% } %>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>

                                        <!-- Advice Section -->
                                        <div class="prescription-section">
                                            <h5><i class="fas fa-comment-medical me-2"></i>Doctor's Advice</h5>
                                            <p class="card-text"><%= (prescription.getAdviceNotes() != null && !prescription.getAdviceNotes().isEmpty()) ? prescription.getAdviceNotes() : "No specific advice given." %></p>
                                        </div>

                                        <!-- Follow-up Section -->
                                        <div class="prescription-section">
                                            <h5><i class="fas fa-calendar-alt me-2"></i>Follow-up</h5>
                                            <p class="card-text">
                                                <%= (prescription.getFollowUpDate() != null) ? "Please follow-up on " + prescription.getFollowUpDate() : "No follow-up required." %>
                                            </p>
                                        </div>
                                    <% } else { %>
                                        <div class="text-center p-4">
                                            <i class="fas fa-file-alt fa-3x text-muted mb-3"></i>
                                            <h5 class="text-muted">No Prescription Available</h5>
                                            <p class="text-muted mb-0">A prescription is only available after an appointment is marked as "Completed" by the doctor.</p>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    </main>
    
    <!-- --- UPDATED: Added Print Button script --- -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const mobileMenuToggle = document.getElementById('mobileMenuToggle');
            const sidebar = document.getElementById('sidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay'); 

            function checkScreenSize() {
                if (window.innerWidth <= 768) {
                    if (mobileMenuToggle) mobileMenuToggle.style.display = 'flex';
                    if (sidebar) sidebar.classList.remove('mobile-open');
                    if (sidebarOverlay) sidebarOverlay.classList.remove('active');
                } else {
                    if (mobileMenuToggle) mobileMenuToggle.style.display = 'none';
                    if (sidebar) sidebar.classList.remove('mobile-open');
                    if (sidebarOverlay) sidebarOverlay.classList.remove('active');
                }
            }

            checkScreenSize();
            window.addEventListener('resize', checkScreenSize);

            if (mobileMenuToggle) {
                mobileMenuToggle.addEventListener('click', function() {
                    if (sidebar) sidebar.classList.toggle('mobile-open');
                    if (sidebarOverlay) sidebarOverlay.classList.toggle('active');
                    this.innerHTML = sidebar.classList.contains('mobile-open') ? 
                        '<i class="fas fa-times"></i>' : '<i class="fas fa-bars"></i>';
                });
            }
            
            if (sidebarOverlay) {
                sidebarOverlay.addEventListener('click', function() {
                    if (sidebar) sidebar.classList.remove('mobile-open');
                    if (sidebarOverlay) sidebarOverlay.classList.remove('active');
                    if (mobileMenuToggle) mobileMenuToggle.innerHTML = '<i class="fas fa-bars"></i>';
                });
            }
            
            // --- NEW: Print Button Functionality ---
            const printButton = document.getElementById('printButton');
            if (printButton) {
                printButton.addEventListener('click', function() {
                    window.print();
                });
            }
            // --- END NEW SCRIPT ---
        });
    </script>
</body>
</html>