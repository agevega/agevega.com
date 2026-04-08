Register a new entry in the AI agent usage log at `tmp/costes.md`.

## Steps

1. Read `tmp/costes.md` to get the current table format and last entries.
2. Ask the user for:
   - **Task**: What was done this session (short description, include commit hash if applicable).
   - **Model**: Which model was used (e.g., Opus 4.6, Sonnet 4.6, Haiku 4.5).
   - **Duration**: Approximate session length (e.g., ~30min, ~1h).
3. Generate a new table row using today's date and time in `YYYY-MM-DD HH:MM` format.
4. Append the row to the end of the table in `tmp/costes.md`.
5. Show the updated table to the user for confirmation.
