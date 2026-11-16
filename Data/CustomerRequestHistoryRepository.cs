using System.Data;
using AutoLot.Models;
using Microsoft.Data.SqlClient;

namespace AutoLot.Data;

public class CustomerRequestHistoryRepository(IConfiguration config)
{
    private string Connection => config.GetConnectionString("AutoLot")
        ?? throw new InvalidOperationException("Set ConnectionStrings:AutoLot first. See README.");

    public async Task<CustomerRequestHistory> GetForUser(int userId)
    {
        await using var connection = new SqlConnection(Connection);
        await connection.OpenAsync();

        var reservations = new List<ReservationHistoryItem>();
        await using (var command = new SqlCommand(@"
            SELECT r.ReservationID, r.RequestDate, r.Status, v.VehicleID, mk.Name, m.Name, v.Year
            FROM dbo.Reservations AS r
            JOIN dbo.Vehicles AS v ON v.VehicleID = r.VehicleID
            JOIN dbo.Models AS m ON m.ModelID = v.ModelID
            JOIN dbo.Makes AS mk ON mk.MakeID = m.MakeID
            WHERE r.UserID = @UserID
            ORDER BY r.RequestDate DESC", connection))
        {
            command.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
            await using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                reservations.Add(new ReservationHistoryItem(
                    reader.GetInt32(0), reader.GetDateTime(1), reader.GetString(2),
                    reader.GetInt32(3), reader.GetString(4), reader.GetString(5), reader.GetInt32(6)));
            }
        }

        var testDrives = new List<TestDriveHistoryItem>();
        await using (var command = new SqlCommand(@"
            SELECT t.TestDriveID, t.PreferredDateTime, t.Status, v.VehicleID, mk.Name, m.Name, v.Year
            FROM dbo.TestDriveRequests AS t
            JOIN dbo.Vehicles AS v ON v.VehicleID = t.VehicleID
            JOIN dbo.Models AS m ON m.ModelID = v.ModelID
            JOIN dbo.Makes AS mk ON mk.MakeID = m.MakeID
            WHERE t.UserID = @UserID
            ORDER BY t.PreferredDateTime DESC", connection))
        {
            command.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
            await using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                testDrives.Add(new TestDriveHistoryItem(
                    reader.GetInt32(0), reader.GetDateTime(1), reader.GetString(2),
                    reader.GetInt32(3), reader.GetString(4), reader.GetString(5), reader.GetInt32(6)));
            }
        }

        return new CustomerRequestHistory(reservations, testDrives);
    }
}
