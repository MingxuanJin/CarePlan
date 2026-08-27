# Care Plan Generator

This is an intentionally tiny MVP for generating a pharmacy care plan with an LLM.

## Current MVP

- FastAPI backend
- Plain HTML, CSS, and JavaScript frontend
- One synchronous API call that waits for the LLM response
- In-memory Python dictionary for generated care plans
- No database
- No tests
- No websocket
- No queue or worker
- No Controller-Service-Repository split
- No warning, error, or boundary-condition handling yet

## Run with Docker

```bash
cp .env.example .env
# edit .env and set GEMINI_API_KEY
docker compose up --build
```

Then open:

```text
http://localhost:8000
```

Optional model override in `.env`:

```text
GEMINI_MODEL=gemini-2.0-flash
```

## API

```text
POST /api/careplans
```

The frontend sends the form data as JSON, waits while the LLM generates the care plan, then displays the response on the page.
