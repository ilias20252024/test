using Microsoft.AspNetCore.Mvc;

namespace VulnerableWebApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HeadersController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetHeaders()
        {
            var headers = Request.Headers.ToDictionary(h => h.Key, h => h.Value.ToString());
            return Ok(headers);
        }
    }
} 