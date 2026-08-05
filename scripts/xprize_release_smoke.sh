#!/usr/bin/env bash
set -euo pipefail

flutter test \
  test/release_candidate_configuration_test.dart \
  test/gemini_live_path_test.dart \
  test/knowledge_builder_screen_test.dart \
  test/grounded_answer_panel_test.dart \
  test/grounded_website_links_test.dart \
  test/operations_dashboard_screen_test.dart \
  test/knowledge_improvement_screen_test.dart \
  test/guided_demo_screen_test.dart \
  test/platform_entry_navigation_test.dart

deno test supabase/functions/tests/ai_generate_test.ts
