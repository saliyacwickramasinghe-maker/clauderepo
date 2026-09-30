# Badge demo: Workato build spec (merged with session handoff)

Audience: Claude Code (desktop app), building in the Workato workspace using **two tool sets together**: the AIRO MCP (`mcp__AIRO_MCP__*`) and the Workato Developer API MCP (`workato_devapi_mcp`).
Author context: Sal Wickramasinghe, Senior Solutions Consultant. Prospect: Badge Group Holdings (construction, ANZ).
Purpose: technical demo assets for Badge's stated requirements.

Status as of 2026-09-30: Gate 1 (discovery) is done. Nothing has been built yet. Read Section A first, then the spec (Sections 0 to 10).

---

## A. Handoff from the previous session

Gate 1 is done. Do not redo it in full, but re-verify the items below quickly before creating anything.

### A.1 Verified state

- **Project "Badge - Demo":** project ID 18139092, folder ID 35630656. Empty: no recipes, no subfolders, no data tables. There are no `badge_*` data tables anywhere in the workspace (72 tables checked). No "Bridgit Mock" assets exist elsewhere.
- **MySQL connection** `MySQL | Bridgit Mock` (ID 22218414) is active and authorized. Do not create a new MySQL connection.
- **Entra connection** `Microsoft Entra ID` (ID 19333274), custom connector `microsoft_entra_id_azure_active_directory__connector_3905295_1739841590`, was **"lost"** at last check even though authorization read "success". Re-check it. If it is still lost, ask Sal to reconnect it. It only blocks recipes 5.1 and 5.2.
- **On-Prem group** `OPA - Sal` (ID 39474) exists and is in use. `on_prem_group_status_get` returned a 422, so agent status is unverified. A test query through the MySQL connection will confirm it later.
- **HTTP connection for the mock API** (`Badge Demo - HTTP (Bridgit mock)`) does not exist yet. It has to wait for the API Platform collection.

### A.2 Tooling gaps and how to fill them

- AIRO has **no folder-create tool**, **no API Platform collection, client or key tools**, and **no data table row-insert tool**.
- `workato_devapi_mcp` should cover those gaps. It runs locally in this desktop app.
- **First action of the session: confirm the devapi tools are actually loaded** (search the tool list for `workato_devapi_mcp`). If they are not loaded, stop and tell Sal.
- Use devapi for:
  1. Creating the subfolders `API - Bridgit Mock`, `Recipes - HR Sync` and `Data Tables` inside folder 35630656. Check first that they do not already exist.
  2. The API Platform collection, client and key at Gate 4. **Never print the API key.** Sal retrieves it himself.
  3. Seeding data table rows, if devapi has a record-insert endpoint.
- AIRO `data_table_create` and `data_table_update` support only: name, type, optional, default_value, hint, multivalue, relation. There is **no unique, primary key or index option**.
  - Check whether devapi's data table endpoints can enforce uniqueness.
  - If they cannot, tell Sal plainly and enforce uniqueness in the recipes (lookup before insert).
- If devapi has no record-insert, seed the rows with a one-off recipe or give Sal a file to import. Ask which he prefers.

### A.3 Decisions already made

- Use the subfolders (Section 6 layout).
- Go ahead with Gate 3 (both data tables) once the folders exist.
- Still open: **O2** (UPN domain), **O3** (Employment Hero write-back: stub unless told otherwise), **O5** (shared or separate webhook trigger).

### A.4 Start here (Gate 2/3)

1. Confirm the devapi tools are loaded.
2. Create the three subfolders and report their IDs.
3. Confirm the Entra connection status.
4. Create and seed `badge_identity_map` and `badge_bridgit_field_map` in the `Data Tables` folder. **The column definitions and seed rows are in Section 3 below. Use them as written. Do not guess the schema.**
5. Tell Sal clearly whether unique columns can be enforced.

---

## 0. Rules of engagement (read first)

