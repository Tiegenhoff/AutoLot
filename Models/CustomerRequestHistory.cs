namespace AutoLot.Models;

public sealed record ReservationHistoryItem(
    int Id,
    DateTime RequestDate,
    string Status,
    int VehicleId,
    string Make,
    string Model,
    int Year);

public sealed record TestDriveHistoryItem(
    int Id,
    DateTime PreferredDateTime,
    string Status,
    int VehicleId,
    string Make,
    string Model,
    int Year);

public sealed record CustomerRequestHistory(
    IReadOnlyList<ReservationHistoryItem> Reservations,
    IReadOnlyList<TestDriveHistoryItem> TestDrives);
