using AutoLot.Models;
using Microsoft.Data.SqlClient;
using System.Data;

namespace AutoLot.Data;

public class VehicleRepository(IConfiguration config)
{
    private string Connection => config.GetConnectionString("AutoLot")
        ?? throw new InvalidOperationException("Set ConnectionStrings:AutoLot first. See README.");

    private const string Columns = @"SELECT v.VehicleID, mk.Name AS Make, m.Name AS Model, v.Year,
        v.AskingPrice, v.SalePrice, v.Mileage, v.AvailabilityStatus, v.Description,
        v.BodyStyle, v.FuelType, v.Transmission, v.EngineDetails, v.Color, v.VehicleCondition
        FROM dbo.Vehicles v JOIN dbo.Models m ON v.ModelID=m.ModelID
        JOIN dbo.Makes mk ON m.MakeID=mk.MakeID ";

    public async Task<List<Vehicle>> Search(string? make, string? model, int? year,
        decimal? minPrice, decimal? maxPrice, bool featured, int page)
    {
        await using var connection = new SqlConnection(Connection);
        await connection.OpenAsync();
        await using var cmd = new SqlCommand(Columns + @"WHERE v.IsActive=1
          AND (@make IS NULL OR mk.Name LIKE '%' + @make + '%')
          AND (@model IS NULL OR m.Name LIKE '%' + @model + '%')
          AND (@year IS NULL OR v.Year=@year)
          AND (@min IS NULL OR COALESCE(v.SalePrice,v.AskingPrice)>=@min)
          AND (@max IS NULL OR COALESCE(v.SalePrice,v.AskingPrice)<=@max)
          AND (@featured=0 OR v.IsFeatured=1)
          ORDER BY v.VehicleID OFFSET @offset ROWS FETCH NEXT 12 ROWS ONLY", connection);
        cmd.Parameters.Add("@make", SqlDbType.NVarChar, 80).Value = (object?)make ?? DBNull.Value;
        cmd.Parameters.Add("@model", SqlDbType.NVarChar, 80).Value = (object?)model ?? DBNull.Value;
        cmd.Parameters.Add("@year", SqlDbType.Int).Value = (object?)year ?? DBNull.Value;
        foreach (var (name, value) in new[] { ("@min", minPrice), ("@max", maxPrice) }) {
            var p = cmd.Parameters.Add(name, SqlDbType.Decimal); p.Precision=12; p.Scale=2; p.Value=(object?)value ?? DBNull.Value;
        }
        cmd.Parameters.Add("@featured", SqlDbType.Bit).Value = featured;
        cmd.Parameters.Add("@offset", SqlDbType.Int).Value = (page-1)*12;
        var result = new List<Vehicle>();
        await using (var reader = await cmd.ExecuteReaderAsync())
            while (await reader.ReadAsync()) result.Add(ReadVehicle(reader));
        foreach (var vehicle in result) vehicle.Photos.AddRange(await GetPhotos(connection, vehicle.Id));
        return result;
    }

    public async Task<Vehicle?> GetById(int id)
    {
        await using var connection = new SqlConnection(Connection);
        await connection.OpenAsync();
        await using var cmd = new SqlCommand(Columns + "WHERE v.IsActive=1 AND v.VehicleID=@id", connection);
        cmd.Parameters.Add("@id", SqlDbType.Int).Value=id;
        Vehicle? result = null;
        await using (var reader = await cmd.ExecuteReaderAsync())
            if (await reader.ReadAsync()) result = ReadVehicle(reader);
        if (result != null) result.Photos.AddRange(await GetPhotos(connection, id));
        return result;
    }

    private static Vehicle ReadVehicle(SqlDataReader r) => new(
        r.GetInt32(0), r.GetString(1), r.GetString(2), r.GetInt32(3), r.GetDecimal(4),
        r.IsDBNull(5) ? null : r.GetDecimal(5), r.GetInt32(6), r.GetString(7),
        Text(r,8), Text(r,9), Text(r,10), Text(r,11), Text(r,12), Text(r,13), Text(r,14), new());
    private static string? Text(SqlDataReader r, int i) => r.IsDBNull(i) ? null : r.GetString(i);
    private static async Task<List<VehiclePhoto>> GetPhotos(SqlConnection c, int id) {
        await using var cmd = new SqlCommand("SELECT ImageLocation, AltText FROM dbo.VehiclePhotos WHERE VehicleID=@id ORDER BY DisplayOrder, PhotoID", c);
        cmd.Parameters.Add("@id", SqlDbType.Int).Value=id;
        var photos = new List<VehiclePhoto>();
        await using var r = await cmd.ExecuteReaderAsync();
        while (await r.ReadAsync()) photos.Add(new(r.GetString(0), r.GetString(1)));
        return photos;
    }
}
