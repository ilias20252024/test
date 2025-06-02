<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.lang.System" %>

<%
    // VULNERABLE: Exposición de información sensible en JSP
    String serverInfo = application.getServerInfo();
    String contextPath = request.getContextPath();
    String remoteAddr = request.getRemoteAddr();
    String userAgent = request.getHeader("User-Agent");
    
    // VULNERABLE: Procesamiento de parámetros sin validación
    String message = request.getParameter("message");
    String search = request.getParameter("search");
    String debug = request.getParameter("debug");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WSP2 - SecDevOps Vulnerable Demo</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    
    <!-- VULNERABLE: Información sensible en meta tags -->
    <meta name="description" content="Aplicación vulnerable para testing de seguridad">
    <meta name="keywords" content="vulnerable,security,testing,secdevops,sql injection,xss">
    <meta name="author" content="SecDevOps Team">
    <meta name="version" content="1.0-VULNERABLE">
</head>
<body>
    <div class="container">
        <header class="main-header">
            <h1>🛡️ WSP2 - SecDevOps Vulnerable Demo</h1>
            <p class="subtitle">Aplicación diseñada para demostrar vulnerabilidades de seguridad</p>
            
            <!-- VULNERABLE: Banner de advertencia que expone información -->
            <div class="warning-banner">
                ⚠️ <strong>APLICACIÓN VULNERABLE</strong> - Solo para propósitos educativos<br>
                <small>Servidor: <%= serverInfo %> | IP: <%= remoteAddr %> | Contexto: <%= contextPath %></small>
            </div>
        </header>

        <main>
            <!-- VULNERABLE: XSS Reflected sin sanitización -->
            <% if (message != null && !message.isEmpty()) { %>
                <div class="alert alert-info">
                    <h3>💬 Mensaje recibido:</h3>
                    <p><%= message %></p> <!-- VULNERABLE: XSS directo -->
                </div>
            <% } %>

            <!-- VULNERABLE: Formulario de búsqueda con XSS -->
            <section class="search-section">
                <h2>🔍 Búsqueda del Sistema</h2>
                <div class="vulnerability-note">⚠️ VULNERABILIDAD: XSS Reflected</div>
                
                <form method="GET" action="index.jsp" class="search-form">
                    <input type="text" name="search" placeholder="Buscar en el sistema..." value="<%= search != null ? search : "" %>">
                    <button type="submit">🔎 Buscar</button>
                </form>
                
                <% if (search != null && !search.isEmpty()) { %>
                    <div class="search-results">
                        <h3>Resultados de búsqueda para: <%= search %></h3> <!-- VULNERABLE: XSS -->
                        <p>Se encontraron 0 resultados para la consulta: <strong><%= search %></strong></p>
                    </div>
                <% } %>
            </section>

            <!-- Panel de funcionalidades vulnerables -->
            <section class="features-grid">
                <div class="feature-card">
                    <h3>📋 Headers HTTP</h3>
                    <p>Visualiza información de headers HTTP del cliente</p>
                    <div class="vuln-tags">
                        <span class="vuln-tag">Information Disclosure</span>
                        <span class="vuln-tag">Header Injection</span>
                    </div>
                    <a href="headers" class="btn btn-primary">Ver Headers</a>
                </div>

                <div class="feature-card">
                    <h3>👤 Who I Am</h3>
                    <p>Sistema de autenticación con múltiples vulnerabilidades</p>
                    <div class="vuln-tags">
                        <span class="vuln-tag">SQL Injection</span>
                        <span class="vuln-tag">Weak Auth</span>
                        <span class="vuln-tag">Session Management</span>
                    </div>
                    <a href="whoiam" class="btn btn-primary">Autenticar</a>
                </div>

                <div class="feature-card">
                    <h3>💾 File Upload</h3>
                    <p>Subida de archivos sin validación adecuada</p>
                    <div class="vuln-tags">
                        <span class="vuln-tag">File Upload</span>
                        <span class="vuln-tag">Path Traversal</span>
                    </div>
                    <a href="upload.jsp" class="btn btn-primary">Subir Archivos</a>
                </div>

                <div class="feature-card">
                    <h3>🗄️ Database</h3>
                    <p>Consultas a base de datos con SQL Injection</p>
                    <div class="vuln-tags">
                        <span class="vuln-tag">SQL Injection</span>
                        <span class="vuln-tag">Database Exposure</span>
                    </div>
                    <a href="database.jsp" class="btn btn-primary">Consultar DB</a>
                </div>
            </section>

            <!-- VULNERABLE: Información de debug visible en producción -->
            <% if ("true".equals(debug) || "1".equals(debug)) { %>
                <section class="debug-panel">
                    <h2>🐛 Panel de Debug (PELIGROSO)</h2>
                    <div class="debug-info">
                        <h3>Información del Sistema:</h3>
                        <ul>
                            <li><strong>Java Version:</strong> <%= System.getProperty("java.version") %></li>
                            <li><strong>OS Name:</strong> <%= System.getProperty("os.name") %></li>
                            <li><strong>User Dir:</strong> <%= System.getProperty("user.dir") %></li>
                            <li><strong>User Home:</strong> <%= System.getProperty("user.home") %></li>
                            <li><strong>Temp Dir:</strong> <%= System.getProperty("java.io.tmpdir") %></li>
                        </ul>
                        
                        <h3>Variables de Sesión:</h3>
                        <ul>
                            <li><strong>Session ID:</strong> <%= session.getId() %></li>
                            <li><strong>Creation Time:</strong> <%= new Date(session.getCreationTime()) %></li>
                            <li><strong>Max Inactive:</strong> <%= session.getMaxInactiveInterval() %> segundos</li>
                        </ul>
                        
                        <h3>Headers HTTP:</h3>
                        <ul>
                            <%
                                Enumeration<String> headerNames = request.getHeaderNames();
                                while (headerNames.hasMoreElements()) {
                                    String headerName = headerNames.nextElement();
                                    String headerValue = request.getHeader(headerName);
                            %>
                                <li><strong><%= headerName %>:</strong> <%= headerValue %></li>
                            <%
                                }
                            %>
                        </ul>
                    </div>
                </section>
            <% } %>

            <!-- Panel de ejemplos de vulnerabilidades -->
            <section class="examples-section">
                <h2>🎯 Ejemplos de Testing</h2>
                
                <div class="example-card">
                    <h3>XSS Testing</h3>
                    <p>Prueba estos payloads en el campo de búsqueda:</p>
                    <code>&lt;script&gt;alert('XSS')&lt;/script&gt;</code><br>
                    <code>&lt;img src=x onerror=alert('XSS')&gt;</code>
                </div>

                <div class="example-card">
                    <h3>SQL Injection Testing</h3>
                    <p>Prueba estos payloads en Who I Am:</p>
                    <code>' OR '1'='1</code><br>
                    <code>admin'; DROP TABLE users; --</code>
                </div>

                <div class="example-card">
                    <h3>Information Disclosure</h3>
                    <p>Accede a información de debug:</p>
                    <code><a href="?debug=true">index.jsp?debug=true</a></code><br>
                    <code><a href="headers">Headers del sistema</a></code>
                </div>
            </section>
        </main>

        <footer class="main-footer">
            <p>📅 <%= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()) %></p>
            <p>🌐 User-Agent: <%= userAgent %></p>
            <p>⚠️ Esta aplicación contiene vulnerabilidades intencionalmente para propósitos educativos</p>
        </footer>
    </div>

    <!-- VULNERABLE: Script inline con funciones expuestas -->
    <script>
        // VULNERABLE: Función que ejecuta código sin validación
        function processMessage(msg) {
            document.write("Procesando: " + msg); // XSS vulnerability
        }
        
        // VULNERABLE: Exposición de información sensible en JavaScript
        var systemInfo = {
            server: "<%= serverInfo %>",
            context: "<%= contextPath %>",
            userIP: "<%= remoteAddr %>",
            sessionId: "<%= session.getId() %>"
        };
        
        console.log("System Info:", systemInfo);
        
        // Auto-submit de formularios con parámetros maliciosos (simulado)
        if (window.location.search.includes('autoSubmit=true')) {
            window.onload = function() {
                console.log("VULNERABLE: Auto-ejecución detectada");
                // Simulación de vulnerabilidad eval
            };
        }
    </script>
</body>
</html> 