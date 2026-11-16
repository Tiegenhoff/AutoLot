using AutoLot.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace AutoLot.Identity;

public class AutoLotIdentityDbContext(DbContextOptions<AutoLotIdentityDbContext> options)
    : IdentityDbContext<ApplicationUser, IdentityRole<int>, int>(options)
{
    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<ApplicationUser>(entity =>
        {
            entity.ToTable("Users");
            entity.Property(user => user.Id).HasColumnName("UserID");
            entity.Property(user => user.Email).HasMaxLength(254).IsRequired();
            entity.Property(user => user.NormalizedEmail).HasMaxLength(254);
            entity.Property(user => user.UserName).HasMaxLength(254);
            entity.Property(user => user.NormalizedUserName).HasMaxLength(254);
            entity.Property(user => user.PasswordHash).HasMaxLength(500);
            entity.Property(user => user.PhoneNumber).HasColumnName("Phone").HasMaxLength(30);
            entity.Property(user => user.FullName).HasMaxLength(100).IsRequired();
        });

        builder.Entity<IdentityRole<int>>().ToTable("AspNetRoles");
        builder.Entity<IdentityUserClaim<int>>().ToTable("AspNetUserClaims");
        builder.Entity<IdentityUserRole<int>>().ToTable("AspNetUserRoles");
        builder.Entity<IdentityUserLogin<int>>().ToTable("AspNetUserLogins");
        builder.Entity<IdentityRoleClaim<int>>().ToTable("AspNetRoleClaims");
        builder.Entity<IdentityUserToken<int>>().ToTable("AspNetUserTokens");
    }
}
