---
title: "LifeLogger: Building a Personal Email Memory System with Docker, Maildir, and SQLite"
date: 2026-06-16 22:30:00
tags:
  - DIY
  - Python
  - Docker
  - Email
  - SQLite
  - Personal Knowledge Base
categories:
  - 03 DIY
index_img: /images/2026/diy/lifelogger-email-memory-hero.png
banner_img: /images/2026/diy/lifelogger-email-memory-hero.png
---

LifeLogger started from a very ordinary personal need: I wanted a durable way to keep my own email history, turn it into a timeline, and eventually make it searchable by local AI tools.

Email is one of the longest-running personal data streams in my life. It contains travel bookings, account changes, job applications, family records, receipts, newsletters, old conversations, and many small traces that are easy to forget. But most mail systems are designed for daily inbox use, not for long-term personal memory.

So I built a small Dockerized service to collect mail through IMAP, preserve raw messages, write structured timeline records into SQLite, and prepare the foundation for a future local knowledge base.

<!-- more -->

## The Goal

The current goal is not to build another mail client.

The goal is to build a personal data foundation:

```text
Mail providers
  -> IMAP sync
  -> raw Maildir archive
  -> SQLite timeline
  -> sidecar metadata
  -> attachment deduplication
  -> local vector database
  -> AI-assisted retrieval
```

The important idea is separation:

- raw messages should be preserved;
- derived metadata should be rebuildable;
- attachments should be deduplicated;
- vectorization should be incremental;
- every processing stage should be safe to rerun.

In other words, LifeLogger should behave more like a personal archive pipeline than a one-off script.

## Current Version

The current implementation is a Python service packaged by Docker Compose.

It contains:

- a Flask management API and small web UI;
- IMAP mail fetching;
- Maildir-based raw message storage;
- SQLite timeline records;
- provider-specific IMAP handling;
- scheduled per-account sync jobs;
- basic duplicate hiding and review;
- remote deletion support for selected messages.

The service runs as a simple container:

```text
lifelogger
  -> Python Flask service
  -> mounted data directory
  -> mounted source directory
  -> SQLite database
  -> Maildir archive
```

The current dependency list is intentionally small:

```text
Flask
schedule
PySocks
```

That is deliberate. I want the system to stay inspectable and easy to repair.

## Progress Update: June 18, 2026

The project moved from a prototype mail fetcher into a more complete local memory pipeline.

The current data scale is already large enough to expose real engineering problems instead of toy examples:

| Area | Current progress |
| --- | ---: |
| Stable mail records | 79,615 |
| Duplicate mail records marked for review | 43,263 |
| Markdown sidecars generated | 52,984 |
| Attachments indexed | 16,969 |
| Attachments uploaded to MinIO | 16,964 |
| Raw attachment bytes | 9.38 GB |
| Deduplicated MinIO objects | 9,265 |
| Deduplicated object bytes | 6.09 GB |
| Successful attachment text extracts | 6,974 |
| Extracted attachment text | 41.5 million characters |
| Knowledge chunks | 577,434 |
| Knowledge chunk content | 845.9 million characters |

This changed my view of the project.

At the beginning, the main question was whether I could reliably fetch email and avoid obvious duplicate downloads. Now the useful question is how to maintain a local personal corpus over time: how to preserve raw evidence, rebuild derived views, avoid repeated storage, and keep search results traceable back to the original mail or attachment.

Several pieces are now in place:

- `mail_messages` has become the stable email entity table.
- Maildir scanning can rebuild message records from the raw archive.
- Sidecar JSON and Markdown files are generated for mail bodies.
- Attachment metadata is indexed with SHA-256 hashes.
- Attachment binaries are uploaded into MinIO with content-addressed object keys.
- Deterministic extractors handle PDFs, modern Office files, plain text, HTML, and common structured files.
- A LibreOffice headless pass adds useful coverage for legacy `.doc`, `.xls`, `.ppt`, and `.rtf` files.
- `knowledge_chunks` now stores searchable chunks from both mail bodies and extracted attachment text.
- The Web UI has grown beyond account sync into message review, attachment extract viewing, archive import, and local knowledge search.

The important architectural boundary is also clearer now.

Sidecar files, SQLite, and MinIO are enough to support parsed metadata, Markdown bodies, deduplicated attachment storage, extracted text, and local search. They are not yet a full replacement for raw Maildir, because they do not preserve every original MIME boundary, transfer encoding detail, and header exactly as received.

So raw Maildir remains the source of truth. Everything else is a rebuildable working layer.

## Why Maildir

The first design decision was to preserve raw emails in Maildir format.

Maildir is boring in a good way.

Each message is stored as a file. It is easy to inspect, back up, copy, rebuild, and migrate. A future parser can always go back to the original message if the derived metadata is wrong.

This is the same pattern I like in media systems such as Immich: keep original files, then build sidecar metadata and derived views around them.

For email, that means:

```text
Raw layer:
  Maildir message files

Derived layer:
  SQLite rows
  sidecar JSON
  attachment metadata
  text chunks
  vector sync state
```

The raw layer should be durable.

The derived layer should be reproducible.

## The First Real Problem: Duplicate Downloads

The first painful issue was duplication.

The old sync logic mainly relied on local UID cache files under the Maildir directory. That worked only as long as the cache stayed perfectly aligned with the remote mailbox and the local archive.

In practice, after Docker restarts and repeated sync jobs, duplicate downloads could happen.

The SQLite timeline already had signs of the problem:

- tens of thousands of hidden mail rows;
- many duplicate fingerprints;
- many duplicate message IDs.

The fix was to move deduplication closer to the durable database layer.

