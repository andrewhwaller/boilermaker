---
date: 2026-03-27
topic: carrel-research-assistant
---

# Carrel: LLM-Powered Zotero Research Assistant

## Problem Frame

Zotero is an excellent tool for collecting, organizing, and citing research materials. What it lacks is the ability to reason across a library — to answer questions like "what does my collection say about topic X?" or "who are the key authors I'm missing on this subject?" A researcher with thousands of items cannot practically re-read or manually cross-reference their entire library. Carrel fills this gap by providing an AI layer on top of Zotero that enables semantic search, research Q&A with citations, and citation-based literature discovery.

Carrel is a personal tool for a single researcher working primarily in humanities and social sciences. It complements Zotero rather than replacing it — the user continues to manage their library in Zotero while using Carrel for AI-powered interrogation of that library.

## Requirements

Requirements are organized by priority. **P0** items form the MVP core. **P1** items are important but can follow. **P2** items are deferred to a future phase.

### P0 — MVP Core

#### Zotero Library Sync

- R1. Sync items from the user's Zotero library via the Zotero Web API into Carrel's database
- R2. Store item metadata (title, authors, abstract, tags, collections, publication date, item type, DOI, URL)
- R3. Support incremental sync — detect new, modified, and deleted items since last sync
- R4. Handle a library of 2,000–10,000 items with progress tracking during initial sync
- R5. Preserve Zotero collection hierarchy for context during search and Q&A
- R36. Download PDF attachments via the Zotero Web API (not local file access). Zotero API key must be read-only (minimum privilege)
- R43. Handle external API failures (rate limits, timeouts, transient errors) with automatic retry and partial progress preservation — never require re-processing successfully completed items due to a mid-batch failure

#### Full-Text Extraction

- R6. Extract full text from PDF attachments associated with Zotero items
- R7. Associate extracted text with its parent Zotero item
- R8. Handle extraction failures gracefully (corrupted PDFs, scanned images without OCR, missing attachments) — log failures and continue processing remaining items

#### Embedding and Vector Storage

- R9. Generate vector embeddings for all synced content (metadata + full text)
- R10. Chunk full-text documents into semantically meaningful segments for embedding
- R11. Store embeddings using sqlite-vec within the existing SQLite database
- R13. Track embedding status per item (not embedded, embedded, needs re-embedding) and store the model identifier with each embedding so re-embedding is possible later

#### Semantic Search

- R14. Accept natural language queries and return semantically relevant items from the library
- R15. Rank results by relevance and show the matched text excerpt
- R16. Return sufficient context (title, authors, relevant excerpt) to evaluate results without leaving Carrel

#### Research Q&A

- R18. Accept research questions and provide synthesized answers grounded in library content
- R19. Cite specific items (and ideally specific passages) in answers
- R20. Support follow-up questions within a conversation thread
- R21. Agent prompts should instruct the model to attribute claims to specific library items and flag when reasoning beyond retrieved content (design heuristic, not a hard guarantee — LLMs cannot reliably self-report source attribution)
- R22. Use OpenRouter as the LLM gateway for provider-agnostic model selection
- R44. LLM responses must stream to the UI token-by-token — the OpenRouter integration must use SSE/streaming and the frontend must handle incremental rendering via Turbo Streams or ActionCable
- R45. Manage context window limits gracefully — handle retrieval volume vs. available context, and manage conversation history as threads grow longer (summarization, truncation, or sliding window)

#### Conversation Management

- R23. Persist conversation threads with full message history, scoped to the owning user/account
- R24. Allow the user to return to and continue previous research threads
- R25. Title or label threads for easy identification
- R46. Allow the user to delete conversation threads

#### Processing Pipeline

- R37. Pipeline stages (sync → extract text → generate embeddings) chain automatically — triggering sync runs the full pipeline through to embeddings. Manual trigger via R34 initiates the chain.

#### User Interface

- R30. Chat-first interface with a dense, keyboard-driven REPL-style interaction model optimized for a power user
- R31. Do not duplicate Zotero's library management features (browsing, editing, organizing)
- R32. Link results back to Zotero items where possible (deep links or item keys)
- R34. Provide a way to trigger the full pipeline manually (sync + extract + embed)
- R40. Sidebar navigation with conversation thread list, pipeline status link, and settings
- R41. Agent-composed responses rendered as markdown — citation format determined by agent prompts, not hardcoded UI
- R42. Agent prompt design is a first-class concern — prompts should be crafted to produce well-cited, clearly-sourced research answers

#### Access Control

- R47. Disable or restrict user registration — single-user tool, no public sign-up (set `user_registration: false` in boilermaker.yml)
- R48. All new controllers must scope queries through `Current.account` — no unscoped access to ZoteroItems, Conversations, Embeddings, or search results

### P1 — Important Follow-ups

#### Processing Pipeline Automation

- R35. Run sync automatically on a periodic background schedule while the app is running
- R38. Pipeline dashboard showing processing status, progress, and any failures on a dedicated page
- R39. Initial bulk sync processes all items in one run with progress tracking (no manual prioritization needed)

#### Search Enhancements

- R17. Support filtering by collection, item type, date range, or tags (filters combine with AND logic)

### P2 — Future Phase

#### Citation Mining (Literature Discovery)

- R26. Extract references/bibliographies from full-text content in the library
- R27. Identify frequently-cited works that are not in the user's library
- R28. Present discovered works with citation context (which items cite them, how often)
- R29. Allow the user to explore citation networks starting from any item or topic

*Rationale for deferring: R26-R29 depend on reliably extracting bibliographies from academic PDFs — acknowledged as an unsolved technical problem. The core value proposition (search + Q&A) ships without citation mining. This should be prototyped and proven feasible before committing to it.*

## Success Criteria

