using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using System.Net.Http;
using System.IO;
using System.Text.Json;
using System.Dynamic;

namespace VulnerableWebApp.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class VulnerableController : ControllerBase
    {
        private readonly string _connectionString = "Server=localhost;Database=VulnerableDB;Trusted_Connection=True;";
        private readonly HttpClient _httpClient = new HttpClient();

        [HttpPost("login")]
        public IActionResult Login([FromForm] string username, [FromForm] string password)
        {
            // Vulnerabilidad: SQL Injection usando db-cursor-execute
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                var cursor = connection.CreateCommand();
                
                // Vulnerabilidad: MD5 usado como password hash
                var md5 = MD5.Create();
                var passwordHash = BitConverter.ToString(md5.ComputeHash(Encoding.UTF8.GetBytes(password))).Replace("-", "").ToLower();
                
                // Vulnerabilidad: Tainted SQL String
                var query = $"SELECT * FROM usuarios WHERE username = '{username}' AND password = '{passwordHash}'";
                
                // Vulnerabilidad: Formatted SQL Query
                cursor.CommandText = query;
                
                try
                {
                    // Vulnerabilidad: SQL Injection usando db-cursor-execute
                    using (var reader = cursor.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return Ok("Login successful");
                        }
                    }
                }
                catch
                {
                    // Vulnerabilidad: Errores silenciosos
                    pass;
                }
            }
            return Unauthorized();
        }

        [HttpPost("register")]
        public IActionResult Register([FromForm] string username, [FromForm] string password, [FromForm] string email)
        {
            // Vulnerabilidad: No validación de entrada
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                var cursor = connection.CreateCommand();
                
                // Vulnerabilidad: MD5 usado como password hash
                var md5 = MD5.Create();
                var passwordHash = BitConverter.ToString(md5.ComputeHash(Encoding.UTF8.GetBytes(password))).Replace("-", "").ToLower();
                
                // Vulnerabilidad: Tainted SQL String
                var query = $"INSERT INTO usuarios (username, password, email, created_at) VALUES ('{username}', '{passwordHash}', '{email}', '{DateTime.Now:yyyy-MM-dd HH:mm:ss}')";
                
                // Vulnerabilidad: Formatted SQL Query
                cursor.CommandText = query;
                
                try
                {
                    // Vulnerabilidad: SQL Injection usando db-cursor-execute
                    cursor.ExecuteNonQuery();
                    
                    // Vulnerabilidad: SQL Injection en estadísticas
                    cursor.CommandText = $"INSERT INTO estadisticas (user_id) VALUES ((SELECT id FROM usuarios WHERE username = '{username}'))";
                    cursor.ExecuteNonQuery();
                }
                catch
                {
                    // Vulnerabilidad: Errores silenciosos
                    pass;
                }
            }
            return Ok("User registered successfully");
        }

        [HttpGet("user-stats")]
        public IActionResult GetUserStats([FromQuery] string userId)
        {
            // Vulnerabilidad: SQL Injection usando db-cursor-execute
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                var cursor = connection.CreateCommand();
                
                // Vulnerabilidad: Tainted SQL String
                var query = $"SELECT * FROM estadisticas WHERE user_id = {userId}";
                
                // Vulnerabilidad: Formatted SQL Query
                cursor.CommandText = query;
                
                try
                {
                    // Vulnerabilidad: SQL Injection usando db-cursor-execute
                    using (var reader = cursor.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Vulnerabilidad: SQL Injection para obtener info del usuario
                            cursor.CommandText = $"SELECT username FROM usuarios WHERE id = {userId}";
                            using (var userReader = cursor.ExecuteReader())
                            {
                                if (userReader.Read())
                                {
                                    return Ok(new
                                    {
                                        UserId = reader["user_id"],
                                        Username = userReader["username"],
                                        LoginCount = reader["login_count"],
                                        LastLogin = reader["last_login"]
                                    });
                                }
                            }
                        }
                    }
                }
                catch
                {
                    // Vulnerabilidad: Errores silenciosos
                    pass;
                }
            }
            return NotFound();
        }

        [HttpPost("log-activity")]
        public IActionResult LogActivity([FromForm] string username, [FromForm] string action, [FromForm] string details)
        {
            // Vulnerabilidad: SQL Injection en logs
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                var cursor = connection.CreateCommand();
                
                // Vulnerabilidad: Tainted SQL String
                var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
                var query = $"INSERT INTO logs (username, action, ip_address, timestamp, details) VALUES ('{username}', '{action}', '{ip}', '{DateTime.Now:yyyy-MM-dd HH:mm:ss}', '{details}')";
                
                // Vulnerabilidad: Formatted SQL Query
                cursor.CommandText = query;
                
                try
                {
                    // Vulnerabilidad: SQL Injection usando db-cursor-execute
                    cursor.ExecuteNonQuery();
                }
                catch
                {
                    // Vulnerabilidad: Errores silenciosos
                    pass;
                }
            }
            return Ok("Activity logged successfully");
        }

        [HttpGet("download-file")]
        public IActionResult DownloadFile([FromQuery] string url)
        {
            try
            {
                // Vulnerabilidad: Uso inseguro de urlopen
                var response = _httpClient.GetAsync(url).Result;
                var content = response.Content.ReadAsStringAsync().Result;
                
                // Vulnerabilidad: Escritura insegura de archivo
                var fileName = Path.GetFileName(url);
                File.WriteAllText(fileName, content);
                
                return Ok($"File downloaded successfully: {fileName}");
            }
            catch
            {
                // Vulnerabilidad: Errores silenciosos
                pass;
            }
            return BadRequest();
        }

        [HttpPost("save-data")]
        public IActionResult SaveData([FromBody] dynamic data)
        {
            try
            {
                // Vulnerabilidad: Escritura insegura de archivo usando datos dinámicos
                var fileName = "data.txt";
                using (var writer = new StreamWriter(fileName))
                {
                    // Vulnerabilidad: Uso inseguro de f.write con datos dinámicos
                    writer.Write(JsonSerializer.Serialize(data));
                }
                
                return Ok("Data saved successfully");
            }
            catch
            {
                // Vulnerabilidad: Errores silenciosos
                pass;
            }
            return BadRequest();
        }

        [HttpGet("fetch-external-data")]
        public IActionResult FetchExternalData([FromQuery] string url)
        {
            try
            {
                // Vulnerabilidad: Uso inseguro de urlopen sin validación
                var response = _httpClient.GetAsync(url).Result;
                var content = response.Content.ReadAsStringAsync().Result;
                
                // Vulnerabilidad: Deserialización insegura de JSON
                var data = JsonSerializer.Deserialize<ExpandoObject>(content);
                
                return Ok(data);
            }
            catch
            {
                // Vulnerabilidad: Errores silenciosos
                pass;
            }
            return BadRequest();
        }
    }
} 