Instead of downloading the full body immediately, the fetcher now does a header-first check:

```text
FETCH BODY.PEEK[HEADER]
  -> parse Message-ID
  -> check SQLite by source + message_id
  -> if it exists, update UID cache and skip body download
  -> if it is new, fetch RFC822 and store it
```

This small change matters.

It avoids unnecessary full-body downloads, avoids writing duplicate Maildir files, and makes the database the first durable dedupe gate.

The supporting index is simple:

```sql
CREATE INDEX IF NOT EXISTS idx_source_msg_id
ON timeline(source, message_id);
```

It is not perfect deduplication yet, but it is a much better foundation.

## Provider Isolation

Another lesson was that email providers are similar only at the surface.

They all say "IMAP", but details differ:

- hostnames;
- ports;
- folder naming;
- IMAP ID handshake behavior;
- proxy requirements;
- deletion behavior;
- authentication assumptions.

So I split provider behavior into classes:

```text
MailProvider
  -> NetEase163Provider
  -> SohuProvider
  -> OutlookProvider
  -> GmailProvider
```

This keeps provider-specific behavior out of the generic fetcher.

The fetcher should know how to sync a mailbox.

The provider should know how to connect, authenticate, select folders, and handle special protocol behavior.

That boundary made the code easier to reason about.

## Refactoring the Service

The original service had too much logic in one place, so I refactored it into smaller modules.

The current structure is:

```text
main.py
  Application bootstrap

config.py
  Runtime paths and timeout settings

database.py
  SQLite schema, insert, duplicate checks, visibility toggles

mail_parser.py
  Header decoding, date parsing, folder-name encoding, metadata extraction

providers.py
  Provider classes and registry

mail_fetcher.py
  IMAP sync, Maildir persistence, header-first dedupe, remote deletion

scheduler.py
  Account loading, startup sync, recurring jobs, per-account locks

web_app.py
  Flask routes and API handlers
```

The entry point is now thin:

```python
def create_runtime():
    parser = EmailParser()
    db = TimelineDatabase(DB_PATH)
    providers = ProviderRegistry(parser)
    fetcher = MailFetcher(db, parser, providers, MAIL_BASE_DIR)
    scheduler = AccountScheduler(CONFIG_PATH, fetcher)
    web = WebApp(db, scheduler, fetcher)
    return db, scheduler, web.app
```

This is the kind of boring refactor that pays back quickly.

Once the modules were separated, it became much easier to plan sidecars, attachment extraction, and vectorization.

## Sidecar Architecture

The next version introduced sidecar files.

Each email should have a derived JSON representation:

```json
{
  "sidecar_version": 1,
  "provider": "sohu",
  "account": "example@sohu.com",
  "folder": "INBOX",
  "uid": "12345",
  "message_id": "<message@example.com>",
  "subject": "Example subject",
  "from": "Sender <sender@example.com>",
  "date": "2026-06-16T12:00:00+08:00",
  "body": {
    "text": "",
    "html": "",
    "normalized_text_hash": ""
  },
  "attachments": [],
  "parse_status": "ok"
}
```

The sidecar becomes the stable bridge between raw Maildir and future AI ingestion.

It also makes parser upgrades safer. If the parser improves, sidecars can be regenerated without touching the raw archive.

## Attachment Storage

Attachments are now extracted, hashed, and deduplicated by content.

The working order is:

```text
Maildir
  -> sidecar metadata
  -> attachment metadata and SHA-256
  -> MinIO object storage
  -> AnythingLLM vectorization
```

MinIO stores attachment binaries using content-addressed keys:

```text
attachments/sha256/ab/cd/<sha256>
```

SQLite should store only metadata and object references.

This avoids storing the same attachment many times when it appears in multiple emails.

## AI Retrieval Is the Long-Term Payoff

The long-term direction is to connect LifeLogger with a local vector database, probably through AnythingLLM.

But raw email files should not be pushed directly into a vector store.

The better pipeline is:

```text
sidecar JSON
  -> normalized document text
  -> chunks
  -> metadata-rich upload
  -> vector sync state
```

The vector layer should know where each chunk came from:

- provider;
- account;
- folder;
- message ID;
- sent date;
- attachment ID;
- parse version.

That metadata is important. A personal knowledge base without provenance quickly becomes a pile of plausible but untraceable answers.

For now, LifeLogger has a local keyword search layer on top of `knowledge_chunks`.

That is intentionally modest. It gives me a way to inspect the corpus, check provenance, and test chunk quality before adding embeddings and semantic search.

## What I Like About This Project

LifeLogger is not fancy.

That is exactly why I like it.

It uses old, understandable building blocks:

- IMAP;
- Maildir;
- SQLite;
- Flask;
- Docker Compose;
- local files;
- incremental jobs.

But the design direction is modern:

- preserve raw sources;
- build reproducible derived metadata;
- deduplicate by stable keys;
- keep processing idempotent;
- prepare for local AI retrieval;
- keep user data under local control.

This is a good DIY pattern for personal infrastructure.

Not every personal tool needs to begin with a large framework.

Sometimes the right start is a small service that stores raw data carefully, keeps metadata honest, and leaves enough room for future intelligence.

## Next Step

The next useful milestone is to move from local keyword search to controlled semantic retrieval.

That means:

- adding `vector_sync_state`;
- deciding whether SQLite FTS5 should sit before AnythingLLM;
- making chunk regeneration incremental by source version and extractor version;
- uploading chunks or source documents with retryable sync state;
- keeping OCR and AI classification as later enrichment stages;
- preserving provenance as a first-class part of every answer.

For now, LifeLogger is a small local machine for memory.

That feels like a good place to start.
