<%@ page import="com.entity.Patient" %>
<%@ page import="com.dao.AppointmentDao" %>
<%@ page import="com.entity.Appointment" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="com.dao.PrescriptionDao" %> 
<%@ page import="com.entity.Prescription" %> 
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Set" %> <%-- --- NEW IMPORT --- --%>
<%@ page import="java.util.HashSet" %> <%-- --- NEW IMPORT --- --%>
<%@ page import="com.dao.ReviewDao" %> <%-- --- ADD THIS LINE --- --%>
<%
    Patient currentPatient = (Patient) session.getAttribute("patientObj");
    if (currentPatient == null) {
        response.sendRedirect(request.getContextPath() + "/patient/login.jsp"); 
        return;
    }

    // --- THIS DATA NOW COMES FROM THE SERVLET ---
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    Map<Integer, Prescription> prescriptionMap = (Map<Integer, Prescription>) request.getAttribute("prescriptionMap");
    Set<Integer> reviewedIds = (Set<Integer>) request.getAttribute("reviewedIds"); // --- NEW ---

    // --- Fallback in case servlet fails or page is accessed directly ---
    if (appointments == null) {
        AppointmentDao appointmentDao = new AppointmentDao();
        appointments = appointmentDao.getAppointmentsByPatientId(currentPatient.getId());
    }
    if (prescriptionMap == null) {
        prescriptionMap = new HashMap<>(); // Create an empty map to avoid JSP errors
    }
    if (reviewedIds == null) {
        reviewedIds = new HashSet<>(); // Create an empty set to avoid errors
        // Safety net to build reviewedIds if servlet failed
        ReviewDao reviewDao = new ReviewDao();
        if(appointments != null) {
            for (Appointment appt : appointments) {
                if ("Completed".equals(appt.getStatus())) {
                    if (reviewDao.hasPatientReviewed(appt.getId())) {
                        reviewedIds.add(appt.getId());
                    }
                }
            }
        }
    }
    // --- END FALLBACK ---

    long pendingCount = appointments.stream().filter(a -> a.getStatus() == null || "Pending".equals(a.getStatus())).count();
    long confirmedCount = appointments.stream().filter(a -> "Confirmed".equals(a.getStatus())).count();
    long completedCount = appointments.stream().filter(a -> "Completed".equals(a.getStatus())).count();
    long cancelledCount = appointments.stream().filter(a -> "Cancelled".equals(a.getStatus())).count();

    String currentUserRole = "patient";
    
    // --- ROBUST MESSAGE HANDLING ---
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
    // --- END MESSAGE HANDLING ---
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Care System - My Appointments</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- --- NEW CSS FOR STAR RATING --- -->
    <style>
        .star-rating-input {
            display: flex;
            flex-direction: row-reverse;
            justify-content: center;
            font-size: 2.5rem; /* Make stars bigger */
        }
        .star-rating-input input {
            display: none; /* Hide radio buttons */
        }
        .star-rating-input label {
            color: #ccc;
            cursor: pointer;
            transition: color 0.2s;
            padding: 0 0.25rem;
        }
        .star-rating-input input:checked ~ label,
        .star-rating-input label:hover,
        .star-rating-input label:hover ~ label {
            color: #ffc107; /* Bootstrap yellow */
        }
    #feedbackModal .modal-dialog {
        max-width: 50% !important;
        margin: auto;
    }

    /* Optional: Make the modal content nicely rounded */
    #feedbackModal .modal-content {
        border-radius: 12px;
    }

    /* Center fade modal if needed */
    .modal.fade-centered .modal-dialog {
        display: flex;
        align-items: center;
        min-height: 100vh;
    }
    .table-responsive{
    overflow-x:auto;
    }
    </style>
