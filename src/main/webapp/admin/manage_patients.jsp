<%@ page import="com.entity.Admin" %>
<%@ page import="com.dao.PatientDao" %>
<%@ page import="com.entity.Patient" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Admin currentAdmin = (Admin) session.getAttribute("adminObj");
    if (currentAdmin == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }

    PatientDao patientDao = new PatientDao();
    List<Patient> patients = patientDao.getAllPatients();

    String currentUserRole = "admin";
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Care System - Manage Patients</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary: #4361ee;
            --primary-light: #eef2ff;
            --primary-dark: #3a56d4;
            --secondary: #6c757d;
            --success: #198754;
            --info: #0dcaf0;
            --warning: #ffc107;
            --danger: #dc3545;
            --danger-light: #fbebee;
            --light: #f8f9fa;
            --lighter: #fdfdfe;
            --dark: #1a1d29;
            --darker: #12141c;
            --gray-100: #f8f9fa;
            --gray-200: #e9ecef;
            --gray-300: #dee2e6;
            --gray-400: #ced4da;
            --gray-500: #adb5bd;
            --gray-600: #6c757d;
            --gray-700: #495057;
            --gray-800: #343a40;
            --gray-900: #212529;
            --sidebar-width: 280px;
            --transition: all 0.3s ease;
            --border-radius: 12px;
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.05);
            --shadow-md: 0 4px 12px rgba(0,0,0,0.08);
            --shadow-lg: 0 10px 30px rgba(0,0,0,0.12);
            --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--gray-100);
            color: var(--gray-800);
            line-height: 1.6;
            display: flex;
            min-height: 100vh;
            overflow-x: hidden;
        }
        
        /* Sidebar Styles */
        .sidebar {
            width: var(--sidebar-width);
            flex-shrink: 0;
            background: linear-gradient(135deg, #ffffff, #f8fafc);
            color: var(--gray-700);
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            overflow-y: auto;
            transition: var(--transition);
            box-shadow: var(--shadow-md);
            display: flex;
            flex-direction: column;
            border-right: 1px solid var(--gray-200);
            z-index: 1000;
        }
        
        .sidebar-sticky {
            display: flex;
            flex-direction: column;
            min-height: 100%;
            padding: 1.5rem 0;
        }
        
        .user-section {
            text-align: center;
            padding: 1.5rem 1.5rem 2rem;
            border-bottom: 1px solid var(--gray-200);
            margin-bottom: 1rem;
        }
        
        .user-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), #5a6ff0);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            border: 3px solid var(--primary-light);
            box-shadow: var(--shadow-sm);
        }
        
        .user-avatar i {
            font-size: 2.5rem;
            color: white;
        }
        
        .user-info h6 {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 0.25rem;
            color: var(--gray-800);
        }
        
        .user-info .badge {
            background: var(--primary-light);
            color: var(--primary);
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 500;
            border: 1px solid rgba(67, 97, 238, 0.2);
        }
        
        .nav {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            padding: 0 1rem;
            list-style: none;
        }
        
        .nav-main {
            flex-grow: 1;
        }
        
        .nav-bottom {
            margin-top: auto;
            padding-top: 1rem;
            border-top: 1px solid var(--gray-200);
            margin: 1.5rem 0 0 0;
        }

        .nav-item {
            margin-bottom: 0.25rem;
        }
        
        .nav-link {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 0.875rem 1.25rem;
            color: var(--gray-600);
            text-decoration: none;
            border-radius: var(--border-radius);
            transition: var(--transition);
            font-weight: 500;
            position: relative;
            overflow: hidden;
        }
        
        .nav-link::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 4px;
            background: var(--primary);
            transform: scaleY(0);
            transition: var(--transition);
            border-radius: 0 4px 4px 0;
        }
        
        .nav-link:hover {
            color: var(--primary);
            background: var(--primary-light);
            transform: translateX(5px);
        }
        
        .nav-link:hover::before {
            transform: scaleY(1);
        }
        
        .nav-link.active {
            color: var(--primary);
            background: var(--primary-light);
        }
        
        .nav-link.active::before {
            transform: scaleY(1);
        }
        
        .nav-link i {
            width: 20px;
            text-align: center;
            font-size: 1.1rem;
            transition: var(--transition);
        }
        
        .nav-link.active i {
            color: var(--primary);
        }
        
        .nav-link:hover i {
            transform: scale(1.1);
        }
        
        .nav-link-logout {
            color: var(--danger);
        }
        
        .nav-link-logout:hover {
            background: var(--danger-light);
            color: var(--danger);
            transform: translateX(5px);
        }
        
        .nav-link-logout:hover i {
            color: var(--danger);
        }
        
        .nav-link-logout i {
            color: var(--danger);
        }
        
        .main-content {
            flex-grow: 1;
            margin-left: var(--sidebar-width);
            padding: 0;
            min-height: 100vh;
            overflow-y: auto;
            background: var(--gray-100);
            transition: var(--transition);
        }

        .mobile-menu-toggle {
            display: none;
            position: fixed;
            top: 1.5rem;
            left: 1.5rem;
            z-index: 999;
            background: var(--primary);
            color: white;
            border: none;
            width: 45px;
            height: 45px;
            border-radius: 10px;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            cursor: pointer;
            box-shadow: var(--shadow-lg);
        }
        
        /* Mobile responsiveness */
        @media (max-width: 768px) {
            body {
                display: block;
                height: auto;
                overflow: visible;
            }
            .sidebar {
                transform: translateX(-100%);
            }
            
            .sidebar.mobile-open {
                transform: translateX(0);
            }
            
            .main-content {
                margin-left: 0;
                padding: 1.5rem;
                padding-top: 6rem;
            }
            
            .mobile-menu-toggle {
                display: flex;
            }
        }
        
        /* Scrollbar styling */
        .sidebar::-webkit-scrollbar,
        .main-content::-webkit-scrollbar {
            width: 6px;
        }
        
        .sidebar::-webkit-scrollbar-track,
        .main-content::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.05);
        }
        
        .sidebar::-webkit-scrollbar-thumb,
        .main-content::-webkit-scrollbar-thumb {
            background: var(--gray-400);
            border-radius: 3px;
        }
        
        .sidebar::-webkit-scrollbar-thumb:hover,
        .main-content::-webkit-scrollbar-thumb:hover {
            background: var(--gray-500);
        }
        
        /* Dashboard Specific Styles */
        .main-content-dashboard {
            padding: 2.5rem;
        }
        
        @media (max-width: 768px) {
            .main-content-dashboard {
                padding: 1.5rem;
                padding-top: 6rem;
            }
        }
        
        .profile-header {
            background: linear-gradient(135deg, var(--primary), #5a6ff0);
            color: white;
            padding: 2.5rem 2.5rem;
            margin-bottom: 2rem;
            box-shadow: var(--shadow-md);
        }
        
        .card-modern {
            border: none;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-md);
            transition: var(--transition);
            overflow: hidden;
            background: white;
        }
        
        .card-modern:hover {
            box-shadow: var(--shadow-lg);
            transform: translateY(-3px);
        }
        
        .card-header-modern {
            background: white;
            border-bottom: 1px solid var(--gray-200);
            padding: 1.5rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            color: var(--gray-800);
        }
        
        .card-header-modern i {
            color: var(--primary);
            margin-right: 10px;
            font-size: 1.1rem;
        }
        
        .form-label {
            font-weight: 500;
            margin-bottom: 0.5rem;
            color: var(--gray-700);
        }
        
        .input-group {
            position: relative;
            display: flex;
            align-items: stretch;
            width: 100%;
            border-radius: 10px;
            overflow: hidden;
            border: 1px solid var(--gray-300);
            transition: var(--transition);
            background: white;
        }
        
        .input-group:focus-within {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.15);
        }
        
        .input-group-text {
            background: var(--gray-100);
            border: none;
            color: var(--gray-600);
            padding: 0.75rem 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            min-width: 50px;
            flex-shrink: 0;
            border-right: 1px solid var(--gray-300);
        }
        
        .form-control, .form-select {
            border: none;
            padding: 0.75rem 1rem;
            transition: var(--transition);
            font-size: 0.95rem;
            width: 100%;
            flex: 1;
            background: transparent;
        }
        
        .form-control:focus, .form-select:focus {
            box-shadow: none;
            outline: none;
            background: transparent;
        }
        
        .input-group-text.align-items-start {
            align-items: flex-start;
            padding-top: 0.875rem;
        }
        
        .btn-modern {
            border-radius: 10px;
            padding: 0.75rem 1.5rem;
            font-weight: 500;
            transition: var(--transition);
            font-size: 0.95rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            border: none;
            cursor: pointer;
        }
        
        .btn-primary-modern {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: white;
        }
        
        .btn-primary-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 7px 14px rgba(67, 97, 238, 0.25);
        }
        
        .btn-outline-primary {
            border: 2px solid var(--primary);
            color: var(--primary);
            background: transparent;
            font-weight: 500;
        }
        
        .btn-outline-primary:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(67, 97, 238, 0.2);
        }
        
        .btn-outline-warning {
            border: 2px solid var(--warning);
            color: var(--warning);
            background: transparent;
            font-weight: 500;
        }
        
        .btn-outline-warning:hover {
            background: var(--warning);
            color: var(--gray-800);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 193, 7, 0.2);
        }
        
        .btn-outline-danger {
            border: 2px solid var(--danger);
            color: var(--danger);
            background: transparent;
            font-weight: 500;
        }
        
        .btn-outline-danger:hover {
            background: var(--danger);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.2);
        }
        
        .btn-outline-secondary {
            border: 2px solid var(--gray-400);
            color: var(--gray-600);
            background: transparent;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .btn-outline-secondary:hover {
            background: var(--gray-600);
            color: white;
            border-color: var(--gray-600);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108, 117, 125, 0.2);
        }
        
        /* Badge styling */
        .badge {
            display: inline-block;
            padding: 0.4em 0.75em;
            font-size: 0.8rem;
            font-weight: 600;
            line-height: 1;
            text-align: center;
            white-space: nowrap;
            vertical-align: baseline;
            border-radius: 50px;
        }
        
        .badge-primary { background: var(--primary); color: white; }
        .badge-success { background: var(--success); color: white; }
        .badge-warning { background: var(--warning); color: var(--gray-800); }
        .badge-danger { background: var(--danger); color: white; }
        .badge-secondary { background: var(--secondary); color: white; }
        .badge-light { background: var(--gray-200); color: var(--gray-800); }
        
        /* Table Styles */
        .table-responsive {
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }
        
        .table {
            width: 100%;
            margin-bottom: 1rem;
            color: #212529;
            vertical-align: middle;
            border-collapse: collapse;
        }
        
        .table>:not(caption)>*>* {
            padding: 0.8rem 0.8rem;
            background-color: transparent;
            border-bottom-width: 1px;
            box-shadow: inset 0 0 0 9999px transparent;
            border-color: var(--gray-300);
        }
        
        .table>thead th {
            font-weight: 600;
            color: var(--gray-600);
            text-transform: uppercase;
            font-size: 0.8rem;
            letter-spacing: 0.05em;
            border-bottom-width: 2px;
            border-color: var(--gray-300);
        }
        
        .table-hover>tbody>tr:hover>* {
            background-color: var(--gray-100);
            color: var(--gray-900);
        }
        
        /* Stats Cards */
        .stats-card {
            border-radius: var(--border-radius);
            padding: 1.5rem;
            color: white;
            text-align: center;
            transition: var(--transition);
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .stats-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-lg);
        }
        
        .stats-card h4 {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.25rem;
        }
        
        .stats-card small {
            font-size: 0.9rem;
            font-weight: 500;
            opacity: 0.9;
        }
        
        .stats-card-primary { background: linear-gradient(135deg, var(--primary), #5a6ff0); }
        .stats-card-warning { background: linear-gradient(135deg, var(--warning), #ffd54f); color: var(--gray-800); }
        .stats-card-success { background: linear-gradient(135deg, var(--success), #20c997); }
        .stats-card-info { background: linear-gradient(135deg, var(--info), #0dcaf0); color: var(--gray-800); }
        .stats-card-secondary { background: linear-gradient(135deg, var(--secondary), #6c757d); }
        .stats-card-danger { background: linear-gradient(135deg, var(--danger), #e63946); }
        
        /* Back link styling */
        .back-link {
            color: rgba(255, 255, 255, 0.9);
            text-decoration: none;
            font-weight: 500;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .back-link:hover {
            color: white;
            background: rgba(255, 255, 255, 0.25);
            transform: translateY(-1px);
            text-decoration: none;
        }
        
        /* Icon Box */
        .icon-box {
            width: 45px;
            height: 45px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            flex-shrink: 0;
        }
        
        .icon-primary { background-color: var(--primary-light); color: var(--primary); }
        .icon-success { background-color: #d1fae5; color: #065f46; }
        
        /* Alert Styles */
        .alert-modern {
            border-radius: 10px;
            border: none;
            box-shadow: var(--shadow-sm);
            padding: 1rem 1.5rem;
        }
        
        /* Modal Styles */
        .modal-content {
            border-radius: var(--border-radius);
            border: none;
            box-shadow: var(--shadow-lg);
        }
        
        .modal-header {
            padding: 1.5rem;
            border-bottom: 1px solid var(--gray-200);
        }
        
        .modal-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--gray-800);
        }
        
        .modal-body {
            padding: 1.5rem;
        }
        
        .modal-footer {
            padding: 1.5rem;
            border-top: 1px solid var(--gray-200);
            gap: 0.75rem;
        }
        
        /* Delete Modal */
        .delete-modal-icon {
            width: 70px; 
            height: 70px;
            background-color: var(--danger-light);
            color: var(--danger);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
        }

        #deleteConfirmModal .modal-content {
            border-radius: var(--border-radius);
            border: none;
            box-shadow: var(--shadow-xl);
            max-width: 400px;
            margin: auto;
            overflow: hidden;
        }
        
        #deleteConfirmModal .modal-header {
            border-bottom: none;
            padding: 1.5rem 1.5rem 0.5rem;
        }
        
        #deleteConfirmModal .modal-header .btn-close {
            position: absolute; 
            top: 1rem;
            right: 1rem;
        }

        #deleteConfirmModal .modal-body {
            padding: 0.5rem 2rem 1.5rem;
            text-align: center;
        }
        
        #deleteConfirmModal .modal-body h4 {
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 0.75rem;
        }

        #deleteConfirmModal .modal-footer {
            border-top: none;
            padding: 0 2rem 2rem;
            justify-content: center;
            gap: 1rem;
        }
        
        #deleteConfirmModal .modal-footer .btn {
            flex-grow: 1;
            padding: 0.6rem 1rem;
            font-weight: 500;
        }
        
        /* Patient Details Layout */
        .patient-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1rem;
        }
        
        .detail-section {
            background: var(--gray-100);
            border-radius: var(--border-radius);
            padding: 1.25rem;
        }
        
        .detail-section h5 {
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 0.75rem;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid var(--gray-200);
        }
        
        .detail-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.5rem 0;
            min-height: 2.5rem;
        }
        
        .detail-item:not(:last-child) {
            border-bottom: 1px solid var(--gray-200);
        }
        
        .detail-label {
            font-weight: 500;
            color: var(--gray-700);
            font-size: 0.9rem;
            flex-shrink: 0;
        }
        
        .detail-value {
            color: var(--gray-800);
            text-align: right;
            font-size: 0.9rem;
            flex: 1;
            margin-left: 1rem;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            min-height: 1.5rem;
        }
        
        /* Edit Form Styles */
        .form-section {
            margin-bottom: 2rem;
        }
        
        .section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--gray-800);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid var(--gray-200);
        }
        
        .form-row-spaced > [class*="col-"] {
            margin-bottom: 1.25rem;
        }
        
        /* Action buttons container */
        .action-buttons {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        
        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
        }
        
        .empty-state i {
            font-size: 4rem;
            color: var(--gray-400);
            margin-bottom: 1rem;
        }

        /* Search box */
        .search-box {
            max-width: 300px;
        }
        
        /* Status indicator */
        .status-indicator {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
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
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard.jsp">
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
                        <a class="nav-link active" href="${pageContext.request.contextPath}/admin/management?action=view&type=patients">
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
    
    <main class="main-content">
        <div class="profile-header">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="h2 mb-2">
                        <i class="fas fa-users me-2"></i>
                        Manage Patients
                    </h1>
                    <p class="mb-0 opacity-75">View and manage all patient records</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="back-link">
                        <i class="fas fa-arrow-left me-2"></i>Back to Dashboard
                    </a>
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
                
                if (successMsg != null && !successMsg.isEmpty()) {
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
                if (errorMsg != null && !errorMsg.isEmpty()) {
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
                        <h4 class="mb-1"><%= patients.size() %></h4>
                        <small>Total Patients</small>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-card-success">
                        <h4 class="mb-1"><%= patients.stream().filter(p -> p.getGender() != null && p.getGender().equals("Male")).count() %></h4>
                        <small>Male Patients</small>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-card-info">
                        <h4 class="mb-1"><%= patients.stream().filter(p -> p.getGender() != null && p.getGender().equals("Female")).count() %></h4>
                        <small>Female Patients</small>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="stats-card stats-card-warning">
                        <h4 class="mb-1"><%= patients.stream().filter(p -> p.getBloodGroup() != null && !p.getBloodGroup().isEmpty()).count() %></h4>
                        <small>With Blood Group</small>
                    </div>
                </div>
            </div>

            <%-- Patients Table --%>
            <div class="card card-modern">
                <div class="card-header-modern d-flex justify-content-between align-items-center flex-wrap">
                    <div>
                        <i class="fas fa-list"></i>
                        <span>All Patients</span>
                        <span class="badge badge-primary ms-2"><%= patients.size() %> Total</span>
                    </div>
                    <div class="mt-2 mt-md-0">
                        <div class="input-group search-box">
                            <span class="input-group-text">
                                <i class="fas fa-search"></i>
                            </span>
                            <input type="text" class="form-control" id="patientSearchInput" placeholder="Search patients...">
                        </div>
                    </div>
                </div>
                <div class="card-body p-4">
                    <%
                        if (patients.isEmpty()) {
                    %>
                        <div class="empty-state">
                            <i class="fas fa-users"></i>
                            <h4 class="text-muted">No Patients Found</h4>
                            <p class="text-muted">No patients have registered yet.</p>
                        </div>
                    <%
                        } else {
                    %>
                        <div class="table-responsive">
                            <table class="table table-hover" id="patientsTable">
                                <thead>
                                    <tr>
                                        <th>Patient Info</th>
                                        <th>Contact</th>
                                        <th>Gender</th>
                                        <th>Blood Group</th>
                                        <th>Date of Birth</th>
                                        <th>Registered</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        for (Patient patient : patients) {
                                    %>
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="icon-box icon-primary me-3 d-none d-md-flex">
                                                        <i class="fas fa-user"></i>
                                                    </div>
                                                    <div>
                                                        <strong><%= patient.getFullName() %></strong><br>
                                                        <small class="text-muted">
                                                            <i class="fas fa-envelope me-1"></i><%= patient.getEmail() %>
                                                        </small><br>
                                                        <small class="text-muted">ID: PAT<%= patient.getId() %></small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <small class="text-muted d-block">
                                                    <i class="fas fa-phone me-1"></i><%= patient.getPhone() != null ? patient.getPhone() : "N/A" %>
                                                </small>
                                                <small class="text-muted d-block mt-1">
                                                    <i class="fas fa-home me-1"></i>
                                                    <%
                                                        if (patient.getAddress() != null && patient.getAddress().length() > 30) {
                                                            out.print(patient.getAddress().substring(0, 30) + "...");
                                                        } else if (patient.getAddress() != null) {
                                                            out.print(patient.getAddress());
                                                        } else {
                                                            out.print("N/A");
                                                        }
                                                    %>
                                                </small>
                                            </td>
                                            <td>
                                                <span class="badge badge-light">
                                                    <i class="fas fa-venus-mars me-1"></i>
                                                    <%= patient.getGender() != null ? patient.getGender() : "N/A" %>
                                                </span>
                                            </td>
                                            <td>
                                                <%
                                                    if (patient.getBloodGroup() != null && !patient.getBloodGroup().isEmpty()) {
                                                %>
                                                    <span class="badge badge-danger">
                                                        <i class="fas fa-tint me-1"></i>
                                                        <%= patient.getBloodGroup() %>
                                                    </span>
                                                <%
                                                    } else {
                                                %>
                                                    <span class="badge badge-secondary">N/A</span>
                                                <%
                                                    }
                                                %>
                                            </td>
                                            <td>
                                                <small><%= patient.getDateOfBirth() != null ? patient.getDateOfBirth().toString() : "N/A" %></small>
                                            </td>
                                            <td>
                                                <small class="text-muted"><%= patient.getCreatedAt() != null ? sdf.format(patient.getCreatedAt()) : "N/A" %></small>
                                            </td>
                                            <td>
                                                <div class="action-buttons">
                                                    <button type="button" class="btn btn-sm btn-outline-primary"
                                                            data-bs-toggle="modal" 
                                                            data-bs-target="#viewPatientModal<%= patient.getId() %>"
                                                            title="View Details">
                                                        <i class="fas fa-eye"></i>
                                                    </button>
                                                    
                                                    <button type="button" class="btn btn-sm btn-outline-warning"
                                                            data-bs-toggle="modal" 
                                                            data-bs-target="#editPatientModal<%= patient.getId() %>"
                                                            title="Edit Patient">
                                                        <i class="fas fa-edit"></i>
                                                    </button>

                                                    <button type="button" class="btn btn-sm btn-outline-danger delete-btn"
                                                            data-bs-toggle="modal" 
                                                            data-bs-target="#deleteConfirmModal"
                                                            data-patient-id="<%= patient.getId() %>"
                                                            data-patient-name="<%= patient.getFullName() %>"
                                                            title="Delete Patient">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </main>

    <%-- Modals --%>
    <%
        for (Patient patient : patients) {
    %>
        <%-- View Modal --%>
        <div class="modal fade" id="viewPatientModal<%= patient.getId() %>" tabindex="-1" aria-labelledby="viewPatientModalLabel<%= patient.getId() %>" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h3 class="modal-title">
                            <i class="fas fa-user text-primary me-2"></i>
                            Patient Details
                        </h3>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="patient-details">
                            <div class="detail-section">
                                <h5><i class="fas fa-info-circle"></i> Basic Information</h5>
                                <div class="detail-item">
                                    <span class="detail-label">Patient ID:</span>
                                    <span class="detail-value">PAT<%= patient.getId() %></span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Full Name:</span>
                                    <span class="detail-value"><%= patient.getFullName() %></span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Email:</span>
                                    <span class="detail-value"><%= patient.getEmail() %></span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Phone:</span>
                                    <span class="detail-value"><%= patient.getPhone() != null ? patient.getPhone() : "N/A" %></span>
                                </div>
                            </div>
                            
                            <div class="detail-section">
                                <h5><i class="fas fa-user-circle"></i> Personal Information</h5>
                                <div class="detail-item">
                                    <span class="detail-label">Gender:</span>
                                    <span class="detail-value"><%= patient.getGender() != null ? patient.getGender() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Date of Birth:</span>
                                    <span class="detail-value"><%= patient.getDateOfBirth() != null ? patient.getDateOfBirth().toString() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Blood Group:</span>
                                    <span class="detail-value"><%= patient.getBloodGroup() != null ? patient.getBloodGroup() : "N/A" %></span>
                                </div>
                            </div>
                            
                            <div class="detail-section">
                                <h5><i class="fas fa-address-card"></i> Contact Information</h5>
                                <div class="detail-item">
                                    <span class="detail-label">Address:</span>
                                    <span class="detail-value"><%= patient.getAddress() != null ? patient.getAddress() : "N/A" %></span>
                                </div>
                                <div class="detail-item">
                                    <span class="detail-label">Emergency Contact:</span>
                                    <span class="detail-value"><%= patient.getEmergencyContact() != null ? patient.getEmergencyContact() : "N/A" %></span>
                                </div>
                            </div>
                            
                            <div class="detail-section">
                                <h5><i class="fas fa-file-medical"></i> Medical Information</h5>
                                <div class="detail-item">
                                    <span class="detail-label">Medical History:</span>
                                    <span class="detail-value"><%= patient.getMedicalHistory() != null && !patient.getMedicalHistory().isEmpty() ? patient.getMedicalHistory() : "N/A" %></span>
                                </div>
                            </div>
                            
                            <div class="detail-section">
                                <h5><i class="fas fa-calendar-plus"></i> Registration</h5>
                                <div class="detail-item">
                                    <span class="detail-label">Registered On:</span>
                                    <span class="detail-value"><%= patient.getCreatedAt() != null ? sdf.format(patient.getCreatedAt()) : "N/A" %></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <%-- Edit Modal --%>
        <div class="modal fade" id="editPatientModal<%= patient.getId() %>" tabindex="-1" aria-labelledby="editPatientModalLabel<%= patient.getId() %>" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h3 class="modal-title">
                            <i class="fas fa-edit text-primary me-2"></i>
                            Edit Patient
                        </h3>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/management?action=update&type=patient" method="post" id="editForm<%= patient.getId() %>">
                        <input type="hidden" name="patientId" value="<%= patient.getId() %>">
                        <div class="modal-body">
                            <div class="form-section">
                                <h4 class="section-title">Personal Information</h4>
                                <div class="row form-row-spaced">
                                    <div class="col-md-6">
                                        <label for="editFullName<%= patient.getId() %>" class="form-label">Full Name</label>
                                        <div class="input-group">
                                            <span class="input-group-text">
                                                <i class="fas fa-user"></i>
                                            </span>
                                            <input type="text" class="form-control" id="editFullName<%= patient.getId() %>" name="fullName"
                                                   value="<%= patient.getFullName() %>" required>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Email</label>
                                        <div class="input-group">
                                            <span class="input-group-text">
                                                <i class="fas fa-envelope"></i>
                                            </span>
                                            <input type="email" class="form-control" value="<%= patient.getEmail() %>" readonly disabled>
                                        </div>
                                        <small class="text-muted">Email cannot be changed by admin.</small>
                                    </div>
                                </div>
                                
                                <div class="row form-row-spaced">
                                    <div class="col-md-6">
                                        <label for="editPhone<%= patient.getId() %>" class="form-label">Phone</label>
                                        <div class="input-group">
                                            <span class="input-group-text">
                                                <i class="fas fa-phone"></i>
                                            </span>
                                            <input type="tel" class="form-control" id="editPhone<%= patient.getId() %>" name="phone"
                                                   value="<%= patient.getPhone() != null ? patient.getPhone() : "" %>" required>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="editGender<%= patient.getId() %>" class="form-label">Gender</label>
                                        <div class="input-group">
                                            <span class="input-group-text">
                                                <i class="fas fa-venus-mars"></i>
                                            </span>
                                            <select class="form-select" id="editGender<%= patient.getId() %>" name="gender" required>
                                                <option value="">Select Gender</option>
                                                <option value="Male" <%= "Male".equals(patient.getGender()) ? "selected" : "" %>>Male</option>
                                                <option value="Female" <%= "Female".equals(patient.getGender()) ? "selected" : "" %>>Female</option>
                                                <option value="Other" <%= "Other".equals(patient.getGender()) ? "selected" : "" %>>Other</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="row form-row-spaced">
                                    <div class="col-md-6">
                                        <label for="editBloodGroup<%= patient.getId() %>" class="form-label">Blood Group</label>
                                        <div class="input-group">
                                            <span class="input-group-text">
                                                <i class="fas fa-tint"></i>
                                            </span>
                                            <select class="form-select" id="editBloodGroup<%= patient.getId() %>" name="bloodGroup" required>
                                                <option value="">Select</option>
                                                <option value="A+" <%= "A+".equals(patient.getBloodGroup()) ? "selected" : "" %>>A+</option>
                                                <option value="A-" <%= "A-".equals(patient.getBloodGroup()) ? "selected" : "" %>>A-</option>
                                                <option value="B+" <%= "B+".equals(patient.getBloodGroup()) ? "selected" : "" %>>B+</option>
                                                <option value="B-" <%= "B-".equals(patient.getBloodGroup()) ? "selected" : "" %>>B-</option>
                                                <option value="AB+" <%= "AB+".equals(patient.getBloodGroup()) ? "selected" : "" %>>AB+</option>
                                                <option value="AB-" <%= "AB-".equals(patient.getBloodGroup()) ? "selected" : "" %>>AB-</option>
                                                <option value="O+" <%= "O+".equals(patient.getBloodGroup()) ? "selected" : "" %>>O+</option>
                                                <option value="O-" <%= "O-".equals(patient.getBloodGroup()) ? "selected" : "" %>>O-</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="editDateOfBirth<%= patient.getId() %>" class="form-label">Date of Birth</label>
                                        <div class="input-group">
                                            <span class="input-group-text">
                                                <i class="fas fa-calendar"></i>
                                            </span>
                                            <input type="date" class="form-control" id="editDateOfBirth<%= patient.getId() %>" name="dateOfBirth"
                                                   value="<%= patient.getDateOfBirth() != null ? patient.getDateOfBirth().toString() : "" %>" required>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="form-section">
                                <h4 class="section-title">Contact Information</h4>
                                <div class="mb-3">
                                    <label for="editAddress<%= patient.getId() %>" class="form-label">Address</label>
                                    <div class="input-group">
                                        <span class="input-group-text align-items-start">
                                            <i class="fas fa-home"></i>
                                        </span>
                                        <textarea class="form-control" id="editAddress<%= patient.getId() %>" name="address" rows="2" required><%= patient.getAddress() != null ? patient.getAddress() : "" %></textarea>
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="editEmergencyContact<%= patient.getId() %>" class="form-label">Emergency Contact</label>
                                    <div class="input-group">
                                        <span class="input-group-text">
                                            <i class="fas fa-phone-alt"></i>
                                        </span>
                                        <input type="tel" class="form-control" id="editEmergencyContact<%= patient.getId() %>" name="emergencyContact"
                                               value="<%= patient.getEmergencyContact() != null ? patient.getEmergencyContact() : "" %>" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="form-section">
                                <h4 class="section-title">Medical Information</h4>
                                <div class="mb-3">
                                    <label for="editMedicalHistory<%= patient.getId() %>" class="form-label">Medical History (Optional)</label>
                                    <div class="input-group">
                                        <span class="input-group-text align-items-start">
                                            <i class="fas fa-file-medical"></i>
                                        </span>
                                        <textarea class="form-control" id="editMedicalHistory<%= patient.getId() %>" name="medicalHistory" rows="3"><%= patient.getMedicalHistory() != null ? patient.getMedicalHistory() : "" %></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save me-1"></i>Update Patient
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    <%
        }
    %>

    <%-- Delete Confirmation Modal --%>
    <div class="modal fade" id="deleteConfirmModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-bottom-0">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center">
                    <div class="delete-modal-icon">
                        <i class="fas fa-exclamation-triangle fa-2x"></i>
                    </div>
                    <h4 class="mb-3">Are you sure?</h4>
                    <p class="mb-3">You are about to delete patient <strong id="deletePatientName" class="text-danger"></strong>.</p>
                    <p class="text-muted small">This action cannot be undone and will also delete all associated appointments.</p>
                </div>
                <div class="modal-footer border-top-0 justify-content-center">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <form id="deleteForm" method="post" action="${pageContext.request.contextPath}/admin/management" style="display: inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="type" value="patient">
                        <input type="hidden" name="id" id="deletePatientId">
                        <button type="submit" class="btn btn-danger">
                            <i class="fas fa-trash me-1"></i>Delete Patient
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Mobile menu toggle
            const mobileMenuToggle = document.getElementById('mobileMenuToggle');
            const sidebar = document.getElementById('sidebar');
            
            if (mobileMenuToggle && sidebar) {
                mobileMenuToggle.addEventListener('click', function() {
                    sidebar.classList.toggle('mobile-open');
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

            // Delete confirmation modal
            const deleteModal = document.getElementById('deleteConfirmModal');
            const deleteButtons = document.querySelectorAll('.delete-btn');
            
            if (deleteModal) {
                deleteButtons.forEach(button => {
                    button.addEventListener('click', function() {
                        const patientId = this.getAttribute('data-patient-id');
                        const patientName = this.getAttribute('data-patient-name');
                        
                        document.getElementById('deletePatientId').value = patientId;
                        document.getElementById('deletePatientName').textContent = patientName;
                    });
                });
            }

            // Search functionality
            const searchInput = document.getElementById('patientSearchInput');
            const tableRows = document.querySelectorAll('#patientsTable tbody tr');

            if (searchInput) {
                searchInput.addEventListener('input', function() {
                    const searchTerm = this.value.toLowerCase().trim();

                    tableRows.forEach(row => {
                        const patientInfoCell = row.cells[0];
                        const text = patientInfoCell ? patientInfoCell.textContent.toLowerCase() : '';

                        if (text.includes(searchTerm)) {
                            row.style.display = '';
                        } else {
                            row.style.display = 'none';
                        }
                    });
                });
            }

            // Form validation
            const forms = document.querySelectorAll('form');
            forms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    const requiredFields = form.querySelectorAll('[required]');
                    let valid = true;
                    
                    requiredFields.forEach(field => {
                        if (!field.value.trim()) {
                            valid = false;
                            field.classList.add('is-invalid');
                        } else {
                            field.classList.remove('is-invalid');
                        }
                    });
                    
                    if (!valid) {
                        e.preventDefault();
                        const alertDiv = document.createElement('div');
                        alertDiv.className = 'alert alert-danger alert-modern mt-3';
                        alertDiv.innerHTML = '<i class="fas fa-exclamation-circle me-2"></i>Please fill in all required fields.';
                        form.insertBefore(alertDiv, form.firstChild);
                    }
                });
            });

            // Initialize tooltips
            const tooltipTriggerList = [].slice.call(document.querySelectorAll('[title]'));
            const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        });
    </script>
</body>
</html>