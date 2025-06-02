using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Text;

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
    }
} 