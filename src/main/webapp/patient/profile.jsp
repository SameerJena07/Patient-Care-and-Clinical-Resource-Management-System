<%@ page import="com.entity.Patient" %>
<%@ page import="java.util.List" %>
<%@ page import="com.entity.Appointment" %>

<%
    // Check if the patient is logged in
    Patient currentPatient = (Patient) session.getAttribute("patientObj");

    if (currentPatient == null) {
        response.sendRedirect(request.getContextPath() + "/patient/login.jsp");
        return;
    } 

    String currentUserRole = "patient";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Care System - Patient Profile</title>
    
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
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
                    <h6><%= currentPatient.getFullName() %></h6>
                    <span class="badge">Patient</span>
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
                        <a class="nav-link active" 
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
    
    <main class="main-content main-content-flush">
        <div class="profile-header">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="h2 mb-2">
                        <i class="fas fa-user me-2"></i>
                        My Profile
                    </h1>
                    <p class="mb-0 opacity-75">Manage your personal information and health details</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/patient/dashboard.jsp" class="back-link">
                        <i class="fas fa-arrow-left me-2"></i>Back to Dashboard
                    </a>
                </div>
            </div>
        </div>

        <div class="profile-body-wrapper">

            <%
                String successMsg = (String) request.getAttribute("successMsg");
                String errorMsg = (String) request.getAttribute("errorMsg");
                
                if (successMsg != null && !successMsg.isEmpty()) {
            %>
                <div class="alert alert-success alert-dismissible fade show mb-4" role="alert">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-check-circle me-3 fs-5"></i>
                        <div class="flex-grow-1"><%= successMsg %></div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <%
                    request.removeAttribute("successMsg");
                }
                if (errorMsg != null && !errorMsg.isEmpty()) {
            %>
                <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-exclamation-triangle me-3 fs-5"></i>
                        <div class="flex-grow-1"><%= errorMsg %></div>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <%
                    request.removeAttribute("errorMsg");
                }
            %>

            <div class="row">
                <div class="col-lg-8">
                    <div class="card mb-4">
                        <div class="card-header">
                            <h2 class="card-title">
                                <i class="fas fa-edit"></i>
                                Update Profile Information
                            </h2>
                        </div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/patient/profile?action=update" method="post" class="needs-validation" novalidate>
                                <div class="form-section">
                                    <h3 class="section-title">Personal Information</h3>
                                    <div class="row">
                                        <div class="col-md-6 form-field">
                                            <label for="fullName" class="form-label">Full Name</label>
                                            <div class="input-group">
                                                <span class="input-group-text">
                                                    <i class="fas fa-user text-primary"></i>
                                                </span>
                                                <input type="text" class="form-control" id="fullName" name="fullName" 
                                                       value="<%= currentPatient.getFullName() %>" required>
                                            </div>
                                            <div class="invalid-feedback">Please enter your full name.</div>
                                        </div>
                                        
                                        <div class="col-md-6 form-field">
                                            <label for="email" class="form-label">Email Address</label>
                                            <div class="input-group">
                                                <span class="input-group-text">
                                                    <i class="fas fa-envelope text-primary"></i>
                                                </span>
                                                <input type="email" class="form-control" id="email" 
                                                       value="<%= currentPatient.getEmail() %>" readonly>
                                            </div>
                                            <span class="form-helper">Email cannot be changed</span>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6 form-field">
                                            <label for="phone" class="form-label">Phone Number</label>
                                            <div class="input-group">
                                                <span class="input-group-text">
                                                    <i class="fas fa-phone text-primary"></i>
                                                </span>
                                                <input type="tel" class="form-control" id="phone" name="phone" 
                                                       value="<%= currentPatient.getPhone() != null ? currentPatient.getPhone() : "" %>" required>
                                            </div>
                                            <div class="invalid-feedback">Please enter your phone number.</div>
                                        </div>
                                        
                                        <div class="col-md-6 form-field">
                                            <label for="gender" class="form-label">Gender</label>
                                            <div class="input-group">
                                                <span class="input-group-text">
                                                    <i class="fas fa-venus-mars text-primary"></i>
                                                </span>
                                                <select class="form-select" id="gender" name="gender" required>
                                                    <option value="">Select Gender</option>
                                                    <option value="Male" <%= "Male".equals(currentPatient.getGender()) ? "selected" : "" %>>Male</option>
                                                    <option value="Female" <%= "Female".equals(currentPatient.getGender()) ? "selected" : "" %>>Female</option>
                                                    <option value="Other" <%= "Other".equals(currentPatient.getGender()) ? "selected" : "" %>>Other</option>
                                                </select>
                                            </div>
                                            <div class="invalid-feedback">Please select your gender.</div>
                                        </div>
                                    </div>

                                    <div class="form-field">
                                        <label for="address" class="form-label">Address</label>
                                        <div class="input-group">
                                            <span class="input-group-text align-items-start pt-3">
                                                <i class="fas fa-home text-primary"></i>
                                            </span>
                                            <textarea class="form-control" id="address" name="address" rows="3" required><%= currentPatient.getAddress() != null ? currentPatient.getAddress() : "" %></textarea>
                                        </div>
                                        <div class="invalid-feedback">Please enter your address.</div>
                                    </div>
                                </div>

                                <div class="form-section">
                                    <h3 class="section-title">Medical Information</h3>
                                    <div class="row">
                                        <div class="col-md-4 form-field">
                                            <label for="bloodGroup" class="form-label">Blood Group</label>
                                            <div class="input-group">
                                                <span class="input-group-text">
                                                    <i class="fas fa-tint text-primary"></i>
                                                </span>
                                                <select class="form-select" id="bloodGroup" name="bloodGroup" required>
                                                    <option value="">Select Blood Group</option>
                                                    <option value="A+" <%= "A+".equals(currentPatient.getBloodGroup()) ? "selected" : "" %>>A+</option>
                                                    <option value="A-" <%= "A-".equals(currentPatient.getBloodGroup()) ? "selected" : "" %>>A-</option>
                                                    <option value="B+" <%= "B+".equals(currentPatient.getBloodGroup()) ? "selected" : "" %>>B+</option>
                                                    <option value="B-" <%= "B-".equals(currentPatient.getBloodGroup()) ? "selected" : "" %>>B-</option>
                                                    <option value="AB+" <%= "AB+".equals(currentPatient.getBloodGroup()) ? "selected" : "" %>>AB+</option>
                                                    <option value="AB-" <%= "AB-".equals(currentPatient.getBloodGroup()) ? "selected" : "" %>>AB-</option>
                                                    <option value="O+" <%= "O+".equals(currentPatient.getBloodGroup()) ? "selected" : "" %>>O+</option>
                                                    <option value="O-" <%= "O-".equals(currentPatient.getBloodGroup()) ? "selected" : "" %>>O-</option>
                                                </select>
                                            </div>
                                            <div class="invalid-feedback">Please select your blood group.</div>
                                        </div>
                                        
                                        <div class="col-md-4 form-field">
                                            <label for="dateOfBirth" class="form-label">Date of Birth</label>
                                            <div class="input-group">
                                                <span class="input-group-text">
                                                    <i class="fas fa-calendar text-primary"></i>
                                                </span>
                                                <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth" 
                                                       value="<%= currentPatient.getDateOfBirth() != null ? currentPatient.getDateOfBirth().toString() : "" %>" required>
                                            </div>
                                            <div class="invalid-feedback">Please enter your date of birth.</div>
                                        </div>
                                        
                                        <div class="col-md-4 form-field">
                                            <label for="emergencyContact" class="form-label">Emergency Contact</label>
                                            <div class="input-group">
                                                <span class="input-group-text">
                                                    <i class="fas fa-phone-alt text-primary"></i>
                                                </span>
                                                <input type="tel" class="form-control" id="emergencyContact" name="emergencyContact" 
                                                       value="<%= currentPatient.getEmergencyContact() != null ? currentPatient.getEmergencyContact() : "" %>" required>
                                            </div>
                                            <div class="invalid-feedback">Please enter emergency contact.</div>
                                        </div>
                                    </div>

                                    <div class="form-field">
                                        <label for="medicalHistory" class="form-label">Medical History</label>
                                        <div class="input-group">
                                            <span class="input-group-text align-items-start pt-3">
                                                <i class="fas fa-file-medical text-primary"></i>
                                            </span>
                                            <textarea class="form-control" id="medicalHistory" name="medicalHistory" rows="3"
                                                      placeholder="Any pre-existing conditions, allergies, or medical history"><%= currentPatient.getMedicalHistory() != null ? currentPatient.getMedicalHistory() : "" %></textarea>
                                        </div>
                                        <span class="form-helper">Optional: Include any relevant medical information for better care</span>
                                    </div>
                                </div>

                                <div class="form-actions">
                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save me-2"></i>Update Profile
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                    
                    <div class="danger-zone-card mb-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h3 class="card-title mb-1">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    <b>Danger Zone</b>
                                </h3>
                                <p class="mb-0">
                                    Permanently delete your account and all associated data. <b>This action cannot be undone.</b>
                                </p>
                            </div>
                            <button type="button" class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#deleteAccountModal">
                                <i class="fas fa-trash-alt me-2"></i>Delete Account
                            </button>
                        </div>
                    </div>
                    </div>

                <div class="col-lg-4">
                    <div class="card mb-4">
                        <div class="card-header">
                            <h2 class="card-title">
                                <i class="fas fa-info-circle"></i>
                                Profile Summary
                            </h2>
                        </div>
                        <div class="card-body">
                            <div class="text-center mb-4">
                                <div class="profile-avatar">
                                    <i class="fas fa-user"></i>
                                </div>
                                <h4 class="fw-bold mb-1"><%= currentPatient.getFullName() %></h4>
                                <p class="text-muted mb-3">Patient</p>
                                <span class="status-badge status-active">
                                    <i class="fas fa-circle me-1 small"></i> Active
                                </span>
                            </div>
                            
                            <div class="mb-4">
                                <div class="info-item">
                                    <div class="info-icon">
                                        <i class="fas fa-envelope"></i>
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="fw-medium">Email</div>
                                        <div class="text-muted"><%= currentPatient.getEmail() %></div>
                                    </div>
                                </div>
                                <div class="info-item">
                                    <div class="info-icon">
                                        <i class="fas fa-phone"></i>
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="fw-medium">Phone</div>
                                        <div class="text-muted"><%= currentPatient.getPhone() != null ? currentPatient.getPhone() : "Not set" %></div>
                                    </div>
                                </div>
                                <div class="info-item">
                                    <div class="info-icon">
                                        <i class="fas fa-venus-mars"></i>
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="fw-medium">Gender</div>
                                        <div class="text-muted"><%= currentPatient.getGender() != null ? currentPatient.getGender() : "Not set" %></div>
                                    </div>
                                </div>
                                <div class="info-item">
                                    <div class="info-icon">
                                        <i class="fas fa-tint"></i>
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="fw-medium">Blood Group</div>
                                        <div class="text-muted"><%= currentPatient.getBloodGroup() != null ? currentPatient.getBloodGroup() : "Not set" %></div>
                                    </div>
                                </div>
                                <div class="info-item">
                                    <div class="info-icon">
                                        <i class="fas fa-calendar"></i>
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="fw-medium">Member Since</div>
                                        <div class="text-muted"><%= currentPatient.getCreatedAt() != null ? currentPatient.getCreatedAt().toString().split(" ")[0] : "N/A" %></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header">
                            <h2 class="card-title">
                                <i class="fas fa-link"></i>
                                Quick Actions
                            </h2>
                        </div>
                        <div class="card-body">
                            <a href="${pageContext.request.contextPath}/patient/change_password.jsp" class="quick-link">
                                <i class="fas fa-key"></i>
                                <span>Change Password</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/patient/appointment?action=book" class="quick-link">
                                <i class="fas fa-calendar-plus"></i>
                                <span>Book Appointment</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/patient/appointment?action=view" class="quick-link">
                                <i class="fas fa-list"></i>
                                <span>View Appointments</span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <div class="modal fade" id="deleteAccountModal" tabindex="-1" aria-labelledby="deleteAccountModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title" id="deleteAccountModalLabel"><i class="fas fa-exclamation-triangle me-2"></i>Confirm Account Deletion</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p><i class="fas fa-exclamation-triangle text-danger me-1"></i> <b>Warning: This action is irreversible.</b></p>
                    <p>Are you absolutely sure you want to <b>permanently delete</b> your patient account? All associated data, including medical history and past appointments, will be <b>removed</b> from our database.</p>
                    
                    <div class="form-check mt-3">
                        <input class="form-check-input" type="checkbox" value="" id="confirmDeletionCheck">
                        <label class="form-check-label" for="confirmDeletionCheck">
                            <b>I understand that deleting my account cannot be undone.</b>
                        </label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    
                    <button type="button" class="btn btn-danger" id="confirmDeleteButton" disabled>
                        <i class="fas fa-user-slash me-2"></i>Delete Permanently
                    </button>
                    
                    <form id="deleteAccountForm" action="${pageContext.request.contextPath}/patient/profile?action=delete" method="POST" style="display:none;">
                        </form>
                </div>
            </div>
        </div>
    </div>
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

            // --- Form Validation and DOB Logic ---
            const forms = document.querySelectorAll('.needs-validation');
            Array.from(forms).forEach(form => {
                form.addEventListener('submit', function(event) {
                    if (!form.checkValidity()) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });

            // Set max date for date of birth (18 years ago)
            const dobInput = document.getElementById('dateOfBirth');
            if (dobInput) {
                const today = new Date();
                const maxDate = new Date(today.getFullYear() - 18, today.getMonth(), today.getDate());
                const minDate = new Date(today.getFullYear() - 100, today.getMonth(), today.getDate());
                dobInput.max = maxDate.toISOString().split('T')[0];
                dobInput.min = minDate.toISOString().split('T')[0];
            }
            
            // --- ACCOUNT DELETION LOGIC (Controls Modal Confirmation) ---
            const confirmDeletionCheck = document.getElementById('confirmDeletionCheck');
            const confirmDeleteButton = document.getElementById('confirmDeleteButton');
            const deleteAccountForm = document.getElementById('deleteAccountForm');
            const deleteModal = document.getElementById('deleteAccountModal');

            if (confirmDeletionCheck && confirmDeleteButton && deleteAccountForm && deleteModal) {
                
                // 1. Enable/Disable the final delete button based on checkbox state
                confirmDeletionCheck.addEventListener('change', function() {
                    confirmDeleteButton.disabled = !this.checked;
                });

                // 2. Handle the final button click to submit the form
                confirmDeleteButton.addEventListener('click', function() {
                    if (confirmDeletionCheck.checked) {
                        // Prevent multiple clicks and provide feedback
                        confirmDeleteButton.disabled = true; 
                        confirmDeleteButton.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';

                        // Submit the hidden form to the servlet
                        deleteAccountForm.submit();
                    }
                });
                
                // 3. Reset the modal state whenever it is hidden
                deleteModal.addEventListener('hidden.bs.modal', function () {
                    // Reset checkbox
                    confirmDeletionCheck.checked = false;
                    // Reset button state
                    confirmDeleteButton.disabled = true;
                    confirmDeleteButton.innerHTML = '<i class="fas fa-user-slash me-2"></i>Delete Permanently';
                });
            }
        });
    </script>
</body>
</html>