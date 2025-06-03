<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>

<%
    // VULNERABLE: Configuración de base de datos hardcodeada
    String dbUrl = "jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1";
    String dbUser = "sa";
    String dbPassword = "";
    
    // VULNERABLE: Parámetros de consulta sin validación
    String query = request.getParameter("query");
    String table = request.getParameter("table");
    String searchTerm = request.getParameter("search");
    String userId = request.getParameter("userId");
    
    String resultMessage = "";
    List<Map<String, Object>> results = new ArrayList<>();
    
    // Inicializar base de datos con datos de prueba
    try {
        Class.forName("org.h2.Driver");
        Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
        
        // Crear tablas de prueba si no existen
        Statement stmt = conn.createStatement();
        stmt.execute("CREATE TABLE IF NOT EXISTS users (id INT PRIMARY KEY, username VARCHAR(50), password VARCHAR(50), email VARCHAR(100), role VARCHAR(20))");
        stmt.execute("CREATE TABLE IF NOT EXISTS products (id INT PRIMARY KEY, name VARCHAR(100), price DECIMAL(10,2), description TEXT)");
        stmt.execute("CREATE TABLE IF NOT EXISTS orders (id INT PRIMARY KEY, user_id INT, product_id INT, quantity INT, total DECIMAL(10,2))");
        
        // Insertar datos de prueba
        stmt.execute("INSERT INTO users VALUES (1, 'admin', 'admin123', 'admin@example.com', 'admin') ON DUPLICATE KEY UPDATE username=username");
        stmt.execute("INSERT INTO users VALUES (2, 'user1', 'pass123', 'user1@example.com', 'user') ON DUPLICATE KEY UPDATE username=username");
        stmt.execute("INSERT INTO users VALUES (3, 'guest', 'guest', 'guest@example.com', 'guest') ON DUPLICATE KEY UPDATE username=username");
        
        stmt.execute("INSERT INTO products VALUES (1, 'Laptop', 999.99, 'High-performance laptop') ON DUPLICATE KEY UPDATE name=name");
        stmt.execute("INSERT INTO products VALUES (2, 'Mouse', 29.99, 'Wireless mouse') ON DUPLICATE KEY UPDATE name=name");
        stmt.execute("INSERT INTO products VALUES (3, 'Keyboard', 79.99, 'Mechanical keyboard') ON DUPLICATE KEY UPDATE name=name");
        
        stmt.close();
        conn.close();
    } catch (Exception e) {
        resultMessage = "Error inicializando base de datos: " + e.getMessage();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database - WSP2 SecDevOps</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
</head>
<body>
    <div class="container">
        <header class="main-header">
            <h1>🗄️ Database - Consultas SQL</h1>
            <p class="subtitle">Sistema de consultas con vulnerabilidades de SQL Injection</p>
            
            <div class="warning-banner">
                ⚠️ <strong>VULNERABILIDADES:</strong> SQL Injection, Database Exposure, No Sanitization
            </div>
        </header>

        <main>
            <!-- Consulta SQL directa -->
            <section class="search-section">
                <h2>💀 Consulta SQL Directa (PELIGROSO)</h2>
                <div class="vulnerability-note">⚠️ Ejecución directa de SQL sin validación</div>
                
                <form method="post" action="database.jsp" class="search-form">
                    <div class="form-group">
                        <label for="query">Consulta SQL:</label>
                        <textarea id="query" name="query" rows="4" placeholder="SELECT * FROM users WHERE id = 1"><%= query != null ? query : "" %></textarea>
                        <small>💀 VULNERABLE: Consulta SQL directa sin prepared statements</small>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">🚀 Ejecutar Consulta</button>
                </form>
            </section>

            <!-- Búsqueda de usuarios -->
            <section class="search-section">
                <h2>👥 Búsqueda de Usuarios</h2>
                <div class="vulnerability-note">⚠️ SQL Injection en búsqueda</div>
                
                <form method="get" action="database.jsp" class="search-form">
                    <div class="form-group">
                        <label for="search">Buscar usuario:</label>
                        <input type="text" id="search" name="search" value="<%= searchTerm != null ? searchTerm : "" %>" placeholder="admin">
                        <small>⚠️ Prueba: admin' OR '1'='1</small>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">🔍 Buscar</button>
                </form>
            </section>

            <!-- Consulta por ID de usuario -->
            <section class="search-section">
                <h2>🔢 Consulta por ID</h2>
                <div class="vulnerability-note">⚠️ Concatenación directa de parámetros</div>
                
                <form method="get" action="database.jsp" class="search-form">
                    <div class="form-group">
                        <label for="userId">ID de Usuario:</label>
                        <input type="text" id="userId" name="userId" value="<%= userId != null ? userId : "" %>" placeholder="1">
                        <small>⚠️ Prueba: 1 UNION SELECT password,username,email,role,id FROM users</small>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">🔎 Consultar</button>
                </form>
            </section>

            <!-- Resultados de consultas -->
            <%
                if (query != null && !query.trim().isEmpty()) {
                    try {
                        Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
                        Statement stmt = conn.createStatement();
                        
                        // VULNERABLE: Ejecución directa de SQL sin validación
                        boolean isResultSet = stmt.execute(query);
                        
                        if (isResultSet) {
                            ResultSet rs = stmt.getResultSet();
                            ResultSetMetaData metaData = rs.getMetaData();
                            int columnCount = metaData.getColumnCount();
                            
                            out.println("<section class='examples-section'>");
                            out.println("<h2>📊 Resultados de la Consulta</h2>");
                            out.println("<div class='example-card'>");
                            out.println("<h3>Consulta ejecutada: <code>" + query + "</code></h3>");
                            out.println("<table class='headers-table'>");
                            
                            // Headers
                            out.println("<tr>");
                            for (int i = 1; i <= columnCount; i++) {
                                out.println("<th>" + metaData.getColumnName(i) + "</th>");
                            }
                            out.println("</tr>");
                            
                            // Datos
                            while (rs.next()) {
                                out.println("<tr>");
                                for (int i = 1; i <= columnCount; i++) {
                                    Object value = rs.getObject(i);
                                    out.println("<td>" + (value != null ? value.toString() : "NULL") + "</td>");
                                }
                                out.println("</tr>");
                            }
                            
                            out.println("</table>");
                            out.println("</div>");
                            out.println("</section>");
                        } else {
                            int updateCount = stmt.getUpdateCount();
                            resultMessage = "Consulta ejecutada. Filas afectadas: " + updateCount;
                        }
                        
                        stmt.close();
                        conn.close();
                    } catch (Exception e) {
                        resultMessage = "Error ejecutando consulta: " + e.getMessage();
                    }
                }
                
                // VULNERABLE: Búsqueda con concatenación directa
                if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                    try {
                        Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
                        Statement stmt = conn.createStatement();
                        
                        String sql = "SELECT * FROM users WHERE username LIKE '%" + searchTerm + "%' OR email LIKE '%" + searchTerm + "%'";
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        out.println("<section class='examples-section'>");
                        out.println("<h2>👥 Resultados de Búsqueda</h2>");
                        out.println("<div class='example-card'>");
                        out.println("<h3>Búsqueda: <code>" + searchTerm + "</code></h3>");
                        out.println("<h4>SQL: <code>" + sql + "</code></h4>");
                        out.println("<table class='headers-table'>");
                        out.println("<tr><th>ID</th><th>Usuario</th><th>Password</th><th>Email</th><th>Rol</th></tr>");
                        
                        while (rs.next()) {
                            out.println("<tr>");
                            out.println("<td>" + rs.getInt("id") + "</td>");
                            out.println("<td>" + rs.getString("username") + "</td>");
                            out.println("<td>" + rs.getString("password") + "</td>");
                            out.println("<td>" + rs.getString("email") + "</td>");
                            out.println("<td>" + rs.getString("role") + "</td>");
                            out.println("</tr>");
                        }
                        
                        out.println("</table>");
                        out.println("</div>");
                        out.println("</section>");
                        
                        rs.close();
                        stmt.close();
                        conn.close();
                    } catch (Exception e) {
                        resultMessage = "Error en búsqueda: " + e.getMessage();
                    }
                }
                
                // VULNERABLE: Consulta por ID con concatenación
                if (userId != null && !userId.trim().isEmpty()) {
                    try {
                        Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
                        Statement stmt = conn.createStatement();
                        
                        String sql = "SELECT * FROM users WHERE id = " + userId;
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        out.println("<section class='examples-section'>");
                        out.println("<h2>🔢 Consulta por ID</h2>");
                        out.println("<div class='example-card'>");
                        out.println("<h3>ID: <code>" + userId + "</code></h3>");
                        out.println("<h4>SQL: <code>" + sql + "</code></h4>");
                        out.println("<table class='headers-table'>");
                        out.println("<tr><th>ID</th><th>Usuario</th><th>Password</th><th>Email</th><th>Rol</th></tr>");
                        
                        while (rs.next()) {
                            out.println("<tr>");
                            out.println("<td>" + rs.getInt("id") + "</td>");
                            out.println("<td>" + rs.getString("username") + "</td>");
                            out.println("<td>" + rs.getString("password") + "</td>");
                            out.println("<td>" + rs.getString("email") + "</td>");
                            out.println("<td>" + rs.getString("role") + "</td>");
                            out.println("</tr>");
                        }
                        
                        out.println("</table>");
                        out.println("</div>");
                        out.println("</section>");
                        
                        rs.close();
                        stmt.close();
                        conn.close();
                    } catch (Exception e) {
                        resultMessage = "Error en consulta por ID: " + e.getMessage();
                    }
                }
                
                if (!resultMessage.isEmpty()) {
                    out.println("<div class='alert alert-info'>");
                    out.println("<h3>💬 Resultado:</h3>");
                    out.println("<p>" + resultMessage + "</p>");
                    out.println("</div>");
                }
            %>

            <!-- Ejemplos de testing -->
            <section class="examples-section">
                <h2>🎯 Ejemplos de SQL Injection</h2>
                
                <div class="example-card">
                    <h3>Consultas de Reconocimiento</h3>
                    <p>Prueba estas consultas SQL:</p>
                    <code>SELECT * FROM information_schema.tables</code><br>
                    <code>SELECT * FROM information_schema.columns WHERE table_name='users'</code><br>
                    <code>SELECT version()</code>
                </div>

                <div class="example-card">
                    <h3>SQL Injection en Búsqueda</h3>
                    <p>Prueba estos payloads en búsqueda:</p>
                    <code>' OR '1'='1</code><br>
                    <code>' UNION SELECT password,username,email,role,id FROM users--</code><br>
                    <code>' OR 1=1--</code>
                </div>

                <div class="example-card">
                    <h3>SQL Injection en ID</h3>
                    <p>Prueba estos payloads en ID:</p>
                    <code>1 UNION SELECT password,username,email,role,id FROM users</code><br>
                    <code>1 OR 1=1</code><br>
                    <code>-1 UNION SELECT table_name,table_schema,null,null,null FROM information_schema.tables</code>
                </div>
            </section>

            <!-- Panel de información de BD -->
            <section class="debug-panel">
                <h2>🐛 Información de Base de Datos</h2>
                <div class="debug-info">
                    <h3>Configuración:</h3>
                    <ul>
                        <li><strong>URL:</strong> <%= dbUrl %></li>
                        <li><strong>Usuario:</strong> <%= dbUser %></li>
                        <li><strong>Password:</strong> <%= dbPassword.isEmpty() ? "(vacío)" : "***" %></li>
                    </ul>
                    
                    <h3>Tablas Disponibles:</h3>
                    <ul>
                        <li><strong>users</strong> - Información de usuarios</li>
                        <li><strong>products</strong> - Catálogo de productos</li>
                        <li><strong>orders</strong> - Pedidos realizados</li>
                    </ul>
                </div>
            </section>

            <div class="navigation">
                <a href="index.jsp">🏠 Volver al inicio</a>
                <a href="headers">📋 Ver Headers</a>
                <a href="whoiam">👤 Who I Am</a>
                <a href="upload.jsp">💾 File Upload</a>
            </div>
        </main>

        <footer class="main-footer">
            <p>⚠️ Esta funcionalidad contiene vulnerabilidades intencionalmente para propósitos educativos</p>
            <p>💀 Nunca ejecutes consultas SQL sin validación en producción</p>
        </footer>
    </div>

    <!-- VULNERABLE: JavaScript con información sensible -->
    <script>
        // VULNERABLE: Exposición de credenciales de BD
        var dbConfig = {
            url: "<%= dbUrl %>",
            user: "<%= dbUser %>",
            password: "<%= dbPassword %>"
        };
        
        console.log("Database config:", dbConfig);
        
        // Función para generar consultas maliciosas
        function generatePayload(type) {
            var payloads = {
                'union': "1 UNION SELECT password,username,email,role,id FROM users",
                'dump': "' UNION SELECT table_name,table_schema,null,null,null FROM information_schema.tables--",
                'bypass': "' OR '1'='1' --"
            };
            
            var payload = payloads[type];
            if (payload) {
                document.getElementById('userId').value = payload;
                alert("Payload generado: " + payload);
            }
        }
        
        // Auto-completar consultas comunes
        function quickQuery(query) {
            var queries = {
                'users': "SELECT * FROM users",
                'products': "SELECT * FROM products", 
                'schema': "SELECT * FROM information_schema.tables"
            };
            
            document.getElementById('query').value = queries[query];
        }
    </script>
</body>
</html> 