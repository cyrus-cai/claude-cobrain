---
name: today
description: Review and summarize today's cobrain memory entries.
---

# today

Generate an actionable daily insight briefing — not a logbook.

## Phase 1: Locate and Profile the Data

1. Resolve output directory (direct python mode):

```bash
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/.claude/cobrain}"
echo "$OUTPUT_DIR"
```

2. Build today's file path and check existence:

```bash
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/.claude/cobrain}"
TODAY_FILE="$OUTPUT_DIR/$(date +%Y%m%d)-raw.md"
test -f "$TODAY_FILE" && echo "exists" || echo "missing"
```

3. If the file does not exist or is empty, report:
   - "No cobrain entries captured today. The daemon may not be running — check with `status`."
   - Stop here.

## Phase 2: Efficient Metadata Extraction (bash-first)

**CRITICAL: Do NOT read the raw file yet.** Use bash/grep to extract structured metadata first. This avoids wasting tokens on repetitive VLM output and `<think>` blocks.

4. Extract entry count, time range, and per-app frequency:

```bash
# Entry count and time range
echo "=== ENTRY COUNT ==="
grep -c '^### ' "$TODAY_FILE"
echo "=== FIRST ENTRY ==="
grep -m1 '^### ' "$TODAY_FILE"
echo "=== LAST ENTRY ==="
grep '^### ' "$TODAY_FILE" | tail -1
echo "=== APP FREQUENCY ==="
grep '^### ' "$TODAY_FILE" | sed 's/^### [0-9:]\+ · //' | sort | uniq -c | sort -rn
```

5. Identify distinct activity blocks — consecutive runs of the same app represent a single work session:

```bash
# Show app transitions (block boundaries) with timestamps
grep '^### ' "$TODAY_FILE" | awk -F ' · ' '{app=$2} app!=prev {print NR, $0; prev=app}'
```

This gives you the session structure: how many blocks, what sequence of activities, and approximate durations.

## Phase 3: Intelligent Content Sampling

6. For each distinct activity block (consecutive same-app entries), read ONLY the first and last entry to understand what that session was about. This achieves full activity coverage at ~10% token cost.

   - Use `grep -n` to find line numbers of block boundaries
   - Use `Read` tool with offset/limit to read only those specific entries (typically 5-10 lines each)
   - For very short blocks (1-2 entries), reading the single entry is sufficient
   - **Never read the entire file**

7. Classify each activity block into one of these work categories:
   - **Deep Work**: focused productive tasks (coding, writing, spreadsheet analysis, design work)
   - **Communication**: work messaging (WeCom, Slack, email), meetings
   - **Research/Browsing**: web research, documentation reading, learning
   - **Personal/Other**: personal chat (WeChat non-work), system settings, activity monitor, idle time

## Phase 4: Generate Insight Report

Produce a report with these four sections. Total output should be **under 40 lines** — dense and scannable. Write in a professional tone, like a personal executive assistant's daily brief.

### Output Format

```
## Daily Brief — <date>

### Work Accomplished
- <concrete deliverable or task completed, in past tense>
- <another deliverable>
- ...
(Focus on WHAT was produced/achieved, not what apps were open)

### Time Allocation
- Deep Work: X hrs (XX%) — <primary activities>
- Communication: X hrs (XX%) — <work vs personal breakdown>
- Research: X hrs (XX%) — <topics>
- Other: X hrs (XX%)
(Total tracked: X hrs, from HH:MM to HH:MM)

### Workflow Observations
- <actionable pattern insight with specific numbers>
- <another observation>
(2-3 observations max. Focus on context-switching frequency, longest focus blocks, communication fragmentation, or late-night work patterns)

### Suggestions
- <1 concrete, constructive suggestion tied to today's data, with potential impact>
(1-2 suggestions max. Must reference specific numbers from today. Must have plausible economic or productivity value.)

---
**Headline:** <single sentence summarizing the day, suitable for a weekly digest>
```

### Rules for Each Section

**Work Accomplished:**
- Derive from the CONTENT of sampled entries, not app names
- "Edited Q4 financial spreadsheet" not "Used wpsoffice"
- "Reviewed PR #142 and left feedback" not "Used Chrome for GitHub"
- If entry content is too vague to determine deliverables, note what was worked on at a category level

**Time Allocation:**
- Calculate durations from timestamps between block transitions
- Distinguish productive communication (WeCom work discussions, Slack) from personal/ambient (WeChat personal chat, social media)
- Round to nearest 15 minutes

**Workflow Observations:**
- Count actual app transitions from the block boundary data — each transition is a context switch
- Identify the longest uninterrupted work session (largest consecutive same-app block)
- Note if communication was batched (clustered) or scattered (spread across the day)
- Flag unusual patterns: late-night work, very short focus blocks (<10 min average), excessive context-switching

**Suggestions:**
- Must reference specific data from today (e.g., "your 47 WeCom transitions suggest...")
- Must propose a concrete change (e.g., "batch responses into 3 windows: morning, post-lunch, end-of-day")
- Must articulate the benefit (e.g., "could recover ~45 minutes of fragmented time")
- Never give generic advice like "take more breaks" without tying it to today's numbers