1. **Ground before creating.** Before building anything, list what already exists (`recipe_list`, `data_table_list`, `folder_list`, `project_list`, `mcp_server_get`) and search for the names below. If an asset already exists, edit it in place. Never create a `v2` or a duplicate copy.
2. **Confirm before acting.** Show the plan for each phase (Section 9) and wait for a yes before creating assets. Ask before deleting, moving or bulk-editing anything.
3. **Do not guess Workato specifics.** Where this spec says "verify", check the connector's actual actions and fields with `recipe_builder_list_connector_operations` / `recipe_builder_get_input_schema` before wiring them.
4. **No secrets in assets or in chat.** Use connection credential fields. Never write passwords, API keys or webhook secrets into recipe steps, data tables or descriptions.
5. **Surface ambiguity.** If an input is unclear or only a partial match (for example, two similarly named connections), stop and ask rather than picking one.
6. **Everything is demo data.** No real employee data. Use the sample payload in Section 7.
7. **Hand off by link, not by card.** Share finished assets as direct URLs (use `asset_url_get`), not in-chat file cards. Save deliverables into the designated folders, never at the root of a vault or Drive.
8. **End any research output with a "Sources:" section.**
9. **When delegating to sub-agents,** paste these rules verbatim and brief the task in full.

Open items to confirm with Sal before or during the build are collected in Section 10.

---

## 1. Badge requirements this spec addresses

| # | Badge requirement | Covered by |
|---|---|---|
| 1 | Integrate in-house apps (3 apps, internal network, standard web APIs) with Workato | Section 4 (mock API) + On-Prem Agent. See open item O1 |
| 2 | API gateway functionality | Section 4 (API Platform collection, auth, rate limit, docs) |
| 3 | Integration with Microsoft Graph API | Section 5 (Entra user create/update via existing Entra connection) |
| 4 | Managing entities with no matching key across systems (example: employee in Employment Hero and Bridgit) | Section 3 (data tables) + Section 5 (lookup-then-upsert pattern) |

---

## 2. Connections

| Name | Type | Status | Notes |
|---|---|---|---|
| `MySQL \| Bridgit Mock` (ID 22218414) | MySQL | **Already exists, active** | Points at database `bridgit_mock`. Uses the On-Prem Agent (group `OPA - Sal`, ID 39474) because MySQL runs on Sal's laptop. MySQL 8 may need public key retrieval allowed in the connection settings (same error hit in DBeaver). Verify which field exposes this if a test query fails. Do not create another MySQL connection. |
| `Microsoft Entra ID` (ID 19333274) | Custom connector: Microsoft Entra ID (Azure Active Directory) | **Already exists, status "lost" at last check** | Do not create a new one. Re-check status. Needs Graph `User.ReadWrite.All` (create/update users). Check the custom connector's real actions before wiring (no native Graph connector is used). |
| `Badge Demo - HTTP (Bridgit mock)` | HTTP | **Create (after Gate 4)** | Calls the Bridgit mock endpoints exposed by API Platform (Section 4). Auth: the API Platform client credential (API key). Base URL is the API Platform collection URL. Sal enters the key in the connection himself. |
| Employment Hero | Connector TBC | **Verify** | See O3. Only needed for the write-back step. |
| Webhook trigger | Workato webhook | n/a | Generated when the recipe is saved. Sal needs the URL for the mock script. |

**On-Prem Agent:** confirm the agent is connected before relying on the MySQL connection. If the connection test fails, stop and tell Sal; do not proceed to Section 4.

---

## 3. Data tables (Workato Data Tables)

Create both in the `Data Tables` subfolder of Badge - Demo. Verify column types when creating. Uniqueness: see A.2.

### 3.1 `badge_identity_map`: cross-system matching keys

The Employment Hero employee ID is system-generated and cannot be controlled, so this table is the source of truth for "which Entra user and which Bridgit person is this employee".

| Column | Type | Notes |
|---|---|---|
| `eh_employee_id` | string, **unique** | Employment Hero `data.id` (UUID). Primary lookup key |
| `entra_user_id` | string | Entra object ID (GUID) returned by Graph on create |
| `entra_upn` | string | userPrincipalName created |
| `bridgit_person_id` | integer | Bridgit person `id` |
| `email` | string | Work email written back to Employment Hero |
| `status` | string | `active` / `terminated` / `error` |
| `last_event` | string | Last EH event processed, e.g. `employee_created` |

