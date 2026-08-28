# Care Plan Generator - Initial Design Doc

## 1. Problem

A specialty pharmacy needs a tool to automatically generate care plans from patient clinical records.

Today, pharmacists manually review each patient's medical history and write a care plan. This takes about 20-40 minutes per patient. The pharmacy is short-staffed, backlogged, and needs these care plans for compliance, Medicare reimbursement, and pharma reporting.

## 2. Target Users

The users are CVS medical workers, such as medical assistants or pharmacy staff.

Patients do not use this system directly. Staff will enter patient/order information, generate a care plan, download it, and potentially print it or upload it into another internal system.

## 3. MVP Scope

The MVP should allow a medical worker to:

- Enter patient, provider, diagnosis, medication, medication history, and patient record information in a web form
- Validate required input fields
- Detect duplicate-looking patients and orders
- Enforce provider uniqueness by NPI
- Generate one care plan per medication order using an LLM
- Download the generated care plan as a text file
- Export basic reporting data for pharma

## 4. Out of Scope for MVP

These are intentionally deferred:

- Patient-facing portal
- Authentication and role-based access control
- Real production EHR integration
- Real insurance, Medicare, or pharma submission
- PDF parsing as the only supported input path
- Advanced real-time updates
- Cloud deployment
- Monitoring dashboards

Some of these will be introduced later in the course after the pain point becomes visible.

## 5. Required Inputs

Each care plan order should collect:

- Patient first name
- Patient last name
- Referring provider name
- Referring provider NPI
- Patient MRN
- Patient primary diagnosis as an ICD-10 code
- Medication name
- Additional diagnoses as a list of ICD-10 codes
- Medication history as a list of strings
- Patient records as text, with PDF support deferred unless required later

## 6. Validation Rules

Every input must be validated before the system accepts an order.

Initial validation rules:

- Provider NPI must be a 10-digit number
- Patient MRN must be a unique 6-digit number
- ICD-10 diagnosis codes must match a valid ICD-10-like format
- Required text fields cannot be empty
- Medication history can be empty, but if present each item must be a string
- Additional diagnoses can be empty, but if present each item must be a valid ICD-10-like code

## 7. Duplicate and Integrity Rules

### Order Duplicate Rules

| Scenario | Result | Reason |
| --- | --- | --- |
| Same patient + same medication + same day | Error, block submission | Very likely duplicate submission |
| Same patient + same medication + different day | Warning, allow confirmation | Could be a refill or renewal |

### Patient Duplicate Rules

| Scenario | Result | Reason |
| --- | --- | --- |
| Same MRN + different name or DOB | Warning, allow confirmation | Could be data entry error |
| Same name + same DOB + different MRN | Warning, allow confirmation | Could be same patient entered twice |

### Provider Rules

| Scenario | Result | Reason |
| --- | --- | --- |
| Same NPI + same provider name | Reuse existing provider | Provider already exists |
| Same NPI + different provider name | Error, block submission | NPI is the unique provider identifier |

## 8. Care Plan Output Requirements

Each generated care plan must include:

- Problem list
- Goals
- Pharmacist interventions
- Monitoring plan

The care plan can initially be generated as plain text and downloaded as a `.txt` file.

## 9. Initial Data Model

This is a first draft and will be refined during the database design day.

Possible entities:

- Patient
- Provider
- Order
- CarePlan

Initial relationships:

- One patient can have many orders
- One provider can refer many orders
- One order has one generated care plan

## 10. Initial API Ideas

These are not final API contracts yet.

- `POST /orders`: submit patient/provider/order information and request care plan generation
- `GET /orders`: list submitted orders
- `GET /orders/{order_id}`: view order details and generated care plan
- `GET /orders/{order_id}/download`: download care plan text file
- `GET /reports/export`: export pharma reporting data

## 11. Error Handling Principles

The system should:

- Return clear validation errors to users
- Separate blocking errors from non-blocking warnings
- Avoid exposing stack traces
- Avoid exposing unnecessary PHI in logs or error messages
- Handle LLM failures without crashing the app

## 12. Open Questions for Customer

- What exact format does pharma reporting require?
- Should care plans be downloadable only as `.txt`, or also PDF/CSV later?
- Which ICD-10 validation level is required: format-only or lookup against an official code set?
- Does the system need DOB as an input for patient duplicate detection?
- Who confirms warnings: medical assistant, pharmacist, or any staff user?
- Should generated care plans be editable before download?
- Are there required audit logs for compliance?

## 13. Interview Talking Points

If an interviewer asks why we started with a design doc instead of code:

- The original requirements were ambiguous around duplicate detection, warnings, provider uniqueness, and output format.
- Clarifying these rules first prevents building the wrong behavior.
- The design doc gives engineers, PMs, and future reviewers a shared source of truth.

If an interviewer asks why the MVP uses plain text output first:

- The core value is generating correct care plan content.
- Plain text is simple to verify, download, and test.
- More polished export formats can be added later after the core workflow works.

