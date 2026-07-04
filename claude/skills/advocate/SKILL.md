---
name: advocate
description: Runs parallel devil's-advocate subagents — one per option — then collates their outputs into a per-option pros/cons list. Use when the previous response presented multiple options or approaches and the user wants a structured comparison, or when the user says "advocate", "argue for each", or "steelman these options".
---

# Advocate

For each option under consideration, spawns a subagent assigned to that option. Each subagent argues why its option is correct and why every other option is weaker. Results are collated into a per-option pros/cons list.

Uses the [fan-out](../fan-out/SKILL.md) primitive for parallel execution.

## Steps

### 1. Identify the options

Extract them from the previous response. Include any options the user named in their invocation message.

**Edge cases** (handle before spawning):
- **Options aren't clear** — ask the user to confirm the list first
- **More than 5 options** — warn that spawning >5 subagents will be slow; offer to prune

### 2. Build task list

One task per option. Each prompt must be self-contained — subagents start cold.

Prompt template per option:
```
You are an advocate for: **[ASSIGNED OPTION]**

Context: [PROBLEM/QUESTION BEING SOLVED]

All options under consideration:
[LIST ALL OPTIONS]

Your job:
1. Make the strongest case for [ASSIGNED OPTION]. Why is it the right choice? (terse: 2–4 bullets)
2. For each other option, identify its key weakness and explain why [ASSIGNED OPTION] handles that weakness better. (1–2 bullets per option)

Be direct and opinionated. Do not hedge. Do not recommend a blend of options.
```

Default depth: terse (2–4 bullets). If the user said "detailed", "deep", or "full argument", use 1–2 paragraphs per point instead.

### 3. Fan out (parallel)

Spawn all advocate agents in a **single message** per the fan-out pattern. Wait for all to return.

### 4. Collate

Build a section per option:
- **Pros** — drawn from that option's advocate output
- **Cons** — drawn from all *other* advocates' critiques of this option; do not attribute which advocate raised them

**Bold any argument that multiple advocates raised independently** — these survived cross-examination and deserve the most weight.

### 5. Recommend

Close with a recommendation section:
- **Single winner** — if the analysis converges clearly on one option
- **Decision guide** ("use X when Y, use Z when W") — if the right choice is genuinely context-dependent

Base the recommendation on the advocate outputs, not prior assumptions. Note which repeated arguments drove the conclusion.
