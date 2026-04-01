#!/usr/bin/env bash
exec npx --global @browserbasehq/mcp \
  --browserbaseApiKey "$BROWSERBASE_API_KEY" \
  --browserbaseProjectId "$BROWSERBASE_PROJECT_ID"
