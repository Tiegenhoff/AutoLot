using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using AutoLot.Models;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace AutoLot.Controllers;

[ApiController]
[Route("api/account")]
public class AccountController(
    UserManager<ApplicationUser> userManager,
    SignInManager<ApplicationUser> signInManager,
    IAntiforgery antiforgery) : ControllerBase
{
    [HttpGet("antiforgery")]
    [AllowAnonymous]
    [ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
    public IActionResult GetAntiforgeryToken()
    {
        var tokens = antiforgery.GetAndStoreTokens(HttpContext);
        return Ok(new { token = tokens.RequestToken });
    }

    [HttpPost("register")]
    [AllowAnonymous]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Register(RegisterRequest request)
    {
        var email = request.Email.Trim();
        var user = new ApplicationUser
        {
            UserName = email,
            Email = email,
            FullName = request.FullName.Trim(),
            PhoneNumber = request.Phone?.Trim()
        };

        var result = await userManager.CreateAsync(user, request.Password);
        if (!result.Succeeded)
            return BadRequest(new { errors = result.Errors.Select(error => error.Description) });

        var roleResult = await userManager.AddToRoleAsync(user, "Customer");
        if (!roleResult.Succeeded)
        {
            await userManager.DeleteAsync(user);
            return Problem("Customer role is unavailable. Apply the database setup scripts and try again.");
        }

        await signInManager.SignInAsync(user, isPersistent: false);
        return await AccountInfo(user);
    }

    [HttpPost("login")]
    [AllowAnonymous]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        var result = await signInManager.PasswordSignInAsync(
            request.Email.Trim(), request.Password, request.RememberMe, lockoutOnFailure: true);

        if (!result.Succeeded)
            return Unauthorized(new { message = "Email or password is incorrect, or the account is locked." });

        var user = await userManager.FindByEmailAsync(request.Email.Trim());
        return user is null ? Unauthorized() : await AccountInfo(user);
    }

    [HttpPost("logout")]
    [Authorize]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Logout()
    {
        await signInManager.SignOutAsync();
        return NoContent();
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<IActionResult> Me()
    {
        var user = await userManager.GetUserAsync(User);
        return user is null ? Unauthorized() : await AccountInfo(user);
    }

    private async Task<IActionResult> AccountInfo(ApplicationUser user)
    {
        var roles = await userManager.GetRolesAsync(user);
        return Ok(new { fullName = user.FullName, email = user.Email, roles });
    }
}

public sealed class RegisterRequest
{
    [Required, StringLength(100, MinimumLength = 2)]
    public string FullName { get; set; } = string.Empty;

    [Required, EmailAddress, StringLength(254)]
    public string Email { get; set; } = string.Empty;

    [Required, StringLength(128, MinimumLength = 12)]
    public string Password { get; set; } = string.Empty;

    [Phone, StringLength(30)]
    public string? Phone { get; set; }
}

public sealed class LoginRequest
{
    [Required, EmailAddress, StringLength(254)]
    public string Email { get; set; } = string.Empty;

    [Required, StringLength(128)]
    public string Password { get; set; } = string.Empty;

    public bool RememberMe { get; set; }
}
