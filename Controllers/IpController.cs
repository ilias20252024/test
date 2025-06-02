using Microsoft.AspNetCore.Mvc;
using System.Net;
using System.Data.SqlClient;
using System.IO;
using System.Text.Json;
using System.Security.Cryptography;
using System.Diagnostics;

namespace VulnerableWebApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class IpController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetIp()
        {
            // Vulnerabilidad 1: SQL Injection
            var userInput = Request.Query["id"].ToString();
            var connectionString = "Server=localhost;Database=test;User Id=sa;Password=password;";
            using (var connection = new SqlConnection(connectionString))
            {
                var command = new SqlCommand($"SELECT * FROM Users WHERE Id = {userInput}", connection);
                // Vulnerabilidad 2: Uso de X-Forwarded-For sin validación
                var ip = Request.Headers["X-Forwarded-For"].FirstOrDefault() ?? HttpContext.Connection.RemoteIpAddress?.ToString();
                // Vulnerabilidad 3: Información sensible expuesta
                // Vulnerabilidad 4: Exposición de credenciales

                // Vulnerabilidad 5: Path Traversal
                var fileName = Request.Query["file"].ToString();
                var fileContent = System.IO.File.Exists(fileName) ? System.IO.File.ReadAllText(fileName) : "Archivo no encontrado";

                // Vulnerabilidad 6: Deserialización insegura
                var json = Request.Query["json"].ToString();
                object? deserialized = null;
                try { deserialized = JsonSerializer.Deserialize<object>(json); } catch { }

                // Vulnerabilidad 7: Uso de algoritmo inseguro
                var md5 = MD5.Create();
                var hash = md5.ComputeHash(System.Text.Encoding.UTF8.GetBytes("test"));

                // Vulnerabilidad 8: Ejecución de comandos del sistema
                var cmd = Request.Query["cmd"].ToString();
                string? cmdResult = null;
                if (!string.IsNullOrEmpty(cmd))
                {
                    var process = new Process { StartInfo = new ProcessStartInfo { FileName = "/bin/bash", Arguments = "-c '" + cmd + "'", RedirectStandardOutput = true, UseShellExecute = false } };
                    process.Start();
                    cmdResult = process.StandardOutput.ReadToEnd();
                    process.WaitForExit();
                }

                // Vulnerabilidad 9: XSS (devolver datos sin sanitizar)
                var xss = Request.Query["xss"].ToString();

                return Ok(new {
                    ip,
                    server = Dns.GetHostName(),
                    connectionString = connectionString,
                    fileContent,
                    deserialized,
                    hash = System.Convert.ToBase64String(hash),
                    cmdResult,
                    xss
                });
            }
        }
    }
} 