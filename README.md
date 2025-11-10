# Fleet Maintenance Work Orders — PL/SQL Collections, Records, and `GOTO`

## 📚 Overview
This mini‑project demonstrates **PL/SQL Collections**, **Records**, and the **`GOTO` statement** in a single, realistic scenario: managing **vehicle maintenance work orders** for a transport fleet.

You will:
- Use a **Nested Table** (collection) to store **part costs** for a work order (supports sparse lists and `DELETE` gaps).
- Use a **Record** to group **vehicle/work‑order fields** together.
- Use **`GOTO`** to route the flow for **invalid data** (e.g., negative part cost) and **cost thresholds** (e.g., very expensive jobs).

This aligns with your instructor’s focus on **PL/SQL composite data types** and control flow.

---

## 🧩 Problem Statement
A transport company logs maintenance work orders. For each work order, we must:
1) **Store** part costs (collection) and vehicle info (record).
2) **Validate** inputs (no negative costs; no excessive labor hours).
3) **Summarize** the **total parts + labor** cost.
4) **Branch** with **`GOTO`** to special handling if invalid data appears or if the job is **“High‑Cost”**.

---

## 🧱 What’s Demonstrated
- **Collections**: `TYPE NumTable IS TABLE OF NUMBER;` (Nested Table)
- **Records**: `TYPE WorkOrderRec IS RECORD (...);`
- **GOTO**: `GOTO InvalidData;` / `GOTO HighCost;` with labels

---

## ⚙️ Requirements
- Oracle Database (19c+ recommended)
- SQL*Plus or SQL Developer
- Enable server output:
```sql
SET SERVEROUTPUT ON;
```

---

## ▶️ How to Run
1. Open `fleet_maintenance_demo.sql` in SQL Developer (or paste into SQL*Plus).
2. Ensure `SET SERVEROUTPUT ON;` is enabled.
3. Execute the script.
4. Observe output for three scenarios:
   - **Normal** (valid costs)
   - **InvalidData** (negative cost)
   - **HighCost** (very expensive total)

---

## 🧪 Expected Sample Outputs

### ✅ Normal Flow
```
Work Order for Plate: RAD-123Z
Parts (existing indices): 1,3,4
Total Parts Cost: 730.0
Labor Hours: 3.5
Labor Rate: 45
Grand Total: 887.5
Status: OK
```

### ❌ Invalid Data (Negative Cost)
```
[ERROR] Invalid part cost encountered: -250 at index 2
Work order flagged. Review required.
```

### ⚠️ High Cost
```
[ALERT] High maintenance cost detected: 5600.0
Apply extra approvals before processing.
```

---

## 📁 Repository Tree
```
plsql-fleet-maintenance-goto/
├── README.md
├── fleet_maintenance_demo.sql
├── documentation/
│   └── report.docx
└── screenshots/
    └── README.txt
```

---

## 👨‍💻 Author
- Name: ASDODJI Le Sage
- Course: INSY 831 — Database Development with PL/SQL
- Institution: AUCA
- Date: November 2025
