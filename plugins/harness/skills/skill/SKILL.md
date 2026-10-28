---
name: skill
description: "Turn a task this session finally solved into a project skill in .claude/skills/, so the next session does it directly. Run it right after the solution works."
argument-hint: "<what the skill should do>"
disable-model-invocation: true
---

Using everything you learned in this session, write a project skill that does: $ARGUMENTS

- **Where:** `.claude/skills/<name>/SKILL.md`, committed with the project, so every teammate's
  session has it.
- **Helper:** if a skill-writing skill is installed — `skill-conductor` (architecture and evals),
  `developing-ai-agents` (when the skill runs an agent loop), `writing-for-agents`, or
  `skill-creator` — use it for the structure and the check.
- **Description:** when to use it, in the words a person would use to ask for it, and what it does.
  The agent picks skills by description alone.
- **Body:** the shortest path that worked here — which tools in which order, the inputs it needs,
  where each result goes, the check that proves it worked, and the traps this session hit. Write
  the logic that avoids each trap, not a pile of examples.
- **Who calls it:** leave it model-invoked when the agent should reach for it on its own; add
  `disable-model-invocation: true` when it has side effects only a person should trigger.

Show me the skill and commit it when I confirm. Then try it on a real task in a fresh session and
run `/harness:trajectory` there.
