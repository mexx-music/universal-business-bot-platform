# Universal Business Bot Platform

Universal Business Bot Platform is a Flutter-based internal MVP for managing company workspaces, structured business knowledge, and safe support-bot workflows.

## Idea

The project explores a lightweight platform layer for three connected areas:

- Company workspaces with structured knowledge for products, services, FAQs, processes, and source references
- Bot testing and safe support workflows based on local knowledge entries
- Human review and escalation for unanswered, risky, or blocked bot interactions

## Current MVP Scope

The current app includes:

- Entry page and company selection for the local MVP
- Dashboard with knowledge, review, redirect, and audit metrics
- Company profile and product/service overview
- Audit checklist for bot-readiness signals
- Knowledge Base with categories, risk levels, sources, and manual entries
- Bot Test screen using local keyword matching only
- Human Review workflow for open, reviewed, and closed bot logs
- Sources overview grouped by knowledge-entry origin
- Multi-company support with isolated local mock data per workspace
- German and English localization structure
- Local demo data for HB Cure and SchnurrPurr

## Not Included

This MVP intentionally does not include:

- User login or authentication
- Real multi-tenant backend
- Cloud sync or production database
- Real AI model/API integration
- Automated document ingestion
- Production-grade compliance or medical/legal advice handling

## Tech Stack

- Flutter
- Dart
- Material 3
- go_router
- Flutter localizations / ARB files
- Local in-memory mock state

## Status

Internal MVP / work in progress.