Workato record created/updated timestamps give the audit trail. Do not add redundant timestamp columns unless Workato does not provide them.

### 3.2 `badge_bridgit_field_map`: Bridgit field name to field ID

Bridgit writes custom field values by **numeric field ID**, not by name, and IDs differ per Bridgit account. This table caches the mapping so recipes never hard-code IDs.

| Column | Type | Notes |
|---|---|---|
| `source_attribute` | string, **unique** | Logical name in our recipe, e.g. `eh_employee_id`, `entra_object_id`, `cost_rate`, `home_address` |
| `bridgit_field_name` | string | Bridgit display name |
| `bridgit_field_id` | integer | Bridgit numeric field ID |
| `bridgit_field_type` | string | `Text`, `Currency`, etc. |

**Seed rows** (match the rows already in MySQL table `person_field_defs`):

| source_attribute | bridgit_field_name | bridgit_field_id | bridgit_field_type |
|---|---|---|---|
| `eh_employee_id` | Employment Hero ID | 1001 | Text |
| `entra_object_id` | Entra Object ID | 1002 | Text |
| `cost_rate` | Cost Rate (hr) | 1003 | Currency |
| `home_address` | Home Address | 1004 | Text |

---

## 4. Mock Bridgit API (API Platform over MySQL)

The mock Bridgit is **Workato recipes performing CRUD on MySQL**, exposed through **API Platform**. This gives the gateway demo (requirement 2) and keeps the sync recipe calling a contract that matches the real Bridgit Bench API, so the base URL can be swapped later.

### 4.1 MySQL tables (already created, do not recreate)

Database `bridgit_mock`, created from `bridgit_mock_schema.sql` and verified by Sal in DBeaver:

- `person_field_defs(id, name, type, is_required, is_system)`, seeded with 1001 to 1004
- `persons(id AUTO_INCREMENT, external_id UNIQUE, name, title, email, hire_date, termination_date, is_active, created_at, updated_at)`
- `person_field_values(person_id, field_id, value)`, primary key `(person_id, field_id)`

### 4.2 API Platform collection: `Bridgit Bench Mock v1`

Endpoint shapes copy the real Bridgit Bench API (base path `/rp/api/v1`). One recipe per endpoint, each using the MySQL connection.

| Method + path | Recipe behaviour |
|---|---|
| `GET /accounts/{accountId}/person-fields` | `SELECT` all rows from `person_field_defs`. Return array of `{id, name, type, isRequired, isSystem}` |
| `POST /accounts/{accountId}/persons` | Insert into `persons` (`name`, `title`, `email`, `hireDate`, optional `externalId`). Return the created person incl. new `id`. HTTP 201 |
| `GET /accounts/{accountId}/persons/{personId}` | Select by id. 404 if missing |
| `PATCH /accounts/{accountId}/persons/{personId}` | Update only fields present in the request (`name`, `title`, `email`, `hireDate`, `terminationDate`). Return updated person |
| `GET /accounts/{accountId}/external/persons/{externalId}` | Select by `external_id`. **Return 404 when not found.** That 404 is the signal "no Bridgit record yet, create one" |
| `POST /accounts/{accountId}/persons/{personId}/external-id` | Body `{ "externalId": "..." }`. Update `persons.external_id`. Return 400 if already in use on another person |
| `POST /accounts/{accountId}/persons/{personId}/field-values` | Body `[ { "fieldId": 1001, "values": ["..."] } ]`. Upsert into `person_field_values` (`ON DUPLICATE KEY UPDATE` or select-then-insert/update). Return the person's stored values |

Person JSON shape returned everywhere: `id, externalId, name, title, email, hireDate, terminationDate, isActive`.