- A user can ask a natural language question and begin receiving a streaming, well-cited answer drawn from their Zotero library within a few seconds (first token within ~3s, complete response within ~30s)
- Semantic search returns meaningfully different (better) results than keyword search in Zotero
- The system can sync and process a 5,000-item library with full-text extraction in a reasonable timeframe (hours, not days)
- Conversations persist and can be resumed across sessions

## Scope Boundaries

- **Not a Zotero replacement** — no item creation, editing, or organization features
- **Single user only** — no multi-user auth, sharing, or collaboration. New domain models (ZoteroItem, Conversation, Embedding, etc.) should be scoped to the user's single account for consistency with existing Boilermaker patterns. Registration should be restricted or disabled.
- **No external academic API integration** in MVP — no Semantic Scholar, OpenAlex, CrossRef, or web search
- **No PDF reader** — link to Zotero or the file system for reading
- **No annotation or note-taking** — use Zotero for that
- **Existing Boilermaker account system remains** but is not extended — single user can use existing auth

## Key Decisions

- **Zotero Web API over local SQLite**: Ensures durability of synced data and embeddings independent of local Zotero installation. The Carrel database becomes the working data store; Zotero cloud is the recovery source.
- **SQLite + sqlite-vec over PostgreSQL/pgvector**: Maintains alignment with Rails 8's SQLite-first philosophy. Appropriate for a single-user personal tool. Avoids adding infrastructure. Note: sqlite-vec uses virtual tables outside standard ActiveRecord patterns — planning must address custom adapter approach, migration strategy, and write contention (WAL mode, potentially separate SQLite file for vectors).
- **OpenRouter for LLM gateway**: Provider-agnostic model selection through a single API. Allows switching between Claude, GPT-4, Llama, etc. without code changes.
- **Chat-first UI, not library browser**: Carrel's value-add is AI reasoning, not collection management. Avoid duplicating what Zotero already does well.
- **Citation mining deferred to post-MVP**: Depends on unsolved bibliography extraction from heterogeneous academic PDFs. Core value ships without it.

## Trust Boundaries and Security

- **Credential storage**: Three API keys (Zotero, OpenRouter, OpenAI) require a defined storage mechanism — Rails credentials or encrypted database attributes. Keys must be filtered from logs via `filter_parameter_logging`.
- **Zotero API key**: Must be read-only. Carrel never writes to the Zotero library.
- **Data sent to LLM providers**: RAG Q&A sends chunks of library full-text to OpenRouter and downstream LLM providers. Users should understand what data leaves the system. OpenRouter's data retention and training policies should be documented.
- **Data at rest**: The SQLite database contains full-text research content, embeddings, conversation history, and potentially API keys. Consider filesystem-level encryption or encrypted SQLite for sensitive deployments.
- **PDF processing**: Downloads must validate URL scheme (HTTPS only), content-type, and file size limits. PDF parser should handle malformed input safely.
- **Rate limiting**: Chat and search endpoints proxy to paid external APIs. Basic rate limiting should prevent unbounded API spend from a compromised session or runaway client.
- **Prompt injection**: Library content (synced PDFs) and user queries both become part of LLM prompts. Treat all retrieved content as untrusted; separate system instructions from retrieved context with clear delimiters.
- **Streaming authentication**: SSE or ActionCable streaming endpoints must verify the user session — unauthenticated streaming channels are data exfiltration vectors.

## Dependencies / Assumptions

- User has a Zotero account with Web API access (read-only API key)
- Library items have PDF attachments for full-text extraction (some may not — handled gracefully)
- OpenRouter API key for LLM access
- OpenAI API key for embeddings (text-embedding-3)

## Outstanding Questions

### Resolved During Brainstorm

- [Affects R9] Embedding provider: **OpenAI text-embedding-3** (small or large variant to be determined during planning based on quality/cost tradeoff). Direct OpenAI API for embeddings, OpenRouter for chat completions.

### Deferred to Planning

- [Affects R10][Technical] What chunking strategy to use for full-text documents — fixed-size, sentence-based, semantic, or section-aware?
- [Affects R11][Needs research] sqlite-vec maturity and Rails integration patterns — virtual table creation, versioning, query abstraction for joining vector results with ActiveRecord models
- [Affects R11][Technical] Should vector storage use a separate SQLite file from the primary database to reduce write contention?
- [Affects R6][Needs research] Best Ruby library for PDF text extraction at scale (pdf-reader, poppler bindings, etc.)
- [Affects R1, R3][Needs research] Zotero Web API rate limits and pagination strategy for large library sync
- [Affects R22][Technical] How to integrate OpenRouter with Rails — direct HTTP, ruby client gem, or Active Agent pattern
- [Affects R14, R18][Technical] RAG retrieval strategy — how many chunks to retrieve, re-ranking approach, context window management
- [Affects R44][Technical] Whether Importmap-based JS setup supports the interactive chat UI needed (markdown rendering, streaming responses, keyboard shortcuts) or if a build step is needed
- [Affects R36][Needs research] Zotero Web API attachment download capability and storage tier limits — verify PDFs are accessible for the user's library
- [Affects Dependencies][Technical] Credential storage mechanism — Rails credentials vs. encrypted database attributes vs. environment variables
- [Affects R9][Cost] Estimated embedding cost for 5,000-item library with full text — note that chunking (R10) means each item produces many embeddings (20-100+ chunks per PDF), so actual cost is significantly higher than per-item estimates. Back-of-envelope: 5,000 items × ~50 chunks × ~500 tokens = ~125M tokens. text-embedding-3-small: ~$2.50; text-embedding-3-large: ~$16. These estimates assume average chunk counts; actual cost depends on chunking strategy.

## Next Steps

→ `/ce:plan` for structured implementation planning
