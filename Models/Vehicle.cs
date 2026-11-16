namespace AutoLot.Models;

public record Vehicle(int Id, string Make, string Model, int Year, decimal AskingPrice,
    decimal? SalePrice, int Mileage, string Status, string? Description, string? BodyStyle,
    string? FuelType, string? Transmission, string? Engine, string? Color, string? Condition,
    List<VehiclePhoto> Photos);
public record VehiclePhoto(string Url, string AltText);
