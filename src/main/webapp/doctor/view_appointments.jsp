<%@ page import="com.entity.Doctor" %>
<%@ page import="com.dao.AppointmentDao" %>
<%@ page import="com.entity.Appointment" %>
<%@ page import="com.dao.PatientDao" %>
<%@ page import="com.entity.Patient" %>
<%@ page import="com.dao.PrescriptionDao" %>
<%@ page import="com.entity.Prescription" %>
<%@ page import="com.entity.PrescriptionMedication" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>
<%
    Doctor currentDoctor = (Doctor) session.getAttribute("doctorObj");
    if (currentDoctor == null) {
        response.sendRedirect(request.getContextPath() + "/doctor/login.jsp"); 
        return;
    }

    // --- DATA HANDLING (Unchanged) ---
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    Map<Integer, Prescription> prescriptionMap = (Map<Integer, Prescription>) request.getAttribute("prescriptionMap");

    if (appointments == null) {
        AppointmentDao appointmentDao = new AppointmentDao();
        appointments = appointmentDao.getAppointmentsByDoctorId(currentDoctor.getId());
    }
    if (prescriptionMap == null) {
        prescriptionMap = new HashMap<>();
        PrescriptionDao prescriptionDao = new PrescriptionDao();
        if (appointments != null) {
            for (Appointment appt : appointments) {
                if ("Completed".equals(appt.getStatus())) {
                    Prescription p = prescriptionDao.getPrescriptionByAppointmentId(appt.getId());
                    if (p != null) {
                        prescriptionMap.put(appt.getId(), p);
                    }
                }
            }
        }
    }

    PatientDao patientDao = new PatientDao();
    Map<Integer, Patient> patientMap = new HashMap<>();
    if (appointments != null) {
        for (Appointment appointment : appointments) {
            if (!patientMap.containsKey(appointment.getPatientId())) {
                Patient patient = patientDao.getPatientById(appointment.getPatientId());
                patientMap.put(appointment.getPatientId(), patient);
            }
        }
    }

    long pendingCount = appointments != null ? appointments.stream().filter(a -> "Pending".equals(a.getStatus()) || a.getStatus() == null).count() : 0;
    long confirmedCount = appointments != null ? appointments.stream().filter(a -> "Confirmed".equals(a.getStatus())).count() : 0;
    long completedCount = appointments != null ? appointments.stream().filter(a -> "Completed".equals(a.getStatus())).count() : 0;
    long cancelledCount = appointments != null ? appointments.stream().filter(a -> "Cancelled".equals(a.getStatus())).count() : 0;

    String currentUserRole = "doctor";
    
    // Message handling (Unchanged)
    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");

    if (successMsg != null) {
        session.removeAttribute("successMsg");
    }
    if (errorMsg != null) {
        session.removeAttribute("errorMsg");
    }

    if (request.getAttribute("successMsg") != null) {
        successMsg = (String) request.getAttribute("successMsg");
    }
    if (request.getAttribute("errorMsg") != null) {
        errorMsg = (String) request.getAttribute("errorMsg");
    }

    // =========================================================================
    // 💡 FIX: Manual Server-Side JSON Serialization for Client-Side JS Access
    // =========================================================================
    
    // Function to escape string for JSON
    java.util.function.Function<String, String> jsonEscape = s -> {
        if (s == null) return "";
        return s.replace("\\", "\\\\") 
                 .replace("\"", "\\\"") 
                 .replace("\n", "\\n")
                 .replace("\r", "\\r"); 
    };

    StringBuilder jsonBuilder = new StringBuilder();
    jsonBuilder.append("{");
    boolean firstEntry = true;

    for (Map.Entry<Integer, Prescription> entry : prescriptionMap.entrySet()) {
        if (!firstEntry) {
            jsonBuilder.append(",");
        }
        firstEntry = false;
        
        int appId = entry.getKey();
        Prescription p = entry.getValue();
        
        // Start Prescription Object
        jsonBuilder.append("\"").append(appId).append("\":{");
        
        jsonBuilder.append("\"diagnosis\":\"").append(jsonEscape.apply(p.getDiagnosis())).append("\",");
        jsonBuilder.append("\"adviceNotes\":\"").append(jsonEscape.apply(p.getAdviceNotes())).append("\",");
        
        // Follow-up Date
        String followUpDate = (p.getFollowUpDate() != null) ? p.getFollowUpDate().toString() : null;
        jsonBuilder.append("\"followUpDate\":").append(followUpDate != null ? "\"" + followUpDate + "\"" : "null").append(",");

        // Medications List
        jsonBuilder.append("\"medications\":[");
        
        List<PrescriptionMedication> meds = p.getMedications();
        if (meds != null) {
            boolean firstMed = true;
            for (PrescriptionMedication med : meds) {
                if (!firstMed) {
                    jsonBuilder.append(",");
                }
                firstMed = false;
                
                jsonBuilder.append("{");
                jsonBuilder.append("\"medicineName\":\"").append(jsonEscape.apply(med.getMedicineName())).append("\",");
                jsonBuilder.append("\"dosage\":\"").append(jsonEscape.apply(med.getDosage())).append("\",");
                jsonBuilder.append("\"frequency\":\"").append(jsonEscape.apply(med.getFrequency())).append("\",");
                jsonBuilder.append("\"duration\":\"").append(jsonEscape.apply(med.getDuration())).append("\"");
                jsonBuilder.append("}");
            }
        }
        jsonBuilder.append("]"); // End medications array
        
        jsonBuilder.append("}"); // End Prescription Object
    }
    
    jsonBuilder.append("}"); // End main map
    
    String prescriptionJson = jsonBuilder.toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Appointments | Patient Care System</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
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
    </style>
