# AutoLot — group project starter

A starting point based on the group's progress report: HTML/CSS/JavaScript, ASP.NET Core/C#, and SQL Server. The public inventory page searches the database and links to vehicle details. Sample vehicles are fictional.

## What works in the starter
- SQL schema for users, makes/models, vehicles/photos, test-drive requests, reservations and inquiries. Constraints include unique VINs and email addresses, nonnegative prices/mileage, and a filtered unique index allowing only one confirmed reservation per vehicle.
- Read-only vehicle API with search, featured listings, detail, and 12 results per page.
- Responsive homepage and vehicle detail page. A photo placeholder is used until photo records are added.

## What still needs building
- Registration/login, secure password hashing, authorization and customer request history.
- Test-drive and reservation forms, and employee review/confirmation. Confirming a reservation must check availability and update both reservation and vehicle status in one database transaction. The unique index alone does not implement this workflow.
- Contact form and employee inquiry review; dealership contact details.
- Employee dashboard, inventory management, photo management, featured selection and sale prices. Soft-delete listings using IsActive to preserve history.
- Better pagination (total count), automated tests, accessibility and cross-browser testing, and real photos/content. The current API is read-only; no login or dashboard exists yet.

This is a development starter, not production-ready. It has not been compiled or run in the creation environment because the .NET SDK and SQL Server were unavailable. Test locally before relying on it.

## Windows setup
1. Install the .NET 8 SDK, SQL Server (Express/LocalDB or a local SQL Server instance), SQL Server Management Studio (SSMS), and an editor such as Visual Studio 2022 or VS Code with C# support. Each group member needs their own SQL Server database unless the team sets up a shared server.
2. Open `database/setup.sql` in SSMS, connect to your SQL Server instance, and execute it. It creates the AutoLot database, tables and sample data. Run this on a fresh database only: it does not reset existing tables, and will fail if run twice. Do not delete a database containing work you need.
3. Open a terminal in the folder containing `AutoLot.csproj`. Set your local connection using .NET user secrets (these are stored outside the project and should not be committed):

```powershell
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:AutoLot" "Server=(localdb)\MSSQLLocalDB;Database=AutoLot;Trusted_Connection=True;TrustServerCertificate=True"
```

For SQL Server Express, the server might instead be `.\SQLEXPRESS`. Use the same server name you connected to in SSMS. The example uses Windows authentication and a trusted local development certificate. Don't put passwords or real customer data in GitHub. `dotnet user-secrets init` adds a UserSecretsId to the project file: one person can commit this ID so everyone can use their own secret value with it.
4. Run:

```powershell
dotnet restore
dotnet run
```

Open the `http://localhost:...` address printed in the terminal. Leave that terminal running. Don't open `index.html` directly: the frontend needs the API. If a database error occurs, check that SQL Server is running, your connection string matches SSMS, and setup.sql completed successfully.

## Where to work
- `wwwroot/`: pages, styles and browser JavaScript.
- `Controllers/`: HTTP API endpoints.
- `Data/`: database access. Use parameterized SQL.
- `Models/`: API data types.
- `database/setup.sql`: initial database schema and sample records.

## Working together with GitHub Desktop
1. One member extracts the ZIP and opens GitHub Desktop. Choose **File → Add Local Repository**, select the extracted AutoLot folder, then choose **Create a repository** if prompted. Create it in that folder, commit the files if needed, and choose **Publish repository**. A private repository is a good choice for a class project.
2. On GitHub, open the repository's **Settings → Collaborators**, invite each teammate using their GitHub username or email, and have them accept the invitation. Repository owner access is needed to invite people.
3. Everyone else signs in to GitHub Desktop, chooses **File → Clone Repository**, selects the repository and local folder, then clones it. Set up their own database and connection secret as above; the database data does not automatically travel with Git.
4. Before starting work, switch to `main` and use **Fetch origin**, then **Pull origin** if changes are available. Create a new branch such as `feature/contact-form` using **Current branch → New branch**. Work on one feature at a time.
5. Save changes, review them in GitHub Desktop, write a short summary, and **Commit to branch**. Choose **Publish branch** or **Push origin**. Create a pull request to merge the branch into `main`, have a teammate review/test it, and merge it on GitHub. Pull the updated `main` before beginning the next feature. Resolve conflicts together when two people edit the same lines.
6. When changing the database, commit a new numbered SQL script under `database/` (for example `002_add_feature.sql`) and explain how to run it. Do not rely on committing your local database file. Coordinate schema changes before merging.

Suggested work split: one person handles accounts/security, one customer requests, one employee dashboard/inventory management, and one frontend/contact/testing. Agree on API routes and schema changes before overlapping work. Use GitHub Issues to track tasks.
