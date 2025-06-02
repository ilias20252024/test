package com.secdevops.wsp2;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * VULNERABLE: Servlet de autenticación con múltiples vulnerabilidades
 * Vulnerabilidades incluidas:
 * - SQL Injection
 * - Weak Authentication
 * - Session Management Issues
 * - Information Disclosure
 * - LDAP Injection (simulado)
 */
public class WhoIAmServlet extends HttpServlet {
    
    // VULNERABLE: Logger que puede exponer credenciales
    private static final Logger logger = LogManager.getLogger(WhoIAmServlet.class);
    
    // VULNERABLE: Credenciales hardcodeadas
    private static final String ADMIN_USER = "admin";
    private static final String ADMIN_PASS = "password123";
    private static final String DB_URL = "jdbc:h2:mem:testdb";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Who I Am - WSP2 SecDevOps</title>");
        out.println("<link rel='stylesheet' type='text/css' href='css/style.css'>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='container'>");
        out.println("<h1>👤 Who I Am - Sistema de Autenticación</h1>");
        out.println("<div class='warning'>⚠️ VULNERABILIDADES: SQL Injection, Weak Auth, Session Issues</div>");
        
        // Verificar si hay sesión activa
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("username") != null) {
            String username = (String) session.getAttribute("username");
            String role = (String) session.getAttribute("role");
            
            out.println("<div class='success'>");
            out.println("<h2>✅ Sesión Activa</h2>");
            out.println("<p><strong>Usuario:</strong> " + username + "</p>");
            out.println("<p><strong>Rol:</strong> " + role + "</p>");
            out.println("<p><strong>Session ID:</strong> " + session.getId() + "</p>");
            
            // VULNERABLE: Exposición de información de sesión
            out.println("<p><strong>Última actividad:</strong> " + new java.util.Date(session.getLastAccessedTime()) + "</p>");
            out.println("<p><strong>Tiempo máximo inactivo:</strong> " + session.getMaxInactiveInterval() + " segundos</p>");
            out.println("</div>");
            
            // Panel de administración para usuarios admin
            if ("admin".equals(role)) {
                out.println("<div class='admin-panel'>");
                out.println("<h3>🔧 Panel de Administración</h3>");
                out.println("<p>Acceso a funciones administrativas:</p>");
                out.println("<ul>");
                out.println("<li><a href='#' onclick='executeCommand()'>Ejecutar comandos del sistema</a></li>");
                out.println("<li><a href='#' onclick='viewLogs()'>Ver logs del sistema</a></li>");
                out.println("<li><a href='#' onclick='accessDatabase()'>Acceso directo a base de datos</a></li>");
                out.println("</ul>");
                out.println("</div>");
            }
            
            out.println("<form method='post' action='whoiam'>");
            out.println("<input type='hidden' name='action' value='logout'>");
            out.println("<button type='submit' class='logout-btn'>🚪 Cerrar Sesión</button>");
            out.println("</form>");
            
        } else {
            // Mostrar formulario de login
            out.println("<form method='post' action='whoiam' class='login-form'>");
            out.println("<h2>🔐 Iniciar Sesión</h2>");
            
            out.println("<div class='form-group'>");
            out.println("<label for='username'>Usuario:</label>");
            out.println("<input type='text' id='username' name='username' required>");
            out.println("</div>");
            
            out.println("<div class='form-group'>");
            out.println("<label for='password'>Contraseña:</label>");
            out.println("<input type='password' id='password' name='password' required>");
            out.println("</div>");
            
            out.println("<div class='form-group'>");
            out.println("<label for='domain'>Dominio (opcional):</label>");
            out.println("<input type='text' id='domain' name='domain' placeholder='LDAP domain'>");
            out.println("</div>");
            
            out.println("<button type='submit' class='login-btn'>🔓 Entrar</button>");
            out.println("</form>");
            
            // VULNERABLE: Información de debug visible
            out.println("<div class='debug-info'>");
            out.println("<h3>🐛 Información de Debug (PELIGROSO)</h3>");
            out.println("<p><strong>Usuarios de prueba:</strong></p>");
            out.println("<ul>");
            out.println("<li>admin / password123 (Administrador)</li>");
            out.println("<li>user / user123 (Usuario normal)</li>");
            out.println("<li>guest / guest (Invitado)</li>");
            out.println("</ul>");
            out.println("<p><strong>Base de datos:</strong> " + DB_URL + "</p>");
            out.println("</div>");
        }
        
        out.println("<div class='navigation'>");
        out.println("<a href='index.jsp'>🏠 Volver al inicio</a>");
        out.println("<a href='headers'>📋 Ver Headers</a>");
        out.println("</div>");
        
        out.println("</div>");
        
        // VULNERABLE: JavaScript con funciones administrativas expuestas
        out.println("<script>");
        out.println("function executeCommand() {");
        out.println("  var cmd = prompt('Ingrese comando a ejecutar:');");
        out.println("  if (cmd) {");
        out.println("    alert('Ejecutando: ' + cmd + '\\n(Esto es una simulación de vulnerabilidad de Command Injection)');");
        out.println("  }");
        out.println("}");
        out.println("function viewLogs() {");
        out.println("  alert('Accediendo a logs del sistema...\\n(Vulnerabilidad: Exposición de logs)');");
        out.println("}");
        out.println("function accessDatabase() {");
        out.println("  alert('Conexión directa a: " + DB_URL + "\\n(Vulnerabilidad: Acceso directo a DB)');");
        out.println("}");
        out.println("</script>");
        
        out.println("</body>");
        out.println("</html>");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("logout".equals(action)) {
            // Cerrar sesión
            HttpSession session = request.getSession(false);
            if (session != null) {
                String username = (String) session.getAttribute("username");
                logger.info("Usuario {} cerró sesión", username);
                session.invalidate();
            }
            response.sendRedirect("whoiam");
            return;
        }
        
        // Proceso de login
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String domain = request.getParameter("domain");
        
        // VULNERABLE: Log de credenciales en texto plano
        logger.warn("Intento de login - Usuario: {}, Password: {}, Domain: {}", username, password, domain);
        
        if (authenticateUser(username, password, domain)) {
            // VULNERABLE: Crear sesión sin validaciones de seguridad
            HttpSession session = request.getSession(true);
            session.setAttribute("username", username);
            
            // VULNERABLE: Asignación de roles basada en nombre de usuario
            if ("admin".equals(username)) {
                session.setAttribute("role", "admin");
            } else {
                session.setAttribute("role", "user");
            }
            
            // VULNERABLE: Session sin timeout apropiado
            session.setMaxInactiveInterval(3600); // 1 hora
            
            logger.info("Login exitoso para usuario: {}", username);
            response.sendRedirect("whoiam");
        } else {
            // VULNERABLE: Información específica sobre fallas de autenticación
            logger.error("Login fallido para usuario: {} con password: {}", username, password);
            response.sendRedirect("whoiam?error=invalid_credentials");
        }
    }
    
    // VULNERABLE: Método de autenticación con múltiples problemas
    private boolean authenticateUser(String username, String password, String domain) {
        if (username == null || password == null) {
            return false;
        }
        
        // VULNERABLE: SQL Injection
        if (domain != null && !domain.isEmpty()) {
            String ldapQuery = "(&(objectClass=user)(sAMAccountName=" + username + ")(domain=" + domain + "))";
            logger.info("LDAP Query: {}", ldapQuery);
            // Simulación de LDAP Injection vulnerability
        }
        
        // VULNERABLE: Credenciales hardcodeadas y comparación insegura
        if (ADMIN_USER.equals(username) && ADMIN_PASS.equals(password)) {
            return true;
        }
        
        // VULNERABLE: Otros usuarios de prueba
        if ("user".equals(username) && "user123".equals(password)) {
            return true;
        }
        
        if ("guest".equals(username) && "guest".equals(password)) {
            return true;
        }
        
        // VULNERABLE: SQL directo sin prepared statements
        try {
            String sql = "SELECT * FROM users WHERE username = '" + username + "' AND password = '" + password + "'";
            logger.info("SQL Query: {}", sql);
            // Simulación de SQL Injection vulnerability
            
        } catch (Exception e) {
            logger.error("Error en autenticación SQL", e);
        }
        
        return false;
    }
} 