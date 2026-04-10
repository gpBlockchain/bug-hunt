# Recon: Codebase Reconnaissance

## Overview

Analyze the project once — after `risk-map.json` is generated — to identify the tech stack, trust boundaries, and high-risk entry points. Results are written to `recon-report.json` and used by the loop to focus security-oriented tests on the most exposed surfaces.

## When to Run

Run once during Setup, immediately after Step 7 (Code Risk Analysis). If `recon-report.json` already exists and the source tree has not changed since it was generated, skip and reuse it.

## Execution Steps

### 1. Detect Tech Stack

Scan `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `requirements.txt`, `pom.xml`, and similar manifest files. Also scan `README.md` and top-level config files.

Record:
- **language** — primary language (`typescript`, `python`, `go`, `rust`, `java`, …)
- **framework** — web framework (`express`, `fastapi`, `gin`, `actix`, `spring`, …)
- **orm** — database layer (`prisma`, `sqlalchemy`, `gorm`, `diesel`, `hibernate`, …)
- **auth** — authentication mechanism (`jwt`, `oauth2`, `session`, `api-key`, `none`, …)
- **test_framework** — already known from `bug-hunt.toml`; record here for completeness

### 2. Identify Entry Points

Scan source files for publicly reachable surfaces. Look for:

| Pattern | Entry Point Type |
|---------|-----------------|
| HTTP route handlers (`app.get`, `router.post`, `@app.route`, `http.HandleFunc`) | `http` |
| WebSocket upgrades (`ws.on`, `websocket.accept`, `gorilla/websocket`) | `websocket` |
| Message queue consumers (`consumer.subscribe`, `channel.consume`, `@KafkaListener`) | `queue` |
| CLI argument parsing (`argparse`, `cobra`, `clap`, `argv`) | `cli` |
| Scheduled jobs / cron (`cron.schedule`, `@Scheduled`, `celery.task`) | `scheduled` |
| GraphQL resolvers (`@Resolver`, `makeExecutableSchema`) | `graphql` |

For each entry point record: `type`, `path` (file or directory), and `risk` (`high` / `medium` / `low`).

**Risk heuristics:**
- `high` — accepts unauthenticated input, performs writes, calls external services
- `medium` — authenticated but modifies state, or reads sensitive data
- `low` — authenticated read-only, internal-only

### 3. Map Trust Boundaries

Identify where trust level changes in the request flow:

- **public → authenticated**: middleware / decorators that enforce auth (e.g., `authMiddleware`, `@login_required`, `requireAuth`)
- **authenticated → admin**: role / permission checks (`isAdmin`, `hasRole("ADMIN")`, `require_permission`)
- **internal → external**: calls to third-party APIs, outbound HTTP, database writes

For each boundary record: `from` level, `to` level, and the `files` that enforce it.

### 4. Write recon-report.json

```json
{
  "tech_stack": {
    "language": "<language>",
    "framework": "<framework or null>",
    "orm": "<orm or null>",
    "auth": "<auth mechanism or null>",
    "test_framework": "<from bug-hunt.toml>"
  },
  "entry_points": [
    { "type": "http",      "path": "src/routes/",        "risk": "high"   },
    { "type": "websocket", "path": "src/ws/",            "risk": "medium" },
    { "type": "queue",     "path": "src/consumers/",     "risk": "medium" },
    { "type": "cli",       "path": "src/cli.ts",         "risk": "low"    }
  ],
  "trust_boundaries": [
    {
      "from":  "public",
      "to":    "authenticated",
      "files": ["src/middleware/auth.ts"]
    },
    {
      "from":  "authenticated",
      "to":    "admin",
      "files": ["src/middleware/requireAdmin.ts"]
    }
  ],
  "generated_at": "<YYYY-MM-DD>"
}
```

Commit `recon-report.json` to git:

```bash
git add recon-report.json && git commit -m "recon: generate recon-report.json"
```

### 5. Show Summary

Print a brief summary for the user:

```
Recon complete:
  Language:     typescript
  Framework:    express
  Auth:         jwt
  Entry points: 3 high-risk, 2 medium-risk, 1 low-risk
  Boundaries:   public→authenticated (src/middleware/auth.ts)
```

## How the Loop Uses recon-report.json

When writing tests, the loop reads `recon-report.json` and applies the following priority boosts:

- **High-risk entry points** → prefer `injection`, `auth-bypass`, `idor`, `input-overflow` test types for files under those paths
- **Trust boundaries** → prefer `auth-bypass` tests for files listed in `trust_boundaries`
- **No auth detected** (`auth: null`) → add a note to `bug-hunt-context.md` flagging missing authentication as a potential systemic risk

These boosts are applied as an additive `+0.2` to the composite score for security test types when the target function lives in a high-risk entry point path.
