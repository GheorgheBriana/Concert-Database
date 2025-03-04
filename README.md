# Concert-Database
# 🎟️ Concert Management - PL/SQL

A database management system for handling concerts, tickets, and artists using PL/SQL.

## 🚀 Features
- **🎫 Ticket Management**: Store and retrieve ticket details, calculate prices.
- **🎶 Artist & Genre Management**: Retrieve artists and their associated music genres.
- **📜 Automated Message Logging**: Tracks database operations and errors.
- ⚡ **Triggers:**
  - **Statement-Level Trigger**: Logs ticket insertions.
  - **Row-Level Trigger**: Updates available seats when tickets are purchased.
  - **DDL Trigger**: Monitors schema modifications (`DROP`/`ALTER` on the `LOCATIE` table).

## 📂 Project Structure
```
📦 Concert-Management-PLSQL  
├── 📜 `concert_management_package.sql` # PL/SQL Package with stored procedures & functions  
├── 📜 `triggers.sql` # All database triggers  
├── 📜 `tables.sql` # Table definitions  
├── 📜 `sequences.sql` # Sequences for unique identifiers  
├── 📜 `sample_data.sql` # Sample test data  
├── 📜 `README.md` # Project documentation  
```

## ⚙️ Setup Instructions

### 🔹 Prerequisites
- 🏛️ **Oracle Database** (SQL\*Plus, SQL Developer, or any compatible tool)
- 🖥️ **PL/SQL environment** (Local setup or cloud instance)
- 📂 **Clone the repository** and navigate to the project directory:

```sh
git clone https://github.com/your-repo/concert-management-plsql.git
cd concert-management-plsql
```

### 🔧 Installation
1. **Create database schema**:
   ```sql
   @tables.sql
   ```
2. **Insert sample data**:
   ```sql
   @sample_data.sql
   ```
3. **Create sequences**:
   ```sql
   @sequences.sql
   ```
4. **Create stored procedures & functions**:
   ```sql
   @concert_management_package.sql
   ```
5. **Create triggers**:
   ```sql
   @triggers.sql
   ```

### ▶️ Running the Project
- Execute the package procedures:
   ```sql
   BEGIN
       PKG_GESTIUNE_CONCERTE.GESTIONARE_BILETE;
   END;
   /
   ```
- Test ticket insertion:
   ```sql
   INSERT INTO BILET (ID_CONCERT, ID_UTILIZATOR, ID_TIP_BILET) VALUES (5, 8, 1);
   ```

## 🛠️ Troubleshooting
- Ensure the database connection is established before executing scripts.
- Check log messages stored in the `MESAJE` table for debugging.

## 📜 License
This project is licensed under the MIT License.