</head>
<body>
    
    <button class="mobile-menu-toggle" id="mobileMenuToggle" style="display: none;">
        <i class="fas fa-bars"></i>
    </button>
    
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <div class="sidebar" id="sidebar">
        <div class="sidebar-sticky">
            <div class="user-section">
                <div class="user-avatar">
                    <i class="fas fa-user-md"></i>
                </div>
                <div class="user-info">
                   <% if (currentDoctor != null) { %>
                    <h6>Dr. <%= currentDoctor.getFullName() %></h6>
                    <small><%= currentDoctor.getSpecialization() %></small>
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
                            <i class="fas fa-calendar-check"></i>
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
        <div class="page-header">
            <div class="container-fluid">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h1 class="page-title">
                            <i class="fas fa-calendar-check"></i>
                            My Appointments
                        </h1>
                        <p class="text-muted mb-0">Manage and track all your patient appointments</p>
                    </div>
                    <div class="col-md-4 text-md-end mt-3 mt-md-0">
                        <span class="badge bg-primary fs-6 p-3">
                            <i class="fas fa-calendar-check me-2"></i>
                            <%= appointments != null ? appointments.size() : 0 %> Total Appointments
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <div class="container-fluid py-4">
            <% if (successMsg != null && !successMsg.isEmpty()) { %>
                <div class="alert alert-success alert-dismissible fade show fade-in" role="alert">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-check-circle me-3 fs-5"></i>
                        <div class="flex-grow-1">
                            <strong>Success!</strong> <%= successMsg %>
                        </div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show fade-in" role="alert">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-exclamation-triangle me-3 fs-5"></i>
                        <div class="flex-grow-1">
                            <strong>Attention!</strong> <%= errorMsg %>
                        </div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <div class="row g-4 mb-4 fade-in">
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card pending">
                        <div class="stat-number"><%= pendingCount %></div>
                        <div class="stat-label">Pending</div>
                        <i class="fas fa-clock mt-3 fs-2 text-warning"></i>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card confirmed">
                        <div class="stat-number"><%= confirmedCount %></div>
                        <div class="stat-label">Confirmed</div>
                        <i class="fas fa-check-circle mt-3 fs-2 text-info"></i>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card completed">
                        <div class="stat-number"><%= completedCount %></div>
                        <div class="stat-label">Completed</div>
                        <i class="fas fa-calendar-check mt-3 fs-2 text-success"></i>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="stat-card cancelled">
                        <div class="stat-number"><%= cancelledCount %></div>
                        <div class="stat-label">Cancelled</div>
                        <i class="fas fa-times-circle mt-3 fs-2 text-danger"></i>
                    </div>
                </div>
            </div>

            <div class="card fade-in mb-4">
                <div class="card-body">
                    <div class="row g-3 align-items-end">
                        <div class="col-lg-4 col-md-6">
                            <label class="form-label fw-semibold">Filter by Status</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0">
                                    <i class="fas fa-filter text-primary"></i>
                                </span>
                                <select class="form-select border-start-0" id="statusFilter">
                                    <option value="all" selected>All Statuses</option>
                                    <option value="Pending">Pending</option>
                                    <option value="Confirmed">Confirmed</option>
                                    <option value="Completed">Completed</option>
                                    <option value="Cancelled">Cancelled</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-lg-4 col-md-6">
                            <label class="form-label fw-semibold">Search Patient</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0">
                                    <i class="fas fa-search text-primary"></i>
                                </span>
                                <input type="text" class="form-control border-start-0" id="searchPatient" 
                                       placeholder="Search by patient name...">
                            </div>
                        </div>
                        <div class="col-lg-4 col-md-12">
                            <button type="button" id="clearFilters" class="btn btn-outline-primary w-100">
                                <i class="fas fa-eraser me-2"></i>Clear Filters
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card fade-in">
                <div class="card-header">
                    <div class="row align-items-center">
                        <div class="col">
                            <h5 class="mb-0">
                                <i class="fas fa-list me-2 text-primary"></i>Appointment List
                            </h5>
                        </div>
                        <div class="col-auto">
                            <span class="badge bg-light text-dark fs-6">
                                <i class="fas fa-user-md me-2 text-primary"></i>Dr. <%= currentDoctor.getFullName() %>
                            </span>
                        </div>
                    </div>
                </div>
                <div class="card-body p-0">
                    <%
                        if (appointments == null || appointments.isEmpty()) {
                    %>
                        <div class="text-center py-5">
                            <i class="fas fa-calendar-times fa-4x text-muted mb-4"></i>
                            <h4 class="text-muted mb-3">No Appointments Found</h4>
                            <p class="text-muted mb-4">You don't have any appointments scheduled yet.</p>
                            <a href="${pageContext.request.contextPath}/doctor/dashboard.jsp" class="btn btn-primary">
                                <i class="fas fa-tachometer-alt me-2"></i>Back to Dashboard
                            </a>
                        </div>
                    <%
                        } else {
                    %>
                        <div class="table-container">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0" id="appointmentsTable">
                                    <thead>
                                        <tr>
                                            <th>Patient Details</th>
                                            <th>Contact Info</th>
                                            <th>Date & Time</th>
                                            <th>Type</th>
                                            <th>Reason</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            for (Appointment appointment : appointments) {
                                                String status = appointment.getStatus();
                                                if (status == null) {
                                                    status = "Pending";
                                                }

                                                String statusBadgeClass;
                                                String statusIcon;

                                                switch (status) {
                                                    case "Pending":
                                                        statusBadgeClass = "badge-pending";
                                                        statusIcon = "fas fa-clock";
                                                        break;
                                                    case "Confirmed":
                                                        statusBadgeClass = "badge-confirmed";
                                                        statusIcon = "fas fa-check-circle";
                                                        break;
                                                    case "Completed":
                                                        statusBadgeClass = "badge-completed";
                                                        statusIcon = "fas fa-calendar-check";
                                                        break;
                                                    case "Cancelled":
                                                        statusBadgeClass = "badge-cancelled";
                                                        statusIcon = "fas fa-times-circle";
                                                        break;
                                                    default:
                                                        statusBadgeClass = "badge-pending";
                                                        statusIcon = "fas fa-clock";
                                                }
                                                
                                                Patient patient = patientMap.get(appointment.getPatientId());
                                                String patientPhone = "N/A";
                                                String patientEmail = "N/A";
                                                
                                                if (patient != null) {
                                                    patientPhone = patient.getPhone() != null ? patient.getPhone() : "N/A";
                                                    patientEmail = patient.getEmail() != null ? patient.getEmail() : "N/A";
                                                }
                                        %>
                                            <tr data-status="<%= status.toLowerCase() %>" data-patient="<%= appointment.getPatientName().toLowerCase() %>">
                                                <td>
                                                    <div class="d-flex align-items-center">
                                                        <div class="icon-box icon-primary me-3">
                                                            <i class="fas fa-user"></i>
                                                        </div>
                                                        <div>
                                                            <strong class="d-block"><%= appointment.getPatientName() %></strong>
                                                            <small class="text-muted">ID: PAT<%= appointment.getPatientId() %></small>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-muted">
                                                        <div class="mb-1">
                                                            <i class="fas fa-phone me-2"></i> 
                                                            <span class="small"><%= patientPhone %></span>
                                                        </div>
                                                        <div>
                                                            <i class="fas fa-envelope me-2"></i> 
                                                            <span class="small"><%= patientEmail %></span>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <strong class="d-block"><%= appointment.getAppointmentDate() %></strong>
                                                    <small class="text-muted">
                                                        <i class="fas fa-clock me-1"></i>
                                                        <%= appointment.getAppointmentTime() %>
                                                    </small>
                                                </td>
                                                <td>
                                                    <span class="badge bg-light text-dark">
                                                        <i class="<%= "In-person".equals(appointment.getAppointmentType()) ? "fas fa-hospital-user" : "fas fa-laptop-medical" %> me-1"></i>
                                                        <%= appointment.getAppointmentType() %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="text-truncate d-inline-block" style="max-width: 200px;" 
                                                          data-bs-toggle="tooltip" title="<%= appointment.getReason() %>">
                                                        <%= appointment.getReason().length() > 50 ? appointment.getReason().substring(0, 50) + "..." : appointment.getReason() %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="badge <%= statusBadgeClass %> mb-1">
                                                        <i class="<%= statusIcon %> me-1"></i>
                                                        <%= status %>
                                                    </span>
                                                    <%
                                                        if (appointment.isFollowUpRequired()) {
                                                    %>
                                                        <br>
                                                        <small class="text-warning d-block mt-1">
                                                            <i class="fas fa-redo me-1"></i>Follow-up Required
                                                        </small>
                                                    <%
                                                        }
                                                    %>
                                                    <%-- Check if prescription exists from the map --%>
                                                    <%
                                                        if ("Completed".equals(status) && prescriptionMap.containsKey(appointment.getId())) {
                                                    %>
                                                        <br>
                                                        <small class="text-success d-block mt-1" data-bs-toggle="tooltip" title="Prescription Added">
                                                            <i class="fas fa-file-prescription me-1"></i>Prescription
                                                        </small>
                                                    <%
                                                        }
                                                    %>
                                                </td>
                                                <td>
                                                    <div class="action-buttons">
                                                        <a href="${pageContext.request.contextPath}/doctor/appointment?action=details&id=<%= appointment.getId() %>"
                                                           class="btn btn-outline-primary btn-sm" data-bs-toggle="tooltip" title="View Details">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                        <%
                                                            if (!"Completed".equals(status) && !"Cancelled".equals(status)) {
                                                        %>
                                                            <div class="dropdown">
                                                                <button class="btn btn-outline-warning btn-sm dropdown-toggle" type="button"
                                                                        id="dropdownMenuButton<%= appointment.getId() %>" data-bs-toggle="dropdown" 
                                                                        aria-expanded="false" data-bs-toggle="tooltip" title="Update Status">
                                                                    <i class="fas fa-edit"></i>
                                                                </button>
                                                                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownMenuButton<%= appointment.getId() %>">
                                                                    <%
                                                                        if (!"Confirmed".equals(status)) {
                                                                    %>
                                                                        <li>
                                                                            <form action="${pageContext.request.contextPath}/doctor/appointment?action=updateStatus" method="post" class="d-inline">
                                                                                <input type="hidden" name="appointmentId" value="<%= appointment.getId() %>">
                                                                                <input type="hidden" name="status" value="Confirmed">
                                                                                <button type="submit" class="dropdown-item text-success">
                                                                                    <i class="fas fa-check me-2"></i>Confirm Appointment
                                                                                </button>
                                                                            </form>
                                                                        </li>
                                                                    <%
                                                                        }
                                                                        if (!"Completed".equals(status)) {
                                                                    %>
                                                                        
                                                                        <li>
                                                                            <button type="button" class="dropdown-item text-info complete-appointment-btn"
                                                                                    data-bs-toggle="modal"
                                                                                    data-bs-target="#prescriptionFormModal"
                                                                                    data-appointment-id="<%= appointment.getId() %>">
                                                                                <i class="fas fa-calendar-check me-2"></i>Mark as Completed
                                                                            </button>
                                                                        </li>
                                                                        <%
                                                                        }
                                                                    %>
                                                                    <li>
                                                                        <form action="${pageContext.request.contextPath}/doctor/appointment?action=updateStatus" method="post" class="d-inline" id="cancelForm<%= appointment.getId() %>">
                                                                            <input type="hidden" name="appointmentId" value="<%= appointment.getId() %>">
                                                                            <input type="hidden" name="status" value="Cancelled">
                                                                            <button type="button" class="dropdown-item text-danger cancel-appointment-btn"
                                                                                    data-bs-toggle="modal"
                                                                                    data-bs-target="#deleteConfirmModal"
                                                                                    data-form-id="cancelForm<%= appointment.getId() %>"
                                                                                    data-item-name="Appointment #<%= appointment.getId() %>">
                                                                                <i class="fas fa-times me-2"></i>Cancel Appointment
                                                                            </button>
                                                                        </form>
                                                                    </li>
                                                                    <li><hr class="dropdown-divider"></li>
                                                                    <li>
                                                                        <form action="${pageContext.request.contextPath}/doctor/appointment?action=updateFollowUp" method="post" class="d-inline">
                                                                            <input type="hidden" name="appointmentId" value="<%= appointment.getId() %>">
                                                                            <input type="hidden" name="followUpRequired" value="<%= !appointment.isFollowUpRequired() %>">
                                                                            <button type="submit" class="dropdown-item text-warning">
                                                                                <i class="fas fa-redo me-2"></i>
                                                                                <%= appointment.isFollowUpRequired() ? "Remove Follow-up" : "Mark for Follow-up" %>
                                                                            </button>
                                                                        </form>
                                                                    </li>
                                                                </ul>
                                                            </div>
                                                        <%
                                                            } else if ("Completed".equals(status)) {
                                                        %>
                                                            <%-- UPDATED: Use button to trigger new view prescription modal --%>
                                                            <button type="button" class="btn btn-outline-success btn-sm view-prescription-btn" 
                                                                    data-bs-toggle="modal" data-bs-target="#viewPrescriptionModal" 
                                                                    data-appointment-id="<%= appointment.getId() %>" 
                                                                    data-bs-toggle="tooltip" title="View Prescription">
                                                                <i class="fas fa-file-medical"></i>
                                                            </button>
                                                        <%
                                                            }
                                                        %>
                                                </td>
                                            </tr>
                                        <%
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    <%
                    }
                %>
                </div>
            </div>
        </div>
    </main>

    <div class="modal fade" id="deleteConfirmModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title text-danger" id="deleteModalLabel">
                        <i class="fas fa-exclamation-triangle me-2"></i>Confirm Cancellation
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center py-4">
                    <div class="delete-modal-icon mb-3">
                        <i class="fas fa-exclamation-triangle fa-3x text-danger"></i>
                    </div>
                    <h4 class="mb-3">Cancel Appointment?</h4>
                    <p class="text-muted">Are you sure you want to cancel <strong id="itemNameToDelete" class="text-danger">this appointment</strong>?</p>
                    <p class="text-muted small">This action cannot be undone and will notify the patient.</p>
                </div>
                <div class="modal-footer justify-content-center">
                    <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">
                        <i class="fas fa-times me-2"></i>Keep Appointment
                    </button>
                    <button type="button" class="btn btn-danger px-4" id="modalConfirmDeleteButton">
                        <i class="fas fa-check me-2"></i>Yes, Cancel
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="prescriptionFormModal" tabindex="-1" aria-labelledby="prescriptionFormModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered">
            <div class="modal-content">
                
                <form id="prescriptionForm" action="${pageContext.request.contextPath}/doctor/addPrescription" method="post">
                    <div class="modal-header">
                        <h5 class="modal-title text-primary" id="prescriptionFormModalLabel">
                            <i class="fas fa-file-medical me-2"></i>Create Prescription
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    
                    <div class="modal-body p-4" style="background-color: #f8f9fa;">
                        
                        <input type="hidden" name="appointmentId" id="modalPrescriptionAppointmentId" value="">
                        
                        <div class="row g-3">
                            <div class="col-lg-5">
                                <div class="card h-100">
                                    <div class="card-body">
                                        <h5 class="card-title mb-3">
                                            <i class="fas fa-stethoscope me-2"></i>Clinical Details
                                        </h5>
                                        <div class="mb-3">
                                            <label for="diagnosis" class="form-label fw-bold">Diagnosis*</label>
                                            <input type="text" class="form-control" id="diagnosis" name="diagnosis" 
                                                   placeholder="e.g., Viral Fever" required>
                                        </div>
                                        <div class="mb-3">
                                            <label for="adviceNotes" class="form-label fw-bold">Advice & Notes</label>
                                            <textarea class="form-control" id="adviceNotes" name="adviceNotes" rows="5"
                                                      placeholder="e.g., Complete bed rest, stay hydrated..."></textarea>
                                        </div>
                                        <div class="mb-3">
                                            <label for="followUpDate" class="form-label fw-bold">Follow-up Date (Optional)</label>
                                            <input type="date" class="form-control" id="followUpDate" name="followUpDate">
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="col-lg-7">
                                <div class="card h-100">
                                    <div class="card-body">
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <h5 class="card-title mb-0">
                                                <i class="fas fa-pills me-2"></i>Medications (Rx)
                                            </h5>
                                            <button type="button" class="btn btn-sm btn-success" id="addMedicationRow">
                                                <i class="fas fa-plus me-1"></i> Add Row
                                            </button>
                                        </div>

                                        <div class="table-responsive" style="max-height: 350px; overflow-y: auto;">
                                            <table class="table table-sm" id="medicationTable">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th style="width: 40%;">Medicine*</th>
                                                        <th style="width: 15%;">Dosage</th>
                                                        <th style="width: 20%;">Frequency</th>
                                                        <th style="width: 20%;">Duration</th>
                                                        <th style="width: 5%;"></th>
                                                    </tr>
                                                </thead>
                                                <tbody id="medicationList">
                                                    </tbody>
                                            </table>
                                        </div>
                                        <div id="noMedsMessage" class="text-center text-muted p-3">
                                            <small>Click "Add Row" to add medications.</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save me-2"></i>Complete and Save Prescription
                        </button>
                    </div>
                </form>
                
                <template id="medicationRowTemplate">
                    <tr>
                        <td>
                            <input type="text" class="form-control form-control-sm" name="medicineName" placeholder="e.g., Paracetamol" required>
                        </td>
                        <td>
                            <input type="text" class="form-control form-control-sm" name="dosage" placeholder="500mg">
                        </td>
                        <td>
                            <input type="text" class="form-control form-control-sm" name="frequency" placeholder="1-1-1">
                        </td>
                        <td>
                            <input type="text" class="form-control form-control-sm" name="duration" placeholder="3 Days">
                        </td>
                        <td>
                            <button type="button" class="btn btn-sm btn-outline-danger remove-med-row">
                                <i class="fas fa-times"></i>
                            </button>
                        </td>
                    </tr>
                </template>
                
            </div>
        </div>
    </div>
    
    <!-- Enhanced View Prescription Modal -->
    <div class="modal fade" id="viewPrescriptionModal" tabindex="-1" aria-labelledby="viewPrescriptionModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-xl modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="viewPrescriptionModalLabel">
                        <i class="fas fa-file-medical me-2"></i>Prescription Details
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div id="prescriptionDetailsContent">
                        <div class="text-center p-5">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                            <p class="mt-2 text-muted">Loading prescription details...</p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 🟢 Client-side access to the prescription data (JSON object from server)
        const prescriptionMapClient = JSON.parse('<%= prescriptionJson %>');

        document.addEventListener('DOMContentLoaded', function() {
            // Mobile menu functionality
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

            if (mobileMenuToggle) {
                checkScreenSize();
                window.addEventListener('resize', checkScreenSize);

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

            // Auto-hide alerts
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                setTimeout(() => {
                    const bsAlert = new bootstrap.Alert(alert);
                    bsAlert.close();
                }, 5000);
            });

            // Initialize tooltips
            const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });

            // Filter functionality
            const statusFilter = document.getElementById('statusFilter');
            const searchPatient = document.getElementById('searchPatient');
            const clearFilters = document.getElementById('clearFilters');
            const tableRows = document.querySelectorAll('#appointmentsTable tbody tr');

            function filterAppointments() {
                const statusValue = statusFilter.value;
                const searchValue = searchPatient.value.toLowerCase();

                tableRows.forEach(row => {
                    const status = row.getAttribute('data-status');
                    const patient = row.getAttribute('data-patient');

                    const statusMatch = statusValue === 'all' || status === statusValue.toLowerCase();
                    const searchMatch = patient.includes(searchValue);

                    if (statusMatch && searchMatch) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            }

            if (statusFilter) statusFilter.addEventListener('change', filterAppointments);
            if (searchPatient) searchPatient.addEventListener('input', filterAppointments);
            if (clearFilters) {
                clearFilters.addEventListener('click', function() {
                    statusFilter.value = 'all';
                    searchPatient.value = '';
                    filterAppointments();
                });
            }

            // Enhanced modal functionality (for Cancel)
            const deleteConfirmModal = document.getElementById('deleteConfirmModal');
            let formToSubmit = null;

            if (deleteConfirmModal) {
                deleteConfirmModal.addEventListener('show.bs.modal', function (event) {
                    const button = event.relatedTarget;
                    const formId = button.getAttribute('data-form-id');
                    const itemName = button.getAttribute('data-item-name');
                    
                    formToSubmit = document.getElementById(formId);
                    
                    const modalItemNameElement = document.getElementById('itemNameToDelete');
                    if (modalItemNameElement) {
                        modalItemNameElement.textContent = itemName ? `${itemName}` : 'this appointment';
                    }
                });

                const modalConfirmDeleteButton = document.getElementById('modalConfirmDeleteButton');
                if (modalConfirmDeleteButton) {
                    modalConfirmDeleteButton.addEventListener('click', function () {
                        if (formToSubmit) {
                            formToSubmit.submit();
                        }
                    });
                }
            }
            
            // --- Script for Prescription Form (Mark as Completed) ---
            const prescriptionModal = document.getElementById('prescriptionFormModal');
            const addMedicationButton = document.getElementById('addMedicationRow');
            const medicationListBody = document.getElementById('medicationList');
            const medicationTemplate = document.getElementById('medicationRowTemplate');
            const noMedsMessage = document.getElementById('noMedsMessage');

            // Function to add a new row
            function addMedicationRow() {
                if (medicationTemplate) {
                    const newRow = medicationTemplate.content.cloneNode(true);
                    if (medicationListBody) medicationListBody.appendChild(newRow);
                    if (noMedsMessage) noMedsMessage.style.display = 'none';
                }
            }

            // 1. Listen for the "Add Row" button click
            if(addMedicationButton) {
                addMedicationButton.addEventListener('click', addMedicationRow);
            }

            // 2. Listen for "Remove Row" clicks (using event delegation)
            if(medicationListBody) {
                medicationListBody.addEventListener('click', function(event) {
                    const removeButton = event.target.closest('.remove-med-row');
                    if (removeButton) {
                        removeButton.closest('tr').remove();
                        
                        // Show message if no rows are left
                        if (medicationListBody.children.length === 0 && noMedsMessage) {
                            noMedsMessage.style.display = 'block';
                        }
                    }
                });
            }

            // 3. When the modal opens, set the appointment ID and clear old data
            if(prescriptionModal) {
                prescriptionModal.addEventListener('show.bs.modal', function (event) {
                    const button = event.relatedTarget;
                    if (button) {
                        const appointmentId = button.getAttribute('data-appointment-id');
                        const modalInput = document.getElementById('modalPrescriptionAppointmentId');
                        if (modalInput) modalInput.value = appointmentId;
                    }
                    
                    const presForm = document.getElementById('prescriptionForm');
                    if (presForm) presForm.reset();
                    
                    if (medicationListBody) medicationListBody.innerHTML = ''; 
                    if (noMedsMessage) noMedsMessage.style.display = 'block'; 
                    
                    addMedicationRow();
                });
            }

            // 🟢 ENHANCED: Script for View Prescription Modal with Patient-Style Layout
            const viewPrescriptionModal = document.getElementById('viewPrescriptionModal');
            const prescriptionDetailsContent = document.getElementById('prescriptionDetailsContent');

            if (viewPrescriptionModal) {
                viewPrescriptionModal.addEventListener('show.bs.modal', function (event) {
                    const button = event.relatedTarget;
                    const appointmentId = button.getAttribute('data-appointment-id');
                    
                    // Clear previous content and show loading
                    prescriptionDetailsContent.innerHTML = `
                        <div class="text-center p-5">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                            <p class="mt-2 text-muted">Loading prescription details...</p>
                        </div>
                    `;
                    
                    const prescription = prescriptionMapClient[appointmentId];
                    
                    if (prescription) {
                        let html = '';
                        
                        // Create the exact same layout as patient's prescription page
                        html += `
                            <div class="row">
                                <!-- Prescription Details Card - Exactly like patient view -->
                                <div class="col-12">
                                    <div class="card h-100 prescription-card">
                                        <div class="card-header bg-transparent">
                                            <h5 class="card-title mb-0">
                                                <i class="fas fa-file-medical me-2"></i>Doctor's Prescription
                                            </h5>
                                        </div>
                                        <div class="card-body">
                        `;

                        // Diagnosis Section
                        html += `
                                            <div class="prescription-section">
                                                <h5><i class="fas fa-stethoscope me-2"></i>Diagnosis</h5>
                                                <p class="card-text">${prescription.diagnosis || "N/A"}</p>
                                            </div>
                        `;

                        // Medications Section
                        html += `
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
                        `;
                        
                        const meds = prescription.medications || [];
                        if (meds.length > 0) {
                            meds.forEach(med => {
                                html += `
                                                            <tr>
                                                                <td>${med.medicineName || "N/A"}</td>
                                                                <td>${med.dosage || "N/A"}</td>
                                                                <td>${med.frequency || "N/A"}</td>
                                                                <td>${med.duration || "N/A"}</td>
                                                            </tr>
                                `;
                            });
                        } else {
                            html += `
                                                            <tr>
                                                                <td colspan="4" class="text-center text-muted">No medications prescribed.</td>
                                                            </tr>
                            `;
                        }

                        html += `
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                        `;

                        // Advice Section
                        const adviceNotes = prescription.adviceNotes || "No specific advice given.";
                        html += `
                                            <div class="prescription-section">
                                                <h5><i class="fas fa-comment-medical me-2"></i>Doctor's Advice</h5>
                                                <p class="card-text">${adviceNotes}</p>
                                            </div>
                        `;

                        // Follow-up Section
                        const followUpDate = prescription.followUpDate;
                        const followUpText = followUpDate && followUpDate !== "null" 
                            ? `Please follow-up on <strong>${followUpDate}</strong>` 
                            : "No follow-up required.";
                            
                        html += `
                                            <div class="prescription-section">
                                                <h5><i class="fas fa-calendar-alt me-2"></i>Follow-up</h5>
                                                <p class="card-text">${followUpText}</p>
                                            </div>
                        `;

                        // Close the card structure
                        html += `
                                        </div>
                                    </div>
                                </div>
                            </div>
                        `;
                        
                        prescriptionDetailsContent.innerHTML = html;
                        
                    } else {
                        // No Prescription Available Message
                        prescriptionDetailsContent.innerHTML = `
                            <div class="text-center p-4">
                                <i class="fas fa-file-alt fa-3x text-muted mb-3"></i>
                                <h5 class="text-muted">No Prescription Available</h5>
                                <p class="text-muted mb-0">The prescription details could not be loaded for this appointment.</p>
                            </div>
                        `;
                    }
                });
                
                // Clear content when modal is hidden
                viewPrescriptionModal.addEventListener('hidden.bs.modal', function () {
                    prescriptionDetailsContent.innerHTML = '';
                });
            }

            // Add smooth animations
            const observerOptions = {
                threshold: 0.1,
                rootMargin: '0px 0px -50px 0px'
            };

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateY(0)';
                    }
                });
            }, observerOptions);

            document.querySelectorAll('.card, .stat-card').forEach(el => {
                el.style.opacity = '0';
                el.style.transform = 'translateY(20px)';
                el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
                observer.observe(el);
            });
        });
    </script>
</body>
</html>