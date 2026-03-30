# Oracle HCM Goal Audit Report

## Overview

This repository contains the SQL query and documentation for a **BI Publisher (BIP) report developed in Oracle HCM Cloud** to audit employee goal changes.

The report provides visibility into goal creation and updates, including who modified the goal and when the changes occurred.

This solution supports audit, compliance, and tracking of goal lifecycle activities.

---

## Technology Stack

* Oracle HCM Cloud
* Oracle BI Publisher (BIP)
* Oracle SQL

---

## Objective

The objective of this report is to track and audit changes made to employee goals.

The report helps organizations:

* Monitor goal updates
* Identify who made changes
* Track last update timestamps
* Ensure transparency in goal management

---

## Key Data Extracted

### Employee Information

* Employee Name
* Person Number
* Assignment Number

---

### Goal Details

* Goal Name
* Goal Description
* Goal Status
* Goal Creation Date
* Last Update Date

---

### Audit Information

* Last Updated By (User ID)
* Last Updated By Name
* Update Timestamp

---

## Oracle HCM Tables Used

### Goal Management

* HRG_GOALS

---

### Employee Data

* PER_ALL_PEOPLE_F
* PER_PERSON_NAMES_F
* PER_ALL_ASSIGNMENTS_M

---

### Supporting Tables

* PER_USERS
* PER_EMAIL_ADDRESSES

---

## Query Logic Highlights

### Goal Change Tracking

The report uses:

* CREATION_DATE
* LAST_UPDATE_DATE

to track when goals were created and modified.

---

### User Identification

The query identifies:

* User ID who updated the goal
* Corresponding employee name

using user and person mapping tables.

---

### Filtering

The report supports filtering based on:

* Date range
* Employee
* Assignment status

---

## Key Features

* Tracks goal lifecycle changes
* Identifies users making updates
* Provides audit trail for goals
* Supports compliance requirements
* Enables monitoring of HR and manager actions

---

## Repository Structure

```id="6g0r5w"
oracle-hcm-goal-audit-report
│
├── README.md
└── goal_audit_report.sql
```

---

## Use Cases

* Audit and compliance tracking
* Monitoring goal updates
* Identifying unauthorized changes
* HR reporting and analysis

---

## Learning Outcomes

This report demonstrates:

* Oracle HCM Goal Management data model
* Audit tracking using SQL
* User and employee mapping
* BI Publisher reporting
* Data governance concepts

---

## Author

Saurabh Mharolkar
Oracle HCM Developer

---

## License

This project is licensed under the MIT License.
