# 🎵 Concert Management - Oracle Database Project

This project is an implementation of a relational database for managing concerts, ticket sales, artists, and genres, developed using **Oracle Database 19c** and **PL/SQL**. The system includes functionalities for handling event details, user interactions, and business rules.

## 🚀 Features
- **Ticket Management**: Purchase and manage event tickets.
- **Artist & Genre Management**: Store and retrieve artist details and their associated music genres.
- **Automated Message Logging**: Logs important database operations.
- **Triggers**:
  - **Statement-Level Trigger**: Logs ticket insertions.
  - **Row-Level Trigger**: Updates available seats when tickets are purchased.
  - **DDL Trigger**: Monitors schema modifications (`DROP`/`ALTER` on the `LOCATIE` table).

## 📁 Project Structure
The repository contains the following files:
- `schema.sql` - Defines the database schema, including tables, constraints, and relationships.
- `mesaje_schema.sql` - Defines the message logging system for tracking database actions.
- `plsql_procedures.sql` - Contains stored procedures and functions for managing tickets, users, and business logic.
- `triggers.sql` - Implements statement-level, row-level, and DDL triggers for automated database actions.
- `package.sql` - Defines a PL/SQL package that encapsulates key procedures, functions, and triggers.
- `documentation.docx` - Detailed explanation of the project, including diagrams, implementation details, and query explanations.
- `README.md` - This documentation file.

## 🛠 Technologies and Tools Used
- **Oracle SQL** 
- **PL/SQL**
- **Implemented in sqldeveloper**
  
### Steps to Run the Project
```sql
-- 1. Create the database schema
@schema.sql

-- 2. Create the message logging system
@mesaje_schema.sql

-- 3. Insert sample data (optional, for testing purposes)
@sample_data.sql

-- 4. Execute stored procedures and functions
@plsql_procedures.sql

-- 5. Create database triggers
@triggers.sql

-- 6. Load the PL/SQL package
@package.sql

-- 7. Verify database setup
SELECT * FROM CONCERT;
SELECT * FROM UTILIZATOR;
```

## 📜 Documentation

For a detailed explanation, refer to **documentation.docx**, which includes:

- **ER Diagrams**: Entity-Relationship model representation of the database.
- **Normalization Steps**: Step-by-step process from **1NF → 3NF**.
- **Query Explanations**: Breakdown of complex SQL queries and their purpose.
- **Stored Procedure Details**: Description of PL/SQL stored procedures and their functionality.
- **Trigger Implementations**: Explanation and execution of database triggers (Statement-Level, Row-Level, DDL).


