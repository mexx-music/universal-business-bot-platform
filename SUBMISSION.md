# OpenAI Build Week Submission Checklist

Use this file as the final pre-submit checklist for Devpost.

## Repository

- GitHub repository: `https://github.com/mexx-music/universal-business-bot-platform`
- Public reachability checked: GitHub returned HTTP 200 on July 18, 2026
- Main branch: `main`
- CI/CD: GitHub Actions builds Flutter web and deploys `build/web` to Cloudflare Pages
- Required before final submission: add or confirm the repository license

## Suggested Track

Work and Productivity.

Reason: the platform helps small and medium-sized businesses structure company knowledge, prioritize work, review support questions, and prepare safe automation.

## Demo Video Outline

Keep the video under three minutes.

1. Show the landing page and explain the digital company companion idea.
2. Open a demo company.
3. Show Dashboard, Project Status, and Next Best Actions.
4. Show Knowledge Base, Sources, and Audit.
5. Test the bot with a safe question and a risky or unknown question.
6. Show Human Review and convert a reviewed question into a Knowledge Entry.
7. Show Marketing Strategy, Business Strategy, and Business Intelligence.
8. Briefly explain how Codex and GPT-5.6 were used.

## Codex / GPT-5.6 Evidence

Devpost asks for clear evidence of Codex and GPT-5.6 usage.

Add to the Devpost submission:

- `/feedback` Codex Session ID from the primary build thread
- short explanation of where Codex accelerated the workflow
- short explanation of key product, architecture, and design decisions made during the build
- explanation of how GPT-5.6 was used during development or how it is integrated

Current repository note:

- Codex usage is documented in `README.md`.
- The MVP does not require a live OpenAI API key to run.
- Runtime recommendations are deterministic and local for reproducibility and safety.
- If the judges require runtime GPT-5.6 usage, add a small optional GPT-5.6-backed explanation endpoint or demo mode before final submission.

## Run Locally

```sh
flutter pub get
flutter gen-l10n
flutter run -d chrome
```

## Verify Before Submission

```sh
flutter gen-l10n
flutter analyze
flutter test
flutter build web --release
bash scripts/prepare_cloudflare_pages.sh
```

Optional backend checks:

```sh
.tools/supabase/supabase db reset
.tools/supabase/supabase test db
```

## Manual Devpost Fields To Prepare

- Project title
- Short tagline
- Public demo URL
- Public YouTube demo video URL
- GitHub repository URL
- `/feedback` Codex Session ID
- Track: Work and Productivity
- Team members
- License confirmation
