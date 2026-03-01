---
name: hourly
description: View today's auto-generated hourly activity reports.
---

# hourly

Display today's hourly activity reports generated automatically by the daemon.

## Steps

1. Resolve output directory (direct python mode):

```bash
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/.claude/cobrain}"
echo "$OUTPUT_DIR"
```

2. Build today's hourly file path and check existence:

```bash
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/.claude/cobrain}"
HOURLY_FILE="$OUTPUT_DIR/$(date +%Y%m%d)-hourly.md"
test -f "$HOURLY_FILE" && echo "exists" || echo "missing"
```

3. If the file does not exist or is empty, report:
   - "No hourly reports generated yet today. Reports are created automatically at each hour boundary when the daemon is running."
   - Stop here.

4. Read and display the full contents of the hourly file using the `Read` tool.

5. Present the content as-is — these are pre-generated summaries, no further analysis needed.
