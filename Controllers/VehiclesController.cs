using AutoLot.Data;
using Microsoft.AspNetCore.Mvc;

namespace AutoLot.Controllers;

[ApiController]
[Route("api/vehicles")]
public class VehiclesController(VehicleRepository vehicles) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Search([FromQuery] string? make, [FromQuery] string? model,
        [FromQuery] int? year, [FromQuery] decimal? minPrice, [FromQuery] decimal? maxPrice,
        [FromQuery] bool featured = false, [FromQuery] int page = 1)
    {
        if (page < 1 || page > 100000 || year is < 1886 or > 2100 || minPrice < 0 || maxPrice < 0 || minPrice > maxPrice)
            return BadRequest("Check your year, price range, and page number.");
        return Ok(await vehicles.Search(make, model, year, minPrice, maxPrice, featured, page));
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Details(int id)
    {
        var vehicle = await vehicles.GetById(id);
        return vehicle is null ? NotFound() : Ok(vehicle);
    }
}
