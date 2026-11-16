using System.Security.Claims;
using AutoLot.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoLot.Controllers;

[ApiController]
[Route("api/customer/requests")]
[Authorize(Roles = "Customer")]
public class CustomerRequestsController(CustomerRequestHistoryRepository history) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetHistory()
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
            return Unauthorized();

        return Ok(await history.GetForUser(userId));
    }
}
