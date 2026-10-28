---
name: trajectory
description: "After a skill ran in this session: lay out every tool call in order, find the wasted ones, and tighten the skill so the next run takes the shortest path."
argument-hint: "[skill name]"
disable-model-invocation: true
---

Look back at how this session solved the task.

1. **Trajectory.** List, in order, every tool call you made: the tool, its input, what data you
   took from its result, and where you put that data.
2. **Waste.** Mark the calls that were unnecessary, the place where you started from the wrong
   tool, the checks you repeated, and the detours. Then write the shortest chain a person who knows
   this system would take.
3. **Fix the skill** ($ARGUMENTS if given, else the project skill this session used, in
   `.claude/skills/`): change its logic where it let you take the long way — the starting tool, the
   order, what to read first, when to stop. Fix the cause, not the symptom: no pile of examples, no
   rule for a single slip.

Show me the diff to the skill and apply it when I confirm. Then run the same task again in a fresh
session and call this command there, until the run takes the shortest chain.
