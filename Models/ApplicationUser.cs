using Microsoft.AspNetCore.Identity;

namespace AutoLot.Models;

public class ApplicationUser : IdentityUser<int>
{
    public string FullName { get; set; } = string.Empty;
}
