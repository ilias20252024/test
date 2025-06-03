<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>

<%
    // VULNERABLE: Procesamiento de archivos sin validación
    String uploadPath = "/tmp/uploads/";
    String message = "";
    String fileInfo = "";
    
    // VULNERABLE: Path traversal en parámetros
    String customPath = request.getParameter("path");
    if (customPath != null && !customPath.isEmpty()) {
        uploadPath = customPath;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>File Upload - WSP2 SecDevOps</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <div class="container">
        <header class="main-header">
            <h1>💾 File Upload - Subida de Archivos</h1>
            <p class="subtitle">Sistema de subida de archivos con múltiples vulnerabilidades</p>
            
            <div class="warning-banner">
                ⚠️ <strong>VULNERABILIDADES:</strong> File Upload, Path Traversal, No Validation
            </div>
        </header>

        <main>
            <!-- Formulario de subida vulnerable -->
            <section class="search-section">
                <h2>📁 Subir Archivo</h2>
                <div class="vulnerability-note">⚠️ Sin validación de tipo, tamaño o contenido</div>
                
                <form method="post" action="upload.jsp" enctype="multipart/form-data" class="search-form">
                    <div class="form-group">
                        <label for="file">Seleccionar archivo:</label>
                        <input type="file" id="file" name="file" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="filename">Nombre personalizado (opcional):</label>
                        <input type="text" id="filename" name="filename" placeholder="archivo.txt">
                        <small>⚠️ VULNERABLE: Permite caracteres especiales como ../ </small>
                    </div>
                    
                    <!-- VULNERABLE: Path traversal -->
                    <div class="form-group">
                        <label for="path">Ruta de destino:</label>
                        <input type="text" id="path" name="path" value="<%= uploadPath %>" placeholder="/tmp/uploads/">
                        <small>💀 PELIGROSO: Control total de la ruta de destino</small>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">📤 Subir Archivo</button>
                </form>
            </section>

            <!-- Información de archivos subidos -->
            <section class="examples-section">
                <h2>📋 Archivos en el Sistema</h2>
                
                <div class="example-card">
                    <h3>📂 Directorio Actual</h3>
                    <p><strong>Ruta:</strong> <code><%= uploadPath %></code></p>
                    <p><strong>Archivos existentes:</strong></p>
                    
                    <!-- VULNERABLE: Listado de archivos sin restricciones -->
                    <%
                        try {
                            File dir = new File(uploadPath);
                            if (dir.exists() && dir.isDirectory()) {
                                File[] files = dir.listFiles();
                                if (files != null && files.length > 0) {
                                    out.println("<ul>");
                                    for (File file : files) {
                                        String fileName = file.getName();
                                        long fileSize = file.length();
                                        String lastModified = new Date(file.lastModified()).toString();
                                        
                                        out.println("<li>");
                                        out.println("<strong>" + fileName + "</strong> ");
                                        out.println("(" + fileSize + " bytes) ");
                                        out.println("- Modificado: " + lastModified);
                                        // VULNERABLE: Enlaces de descarga directa
                                        out.println(" <a href='download.jsp?file=" + uploadPath + fileName + "'>📥 Descargar</a>");
                                        out.println("</li>");
                                    }
                                    out.println("</ul>");
                                } else {
                                    out.println("<p><em>Directorio vacío</em></p>");
                                }
                            } else {
                                out.println("<p><em>Directorio no existe: " + uploadPath + "</em></p>");
                            }
                        } catch (Exception e) {
                            out.println("<p style='color: red;'>Error listando archivos: " + e.getMessage() + "</p>");
                        }
                    %>
                </div>
            </section>

            <!-- Ejemplos de testing -->
            <section class="examples-section">
                <h2>🎯 Ejemplos de Testing de Vulnerabilidades</h2>
                
                <div class="example-card">
                    <h3>Path Traversal Testing</h3>
                    <p>Prueba estas rutas en el campo "Ruta de destino":</p>
                    <code>../../../etc/</code><br>
                    <code>..\\..\\..\\windows\\system32\\</code><br>
                    <code>/etc/passwd</code>
                </div>

                <div class="example-card">
                    <h3>File Upload Bypass</h3>
                    <p>Prueba subir estos tipos de archivos:</p>
                    <code>shell.php</code><br>
                    <code>backdoor.jsp</code><br>
                    <code>malware.exe</code><br>
                    <code>script.js</code>
                </div>

                <div class="example-card">
                    <h3>Filename Manipulation</h3>
                    <p>Prueba estos nombres de archivo:</p>
                    <code>../../etc/passwd</code><br>
                    <code>..\\..\\boot.ini</code><br>
                    <code>shell.php.txt</code>
                </div>
            </section>

            <!-- Panel de información de sistema -->
            <section class="debug-panel">
                <h2>🐛 Información del Sistema de Archivos</h2>
                <div class="debug-info">
                    <h3>Configuración Actual:</h3>
                    <ul>
                        <li><strong>Upload Path:</strong> <%= uploadPath %></li>
                        <li><strong>Working Directory:</strong> <%= System.getProperty("user.dir") %></li>
                        <li><strong>Temp Directory:</strong> <%= System.getProperty("java.io.tmpdir") %></li>
                        <li><strong>File Separator:</strong> <%= System.getProperty("file.separator") %></li>
                    </ul>
                    
                    <h3>Permisos del Sistema:</h3>
                    <ul>
                        <li><strong>Can Read:</strong> <%= new File(uploadPath).canRead() %></li>
                        <li><strong>Can Write:</strong> <%= new File(uploadPath).canWrite() %></li>
                        <li><strong>Can Execute:</strong> <%= new File(uploadPath).canExecute() %></li>
                    </ul>
                </div>
            </section>

            <div class="navigation">
                <a href="index.jsp">🏠 Volver al inicio</a>
                <a href="headers">📋 Ver Headers</a>
                <a href="whoiam">👤 Who I Am</a>
                <a href="database.jsp">🗄️ Database</a>
            </div>
        </main>

        <footer class="main-footer">
            <p>⚠️ Esta funcionalidad contiene vulnerabilidades intencionalmente para propósitos educativos</p>
            <p>💀 NO usar en entornos de producción</p>
        </footer>
    </div>

    <!-- VULNERABLE: JavaScript con funciones peligrosas -->
    <script>
        // VULNERABLE: Función que permite ejecutar código arbitrario
        function executeFile(filename) {
            var confirmed = confirm("¿Ejecutar archivo: " + filename + "?\n(Esto es una simulación de vulnerabilidad)");
            if (confirmed) {
                alert("VULNERABILIDAD: Ejecución de archivo sin validación\nArchivo: " + filename);
                // En un escenario real, esto podría ejecutar código malicioso
            }
        }
        
        // Auto-rellenar ruta basada en OS detectado
        function detectOS() {
            var os = navigator.platform;
            var pathField = document.getElementById('path');
            
            if (os.includes('Win')) {
                pathField.value = 'C:\\Windows\\Temp\\';
            } else if (os.includes('Mac')) {
                pathField.value = '/tmp/';
            } else {
                pathField.value = '/var/tmp/';
            }
        }
        
        // VULNERABLE: Exposición de información del cliente
        console.log("Client info:", {
            platform: navigator.platform,
            userAgent: navigator.userAgent,
            language: navigator.language,
            cookieEnabled: navigator.cookieEnabled
        });
    </script>
</body>
</html> 