Error shape (copy Bridgit's): `{ "errors": [ { "errorType", "description", "field", "values" } ], "title", "status", "instance", "requestUid" }`.

### 4.3 Gateway policy to demonstrate

- Auth: API key (client + key) on the collection. Note: real Bridgit uses `POST /auth/signin` then a bearer token; the mock uses gateway auth instead. This is a deliberate simplification.
- Rate limiting and/or quotas on the collection (verify the options available in this workspace, via devapi).
- Auto-generated API documentation (the collection's Swagger/OpenAPI docs) for Sal to show.
- Create one client application for the demo and one key (via devapi). Sal must retrieve the key himself; do not print it.

### 4.4 Smoke tests (run after building, before Section 5)

1. `GET person-fields` returns four rows.
2. `POST persons` with `externalId: "TEST-001"` returns 201 and an `id`.
3. `GET external/persons/TEST-001` returns that person.
4. `GET external/persons/DOES-NOT-EXIST` returns 404.
5. `POST persons/{id}/field-values` with fieldId 1001, then confirm the row in `person_field_values`.
6. `PATCH persons/{id}` changes the email.
7. Delete the `TEST-001` rows afterwards (ask Sal first).

---

## 5. Recipes: Employment Hero to Entra ID to Bridgit

### 5.1 `EH employee created -> Entra + Bridgit`

**Trigger:** webhook (HTTP). Receives Employment Hero's `employee_created` event. Payload: Section 7.

**Steps:**

1. **Parse** the webhook body. Key inputs: `event`, `data.id`, `data.first_name`, `data.last_name`, `data.known_as`, `data.job_title`, `data.start_date`, `data.country`, `data.personal_mobile_number`, `data.account_email`.
2. **Guard:** if `event` is not `employee_created`, stop cleanly.
3. **Idempotency check:** look up `badge_identity_map` by `eh_employee_id = data.id`. If a row exists with status `active`, stop (webhooks can retry up to 3 times, so duplicates are expected).
4. **Build identity values:**
   - `displayName` = first + last name
   - `mailNickname` and `userPrincipalName` = generated from name + tenant domain (domain: see O2). Avoid characters Graph disallows in UPN.
   - `usageLocation` = `data.country` (AU) if licensing is in scope later.
5. **Create Entra user** via the existing Entra connection. Graph `POST /users` requires `accountEnabled`, `displayName`, `mailNickname`, `userPrincipalName`, `passwordProfile` (with `forceChangePasswordNextSignIn: true`). Generate the initial password in the recipe (formula) and never store or log it. Consider also setting Graph `employeeId` to the EH id as a second breadcrumb (verify it is available on the connector).
6. **Write back work email to Employment Hero** (O3). Uses the UPN or mail created in step 5.
7. **Bridgit: check then create**, via the HTTP connection to the mock API:
   1. `GET /external/persons/{data.id}`
   2. If 404 -> `POST /persons` (name, title = `job_title`, email, hireDate = `start_date`, externalId = `data.id`)
   3. If 200 -> use the returned person and `PATCH` instead
   4. Do **not** treat a 404 here as a job failure; configure the step so 404 is handled as a branch.
8. **Set Bridgit custom fields:** look up `badge_bridgit_field_map` for `eh_employee_id` and `entra_object_id`, then `POST /persons/{id}/field-values` with the looked-up numeric IDs (never hard-coded).
9. **Write the mapping:** create (or update) the `badge_identity_map` row: `eh_employee_id`, `entra_user_id`, `entra_upn`, `bridgit_person_id`, `email`, `status = active`, `last_event = employee_created`.
10. **Error handling:** wrap steps 5 to 9 in a monitor/error block. On failure, upsert the `badge_identity_map` row with `status = error` and whatever IDs were obtained so far, so a retry resumes rather than duplicating. Stop the job with a clear message. No real notification channel is specified; leave a placeholder step and flag it (O4).

### 5.2 `EH employee updated -> Entra + Bridgit`

**Trigger:** webhook for `employee_updated` (same webhook URL pattern; confirm whether to share the trigger with 5.1 or keep separate, O5).

1. Look up `badge_identity_map` by `data.id`.
2. No row -> do not create. Log and stop (or route to 5.1 logic; ask Sal, O5).
3. Row found -> `PATCH` Entra user `{entra_user_id}` (displayName, jobTitle, mobilePhone as applicable) using the stored ID, not a search by name.
4. `PATCH /persons/{bridgit_person_id}` on the Bridgit mock (name, title, email).
5. Update `badge_identity_map` (`last_event = employee_updated`).

This is the answer to Badge's matching-key question: the update recipe never searches by name or email; it resolves everything from the stored IDs.

### 5.3 `Bridgit field map refresh` (utility)

Manual or scheduled. Calls `GET /person-fields` on the mock API and upserts each row into `badge_bridgit_field_map` by `bridgit_field_name`. Shows how the mapping table stays current when Bridgit admins add fields. Keep `source_attribute` values that already exist; only add new rows with a placeholder `source_attribute` for a human to fill in.

---

## 6. Asset naming and location

- Project: `Badge - Demo` (project ID 18139092, folder ID 35630656). Already exists; use it.
- Subfolders (create via devapi, check they do not already exist): `API - Bridgit Mock`, `Recipes - HR Sync`, `Data Tables`.
- Recipe names exactly as in Section 5 headings. Prefix API recipes with `Bridgit Mock -`, e.g. `Bridgit Mock - GET person by external id`.

---

## 7. Employment Hero webhook mock (outside Workato)

Employment Hero's own webhooks need a Platinum subscription, so the demo fires a replica of a real `employee_created` event at the recipe's webhook URL.

### 7.1 Sample payload

Matches the `employee_created` schema in Employment Hero's developer docs. `id` is the system-generated UUID.

```json
{
  "event": "employee_created",
  "data": {
    "id": "f5e41ec5-b85d-486a-9bd0-ef9b04284c6e",
    "gender": "male",
    "country": "AU",
    "known_as": "Jordan",
    "job_title": "Site Supervisor",
    "last_name": "Match",
    "first_name": "Jordan",
    "middle_name": "",
    "avatar_url": "/avatar.svg",
    "start_date": "2026-10-12",
    "external_id": "",
    "nationality": "Australia",
    "account_email": "jordan.match.personal@example.com",
    "date_of_birth": "1988-04-21",
    "personal_mobile_number": "+61400000000"
  }
}
```

Use a new `id` for every repeat run, otherwise the idempotency check (5.1 step 3) will stop the run. That behaviour is itself worth demoing: send the same payload twice and show the second run stop cleanly.

### 7.2 Firing script (for Sal to run locally)

Real Employment Hero requests carry `X-EmploymentHero-Signature` and `X-EmploymentHero-Timestamp`. The signature is HMAC-SHA256 over `"<timestamp>.<raw json body>"`, keyed with the base64-decoded webhook secret, output base64-encoded. The script reproduces that so the recipe can optionally demonstrate signature verification.

```bash
#!/usr/bin/env bash
# usage: WEBHOOK_URL=... SECRET_B64=... ./fire_eh_webhook.sh payload.json
set -euo pipefail
PAYLOAD_FILE="${1:-payload.json}"
TS="$(date +%s)"
BODY="$(cat "$PAYLOAD_FILE")"

SIG="$(printf '%s.%s' "$TS" "$BODY" \
  | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$(printf '%s' "$SECRET_B64" | base64 -d | xxd -p -c 256)" -binary \
  | base64)"

curl -sS -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-EmploymentHero-Timestamp: $TS" \
  -H "X-EmploymentHero-Signature: $SIG" \
  --data-binary "$BODY" \
  -w "\nHTTP %{http_code}\n"
```

Claude Code: do not build signature verification into the recipe unless Sal asks (O6). If he does, note that a mock secret is needed and that verification needs the raw body, so check how the webhook trigger exposes it.

---

## 8. Test plan (end to end)

1. Section 4.4 smoke tests pass.
2. Fire the 7.1 payload with a fresh `id`. Expect: one new Entra user (UPN as generated), one `persons` row with `external_id` = the EH id, two rows in `person_field_values` (1001, 1002), one `badge_identity_map` row with all three IDs and `status = active`.
3. Fire the same payload again. Expect: no duplicates; run stops at the idempotency check.
4. Fire an `employee_updated` payload (same `data.id`, changed `job_title`). Expect: Entra job title and Bridgit person title updated, found via stored IDs only.
5. Fire an `employee_updated` for an unknown `id`. Expect: handled per O5, no records created unintentionally.
6. Force a failure (for example an invalid UPN) and confirm the `badge_identity_map` row shows `status = error` and a retry does not duplicate.
7. Clean up: delete the test Entra users and test MySQL / data table rows. **Ask Sal first.**

---

## 9. Build order (confirm with Sal at each gate)

1. **Discovery: DONE** (see Section A). Re-verify quickly only.
2. **Connections and folders:** confirm devapi tools loaded; create the three subfolders; confirm the MySQL (OPA) and Entra connections; create the HTTP connection after Gate 4.
3. **Data tables:** create and seed both (Section 3).
4. **Mock Bridgit API:** build the seven endpoint recipes, create and publish the API Platform collection, client and key (devapi), run 4.4.
5. **Recipe 5.3** (field map refresh), then **5.1** (create), then **5.2** (update).
6. **Hand over:** give Sal the webhook URL(s), the API docs URL and the collection base URL. He generates or retrieves the API key himself.

---

## 10. Open items (ask Sal; do not assume)

| # | Question | Why it matters |
|---|---|---|
| O1 | Requirement 1 is "in-house apps with standard web APIs on the internal network". In this design the mock API is hosted by Workato, so the On-Prem Agent is exercised via MySQL, not via the HTTP connector. To demo the HTTP connector through the agent, a real local HTTP service is needed. Options: (a) accept MySQL-via-agent as the agent demo; (b) Sal runs a small local API and we add an HTTP-via-agent connection and one recipe. | Decides whether a second demo asset is needed |
| O2 | Tenant verified domain for generated UPNs | Graph requires the UPN domain to be a verified tenant domain |
| O3 | Employment Hero: is there a Workato connector, and which writable field and endpoint handles the email write-back? Not verified at time of writing. Check Employment Hero's API reference. If there is no clean write path, stub this step and say so | The write-back step cannot be specified without it |
| O4 | Failure notification target (Slack/email/none) | Placeholder only until decided |
| O5 | Shared or separate webhook trigger for created vs updated; behaviour when an update arrives for an unknown employee | Affects recipe structure |
| O6 | Include HMAC signature verification in the recipe? | Extra demo value vs extra build and a mock secret |
| O7 | Licence assignment in Entra (needs `usageLocation` and a licence SKU)? Assumed out of scope | Scope |
| O8 | Naming/folder conventions: resolved for now (Section 6 layout, confirmed by Sal) | Avoid duplicates and sprawl |

---

## Sources

- Employment Hero developer docs, Webhook: https://developer.employmenthero.com/api-references/webhook (event list, `employee_created` schema, signature headers and verification method; webhooks need a Platinum subscription)
- Bridgit Bench developer docs: https://developers.gobridgit.com/docs/api-overview and https://developers.gobridgit.com/llms.txt (base path `/rp/api/v1`, `/auth/signin`, persons, person-fields, field-values, `external/persons/{externalId}`, set external ID, error shape)
- Microsoft Graph, Create user: https://learn.microsoft.com/en-us/graph/api/user-post-users?view=graph-rest-1.0 (required properties, `User.ReadWrite.All` permission)
- Workato workspace discovery via AIRO MCP (`project_list`, `folder_list`, `data_table_list`, `recipe_list`, `recipe_builder_list_connections`, `on_prem_group_list`, `on_prem_group_get`), run 2026-09-30 (Section A state)
- Workato connector behaviour (MySQL, HTTP, API Platform, Data Tables, Entra, Employment Hero): **not verified in this document**; verify against the workspace at build time.