</head>
<body>
    
    <!-- --- FIXED: Added missing mobile sidebar buttons --- -->
    <button class="mobile-menu-toggle" id="mobileMenuToggle" style="display: none;">
        <i class="fas fa-bars"></i>
    </button>
    
    <div class="sidebar-overlay" id="sidebarOverlay"></div>
    <!-- --- END FIX --- -->

    <div class="sidebar" id="sidebar">
        <div class="sidebar-sticky">
            <div class="user-section">
                <div class="user-avatar">
                    <i class="fas fa-user-circle"></i>
                </div>
                <div class="user-info">
                    <% if (currentPatient != null) { %>
                    <h6><%= currentPatient.getFullName() %></h6>
                    <span class="badge">Patient</span>
                    <% } %>
                </div>
            </div>
            
            <div class="nav-main">
                <ul class="nav">
                    <li class="nav-item">
                        <a class="nav-link" 
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
                        <a class="nav-link active" 
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
                <i class="fas fa-list-alt"></i>
                My Appointments
            </h1>
            <a href="${pageContext.request.contextPath}/patient/appointment?action=book" class="btn btn-primary">
                <i class="fas fa-calendar-plus me-2"></i>New Appointment
            </a>
        </div>
        
        <%-- Message Display Block --%>
        <%
            if (successMsg != null && !successMsg.isEmpty()) {
        %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <div class="d-flex align-items-center">
                    <i class="fas fa-check-circle me-3 fs-5"></i>
                    <div class="flex-grow-1"><%= successMsg %></div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
            }
            if (errorMsg != null && !errorMsg.isEmpty()) {
        %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <div class="d-flex align-items-center">
                    <i class="fas fa-exclamation-triangle me-3 fs-5"></i>
                    <div class="flex-grow-1"><%= errorMsg %></div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
            }
        %>


        <div class="card">
            <div class="card-header">
                <h2 class="card-title">
                    <i class="fas fa-calendar-check"></i>
                    Appointment History
                </h2>
                <span class="badge badge-light">
                    <i class="fas fa-calendar me-1"></i>
                    <%= appointments.size() %> Total Appointments
                </span>
            </div>
            <div class="card-body">
                <%
                    if (appointments.isEmpty()) {
                %>
                    <div class="empty-state">
                        <i class="fas fa-calendar-times"></i>
                        <h4>No Appointments Found</h4>
                        <p>You haven't booked any appointments yet.</p>
                        <a href="${pageContext.request.contextPath}/patient/appointment?action=book" class="btn btn-primary">
                            <i class="fas fa-calendar-plus me-2"></i>Book Your First Appointment
                        </a>
                    </div>
                <%
                    } else {
                %>
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Doctor</th>
                                    <th>Date & Time</th>
                                    <th>Type</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (Appointment appointment : appointments) {
                                        String statusBadgeClass = "";
                                        String statusIcon = "";
                                        
                                        String status = appointment.getStatus();
                                        if (status == null) {
                                            status = "Pending";
                                        }
                                        
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
                                                statusBadgeClass = "badge-light";
                                                statusIcon = "fas fa-question-circle";
                                                break;
                                        }
                                        
                                        // Get prescription from the map we built at the top
                                        Prescription prescription = prescriptionMap.get(appointment.getId());
                                %>
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="doctor-avatar">
                                                    <i class="fas fa-user-md"></i>
                                                </div>
                                                <div>
                                                    <strong>Dr. <%= appointment.getDoctorName() %></strong>
                                                    <div class="text-muted" style="font-size: 0.875rem;">
                                                        <%= appointment.getDoctorSpecialization() %>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div>
                                                <strong><%= appointment.getAppointmentDate() %></strong>
                                                <div class="text-muted" style="font-size: 0.875rem;">
                                                    <i class="fas fa-clock me-1"></i>
                                                    <%= appointment.getAppointmentTime() %>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge badge-light">
                                                <i class="<%= "In-person".equals(appointment.getAppointmentType()) ? "fas fa-user" : "fas fa-laptop" %> me-1"></i>
                                                <%= appointment.getAppointmentType() %>
                                            </span>
                                        </td>
                                        
                                        <td>
                                            <span class="badge <%= statusBadgeClass %>">
                                                <i class="<%= statusIcon %> me-1"></i>
                                                <%= status %>
                                            </span>
                                            <%
                                                if (appointment.isFollowUpRequired()) {
                                            %>
                                                <div class="text-warning mt-1" style="font-size: 0.75rem;">
                                                    <i class="fas fa-redo me-1"></i>Follow-up required
                                                </div>
                                            <%
                                                }
                                            %>
                                            
                                            <%
                                                if (prescription != null) {
                                            %>
                                                <div class="text-info mt-1" style="font-size: 0.75rem;" 
                                                     data-bs-toggle="tooltip" title="Prescription available. Click 'View Prescription' to see it.">
                                                    <i class="fas fa-file-prescription me-1"></i>Prescription Added
                                                </div>
                                            <%
                                                }
                                            %>
                                        </td>
                                        
                                        <%-- --- UPDATED ACTIONS CELL --- --%>
                                        <td>
                                            <div class="btn-group">
                                                <%
                                                    if ("Pending".equals(status)) {
                                                %>
                                                    <!-- Show Edit and Cancel for Pending -->
                                                    <a href="${pageContext.request.contextPath}/patient/appointment?action=edit&id=<%= appointment.getId() %>"
                                                       class="btn btn-outline-warning btn-sm" data-bs-toggle="tooltip" title="Edit Appointment">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    
                                                    <form action="${pageContext.request.contextPath}/patient/appointment?action=cancel" method="post" class="d-inline" id="deleteForm<%= appointment.getId() %>">
                                                        <input type="hidden" name="id" value="<%= appointment.getId() %>">
                                                        <button type="button" class="btn btn-outline-danger btn-sm cancel-appointment-btn"
                                                                data-bs-toggle="modal" 
                                                                data-bs-target="#deleteConfirmModal"
                                                                data-form-id="deleteForm<%= appointment.getId() %>"
                                                                data-item-name="Appointment #<%= appointment.getId() %>"
                                                                data-bs-toggle="tooltip" title="Cancel Appointment">
                                                            <i class="fas fa-times"></i>
                                                        </button>
                                                    </form>
                                                <%
                                                    } else {
                                                %>
                                                    <!-- Show View Details for Confirmed, Cancelled, or Completed -->
                                                    <a href="${pageContext.request.contextPath}/patient/appointment?action=details&id=<%= appointment.getId() %>"
                                                       class="btn btn-outline-primary btn-sm" data-bs-toggle="tooltip" title="View Appointment Details">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                <%
                                                    }
                                                %>
                                                
                                                <%-- Also show View Prescription if it exists --%>
                                                <%
                                                    if ("Completed".equals(status) && prescription != null) {
                                                %>
                                                    <a href="${pageContext.request.contextPath}/patient/appointment?action=prescription&id=<%= appointment.getId() %>"
                                                       class="btn btn-outline-success btn-sm" data-bs-toggle="tooltip" title="View Prescription">
                                                        <i class="fas fa-file-medical"></i>
                                                    </a>
                                                <%
                                                    }
                                                %>
                                                
                                                <%-- --- NEW: Leave Feedback Button --- --%>
                                                <%
                                                    if ("Completed".equals(status)) {
                                                        if (reviewedIds.contains(appointment.getId())) {
                                                %>
                                                            <button class="btn btn-outline-secondary btn-sm" disabled data-bs-toggle="tooltip" title="Feedback Submitted">
                                                                <i class="fas fa-star"></i>
                                                            </button>
                                                <%
                                                        } else {
                                                %>
                                                            <button class="btn btn-outline-warning btn-sm feedback-btn"
                                                                    data-bs-toggle="modal"
                                                                    data-bs-target="#feedbackModal"
                                                                    data-appointment-id="<%= appointment.getId() %>"
                                                                    data-doctor-id="<%= appointment.getDoctorId() %>"
                                                                    data-doctor-name="<%= appointment.getDoctorName() %>"
                                                                    data-bs-toggle="tooltip" title="Leave Feedback">
                                                                <i class="far fa-star"></i>
                                                            </button>
                                                <%
                                                        }
                                                    }
                                                %>
                                                <%-- --- END NEW --- --%>
                                            </div>
                                        </td>
                                        <%-- --- END UPDATED ACTIONS CELL --- --%>
                                    </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>

                    <div class="stats-grid">
                        <div class="stats-card stats-pending">
                            <div class="stats-number"><%= pendingCount %></div>
                            <div class="stats-label">Pending</div>
                        </div>
                        <div class="stats-card stats-confirmed">
                            <div class="stats-number"><%= confirmedCount %></div>
                            <div class="stats-label">Confirmed</div>
                        </div>
                        <div class="stats-card stats-completed">
                            <div class="stats-number"><%= completedCount %></div>
                            <div class="stats-label">Completed</div>
                        </div>
                        <div class="stats-card stats-cancelled">
                            <div class="stats-number"><%= cancelledCount %></div>
                            <div class="stats-label">Cancelled</div>
                        </div>
                    </div>
                <%
                    }
                %>
            </div>
        </div>
    </main>

    <!-- --- Cancel Modal (Fixed) --- -->
    <div class="modal fade" id="deleteConfirmModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 400px; margin: auto;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="delete-modal-icon">
                        <i class="fas fa-exclamation-triangle fa-3x"></i>
                    </div>
                    <h4>Confirm Cancellation</h4>
                    <p class="mb-0">Are you sure you want to cancel <strong id="itemNameToDelete" class="text-danger">this appointment</strong>?</p>
                    <p class="text-muted small mt-2">This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Keep It</button>
                    <button type="button" class="btn btn-danger" id="modalConfirmDeleteButton">
                        <i class="fas fa-times me-1"></i>Yes, Cancel
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    
    <!-- --- NEW: Feedback & Rating Modal --- -->
    <div class="modal fade-centered" id="feedbackModal" tabindex="-1" aria-labelledby="feedbackModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/patient/addReview" method="POST">
                    <div class="modal-header">
                        <h5 class="modal-title" id="feedbackModalLabel">Leave Feedback</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-center">
                        <p class="text-muted">How was your experience with <strong id="modalDoctorName">Dr. Name</strong>?</p>
                        
                        <!-- Hidden inputs for the servlet -->
                        <input type="hidden" name="appointmentId" id="modalAppointmentId" value="">
                        <input type="hidden" name="doctorId" id="modalDoctorId" value="">
                        
                        <!-- Star Rating Input -->
                        <div class="star-rating-input mb-3" id="starRating">
                            <input type="radio" name="rating" id="star5" value="5"><label for="star5" title="5 stars" class="fas fa-star"></label>
                            <input type="radio" name="rating" id="star4" value="4"><label for="star4" title="4 stars" class="fas fa-star"></label>
                            <input type="radio" name="rating" id="star3" value="3"><label for="star3" title="3 stars" class="fas fa-star"></label>
                            <input type="radio" name="rating" id="star2" value="2"><label for="star2" title="2 stars" class="fas fa-star"></label>
                            <input type="radio" name="rating" id="star1" value="1"><label for="star1" title="1 star" class="fas fa-star"></label>
                        </div>
                        
                        <!-- Comment Box -->
                        <div class="form-group text-start">
                            <label for="comment" class="form-label">Add a comment (optional):</label>
                            <textarea class="form-control" id="comment" name="comment" rows="4" placeholder="Share your experience..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Submit Feedback</button>
                    </div>
                </form>
            </div>
        </div>
    </div>


    <!-- --- FIXED: ADDED FULL JAVASCRIPT BLOCK --- -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            
            // --- 1. Mobile Menu Functionality ---
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

            // --- 2. Auto-hide success alerts ---
            const successAlerts = document.querySelectorAll('.alert-success.alert-dismissible');
            successAlerts.forEach(function(alert) {
                setTimeout(function() {
                    const bsAlert = bootstrap.Alert.getInstance(alert) || new bootstrap.Alert(alert);
                    if (bsAlert) {
                        bsAlert.close();
                    }
                }, 5000); 
            });

            // --- 3. Cancel Modal Logic ---
            const deleteConfirmModal = document.getElementById('deleteConfirmModal');
            let formToSubmit = null; 

            if (deleteConfirmModal) {
                deleteConfirmModal.addEventListener('show.bs.modal', function (event) {
                    const button = event.relatedTarget;
                    const formId = button.getAttribute('data-form-id');
                    const itemName = button.getAttribute('data-item-name');
                    formToSubmit = document.getElementById(formId);
                    
                    const modalItemNameElement = document.getElementById('itemNameToDelete');
                    if(modalItemNameElement) {
                        modalItemNameElement.textContent = itemName ? `${itemName}` : 'this item';
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
            
            // --- 4. Initialize tooltips ---
            const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
            
            
            // --- 5. NEW: Feedback Modal & Star Rating Logic ---
            const feedbackModal = document.getElementById('feedbackModal');
            if (feedbackModal) {
                const starRatingContainer = document.getElementById('starRating');
                const ratingValueInput = document.getElementById('ratingValue'); // This is the hidden input

                // Handle star selection
                starRatingContainer.addEventListener('click', function(e) {
                    if (e.target.name === 'rating') {
                        // Note: The hidden input 'ratingValue' is NOT used by the form.
                        // The form directly uses the 'rating' radio button value.
                        // We just update this for clarity, but it's optional.
                        if(ratingValueInput) ratingValueInput.value = e.target.value;
                    }
                });

                // Pass data to modal when it opens
                feedbackModal.addEventListener('show.bs.modal', function(event) {
                    const button = event.relatedTarget;
                    const appointmentId = button.getAttribute('data-appointment-id');
                    const doctorId = button.getAttribute('data-doctor-id');
                    const doctorName = button.getAttribute('data-doctor-name');

                    document.getElementById('modalAppointmentId').value = appointmentId;
                    document.getElementById('modalDoctorId').value = doctorId;
                    document.getElementById('modalDoctorName').innerText = "Dr. " + doctorName;
                    
                    // Reset form
                    document.getElementById('comment').value = '';
                    if(ratingValueInput) ratingValueInput.value = 0;
                    
                    const stars = starRatingContainer.querySelectorAll('input');
                    for (const star of stars) {
                        star.checked = false;
                    }
                });
            }

        });
    </script>
</body>
</html>