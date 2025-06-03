using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Xml;
using System.Net;

namespace WSP2.Controllers
{
    public class HeadersController : Controller
    {
        private readonly ILogger<HeadersController> _logger;

        public HeadersController(ILogger<HeadersController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            var headers = new Dictionary<string, string>();
            foreach (var header in Request.Headers)
            {
                headers[header.Key] = header.Value.ToString();
                // VULNERABLE: Log de información sensible
                _logger.LogInformation("Header expuesto: {HeaderName} = {HeaderValue}", header.Key, header.Value);
            }

            ViewBag.Headers = headers;
            ViewBag.ServerInfo = HttpContext.Request.Host.ToString();
            ViewBag.RemoteAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
            ViewBag.RemoteHost = HttpContext.Connection.RemoteIpAddress?.ToString();
            ViewBag.UserAgent = Request.Headers["User-Agent"].ToString();

            // VULNERABLE: Exposición de variables de sistema
            ViewBag.JavaVersion = Environment.Version.ToString();
            ViewBag.OSName = Environment.OSVersion.ToString();
            ViewBag.UserHome = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);

            return View();
        }

        [HttpPost]
        public IActionResult ProcessXml(string xmlData)
        {
            try
            {
                // VULNERABLE: XXE (XML External Entity)
                var xmlDoc = new XmlDocument();
                xmlDoc.XmlResolver = new XmlUrlResolver(); // VULNERABLE: Permite entidades externas
                xmlDoc.LoadXml(xmlData);
                
                return Ok("XML procesado correctamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al procesar XML");
                return BadRequest("Error al procesar XML");
            }
        }

        [HttpPost]
        public IActionResult DownloadFile(string url)
        {
            try
            {
                // VULNERABLE: SSRF (Server-Side Request Forgery)
                using (var client = new WebClient())
                {
                    var content = client.DownloadString(url);
                    return Ok(content);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al descargar archivo");
                return BadRequest("Error al descargar archivo");
            }
        }

        [HttpPost]
        public IActionResult SaveLog(string logData)
        {
            // VULNERABLE: Log Injection
            _logger.LogInformation(logData);
            
            // VULNERABLE: Unsafe File Operations
            var logPath = Path.Combine("/var/log", "app.log");
            System.IO.File.AppendAllText(logPath, logData + Environment.NewLine);
            
            return Ok("Log guardado correctamente");
        }

        [HttpPost]
        public IActionResult ExecuteScript(string script)
        {
            // VULNERABLE: Dynamic Code Execution
            var scriptPath = Path.Combine("/tmp", "script.cs");
            System.IO.File.WriteAllText(scriptPath, script);
            
            // VULNERABLE: Unsafe Process Execution
            var process = new System.Diagnostics.Process();
            process.StartInfo.FileName = "dotnet";
            process.StartInfo.Arguments = $"run {scriptPath}";
            process.Start();
            
            return Ok("Script ejecutado");
        }

        [HttpPost]
        public IActionResult UpdateEnvironment(string envVar, string value)
        {
            // VULNERABLE: Environment Variable Injection
            Environment.SetEnvironmentVariable(envVar, value);
            
            // VULNERABLE: Unsafe System Command
            var process = new System.Diagnostics.Process();
            process.StartInfo.FileName = "env";
            process.Start();
            
            return Ok("Variable de entorno actualizada");
        }
    }
} 