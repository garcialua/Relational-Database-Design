# Jay-Mart Relational Database System

A complete relational database implementation for **Jay-Mart**, a multi-department retail store. Designed and implemented through the complete database development lifecycle—from conceptual modeling to physical schema implementation, automated constraint testing, and data population—leveraging Generative AI as an iterative design aid.
---
## Project Overview
* **Course:** CSCI 362 - Database Management Systems
* **Target DBMS:** MySQL
* **Key Topics:** Relational Database Design, ER Modeling, DDL, Integrity Constraints, Testing, GenAI Prompting & Critical Analysis

### Store Scenario
Jay-Mart manages ~50 employees, multiple product departments (e.g., Electronics, Clothing, Grocery), inventory, customer records, and sales transactions. This database system establishes schema integrity, referential integrity across entities, and business constraints for operational stability.
---
## Database Architecture & Features
* **Database Engine:** MySQL
* **Language:** SQL (Data Definition Language & Data Manipulation Language)
* **Modeling Tools:** Generative AI (Iterative Prompting) & ER Diagramming
* **Key Entities:** Suppliers, Employees, Departments, Categories, Products, Inventory, Customers, Transactions, Transaction Lines, Payments, Promotions, Product Promotions, and Attendance.
---
## Schema Highlights & Integrity Constraints
* **Dependency Ordering:** Tables are created in strict dependency order to ensure foreign key integrity.
* **Circular Dependency Resolution:** Solved circular dependency between `EMPLOYEE` and `DEPARTMENT` using schema alteration (`ALTER TABLE`).
* **Explicit Constraints:** Enforces business logic using explicit primary keys (`pk_`), foreign keys (`fk_`), unique constraints (`uq_`), and check constraints (`ck_`) for salaries, prices, quantities, and dates.
* **Cascading Rules:** Configured precise `ON UPDATE CASCADE` and `ON DELETE` rules (`RESTRICT`, `CASCADE`, `SET NULL`) across relationship pairs.
---
## Repository Structure
* **`/sql/jaymart_ddl.sql`**: Complete MySQL DDL script with 14 relational tables, explicit constraints, and weak entity handling.
* **`/docs/`**: Full project report detailing requirements gathering, ER diagram modeling, prompt engineering logs, and critical AI evaluations.

---

## 📄 Documentation
 [**View Full Project Report (PDF)**](./docs/CSCI362_DBMS_Project_Report.pdf)
