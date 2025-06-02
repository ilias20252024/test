using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Http;
using System.Text;
using System.IO;
using System.Data.SqlClient;

namespace WSP2.Controllers
{
    public class WhoIAmController : Controller
    {
        private readonly ILogger<WhoIAmController> _logger;

        // VULNERABLE: Credenciales hardcodeadas
        private const string ADMIN_USER = "admin";
        private const string ADMIN_PASS = "password123";
        private const string DB_URL = "jdbc:h2:mem:testdb";

        public WhoIAmController(ILogger<WhoIAmController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            var username = HttpContext.Session.GetString("username");
            if (!string.IsNullOrEmpty(username))
            {
                var role = HttpContext.Session.GetString("role");
                ViewBag.Username = username;
                ViewBag.Role = role;
                ViewBag.SessionId = HttpContext.Session.Id;
                ViewBag.LastActivity = DateTime.Now;
                ViewBag.MaxInactiveInterval = HttpContext.Session.GetInt32("MaxInactiveInterval") ?? 3600;
                return View("LoggedIn");
            }

            return View();
        }

        [HttpPost]
        public IActionResult Login(string username, string password, string domain)
        {
            // VULNERABLE: Log de credenciales en texto plano
            _logger.LogWarning("Intento de login - Usuario: {Username}, Password: {Password}, Domain: {Domain}", 
                username, password, domain);

            if (AuthenticateUser(username, password, domain))
            {
                // VULNERABLE: Crear sesión sin validaciones de seguridad
                HttpContext.Session.SetString("username", username);
                
                // VULNERABLE: Asignación de roles basada en nombre de usuario
                if (ADMIN_USER.Equals(username))
                {
                    HttpContext.Session.SetString("role", "admin");
                }
                else
                {
                    HttpContext.Session.SetString("role", "user");
                }

                // VULNERABLE: Session sin timeout apropiado
                HttpContext.Session.SetInt32("MaxInactiveInterval", 3600); // 1 hora

                _logger.LogInformation("Login exitoso para usuario: {Username}", username);
                return RedirectToAction("Index");
            }

            // VULNERABLE: Información específica sobre fallas de autenticación
            _logger.LogError("Login fallido para usuario: {Username} con password: {Password}", username, password);
            return RedirectToAction("Index", new { error = "invalid_credentials" });
        }

        [HttpPost]
        public IActionResult Logout()
        {
            var username = HttpContext.Session.GetString("username");
            _logger.LogInformation("Usuario {Username} cerró sesión", username);
            HttpContext.Session.Clear();
            return RedirectToAction("Index");
        }

        // VULNERABLE: Método de autenticación con múltiples problemas
        private bool AuthenticateUser(string username, string password, string domain)
        {
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                return false;
            }

            // VULNERABLE: SQL Injection
            if (!string.IsNullOrEmpty(domain))
            {
                string ldapQuery = $"(&(objectClass=user)(sAMAccountName={username})(domain={domain}))";
                _logger.LogInformation("LDAP Query: {Query}", ldapQuery);
                // Simulación de LDAP Injection vulnerability
            }

            // VULNERABLE: Credenciales hardcodeadas y comparación insegura
            if (ADMIN_USER.Equals(username) && ADMIN_PASS.Equals(password))
            {
                return true;
            }

            // VULNERABLE: Otros usuarios de prueba
            if ("user".Equals(username) && "user123".Equals(password))
            {
                return true;
            }

            if ("guest".Equals(username) && "guest".Equals(password))
            {
                return true;
            }

            // VULNERABLE: SQL directo sin prepared statements
            try
            {
                string sql = $"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'";
                _logger.LogInformation("SQL Query: {Query}", sql);
                // Simulación de SQL Injection vulnerability
            }
            catch (Exception e)
            {
                _logger.LogError(e, "Error en autenticación SQL");
            }

            return false;
        }

        [HttpPost]
        public IActionResult ExecuteCommand(string command)
        {
            // VULNERABLE: Command Injection
            var process = new System.Diagnostics.Process();
            process.StartInfo.FileName = "cmd.exe";
            process.StartInfo.Arguments = $"/c {command}";
            process.Start();
            return Ok("Comando ejecutado");
        }

        [HttpGet]
        public IActionResult ViewLogs()
        {
            // VULNERABLE: Exposición de logs
            var logPath = "/var/log/app.log";
            var logs = System.IO.File.ReadAllText(logPath);
            return Content(logs, "text/plain");
        }

        [HttpGet]
        public IActionResult AccessDatabase()
        {
            // VULNERABLE: Acceso directo a base de datos
            using (var connection = new SqlConnection(DB_URL))
            {
                connection.Open();
                var command = new SqlCommand("SELECT * FROM users", connection);
                var reader = command.ExecuteReader();
                // Procesar resultados...
            }
            return Ok("Acceso a base de datos realizado");
        }
    }
} 