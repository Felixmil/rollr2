---
name: file-pipeline-workflow
description: Runs the file-based issue pipeline as a dynamic Workflow, with you (this session) supplying the human answers the workflow itself cannot ask for. Launches workflows/file-pipeline.js, and whenever it stops on a question, a manual-mode gate, or a missing dependency, surfaces that decision inline via AskUserQuestion and relaunches the workflow with the answer. Use when the user says "run the file-pipeline workflow on N", "drive issue N through the workflow", or invokes /file-pipeline-workflow with an issue number and optional mode. For the fully in-session (non-workflow) variant, use the file-pipeline skill instead.
---

# File pipeline (workflow-driven)

You are the thin human-interaction shell around `workflows/file-pipeline.js`.
The workflow is the engine: it owns the phase loop, the four
file-writing agents, the `state.json` state machine, and every
bookkeeping call. It keeps all state and all four artifacts on the local
filesystem under `<repo>.issues/<issue>/`, posts nothing to the issue
thread, and produces a pull request as the only ship channel, exactly
like the in-session `file-pipeline` skill.

The one thing the workflow structurally cannot do is ask you a question:
its `agent()` calls are subagents, and the workflow runtime has no prompt
primitive. So the workflow never guesses. When it needs a human decision
it persists the question to `state.json.pendingQuestion` and **returns**
a small typed object describing what it is waiting on. **Your only job is
to turn that returned object into an `AskUserQuestion`, take the answer,
and relaunch the workflow with the answer folded into its args.** From
the user's seat this is one continuous ask/answer/continue; under the
hood it is stop-and-resume across the answer, and the resume replays every
completed phase from cache so no prior work is redone.

## When to use this vs the in-session file-pipeline skill

Both keep state and artifacts on the filesystem and behave identically to
the user. They differ only in the engine:

- **This skill (`file-pipeline-workflow`)** runs the pipeline as a real
  dynamic Workflow. The phase work, fan-out, and bookkeeping run inside
  the workflow runtime; you only broker questions. Prefer it when you
  want the workflow engine (its progress view, its cached resume, running
  it headless later with answers passed as args).
- **The `file-pipeline` skill** runs the whole loop in this session's own
  context and asks questions inline with true same-run continuation (no
  relaunch). Prefer it when you want the simplest interactive run.

Pick one per issue; do not drive the same issue with both (they share the
same `state.json`, so it is safe, but redundant).

## The loop you run

1. **Parse the argument** as `<issue> [mode]`. `mode` is one of `auto`,
   `semi-auto`, `manual`, or the terminal action `merge`. If no mode word
   is given, pass none and let the workflow default (a persisted mode wins
   on a resume; a fresh issue defaults to `semi-auto`). Reject any other
   mode word loudly.

2. **Launch the workflow.** Call `Workflow` with the script and an object
   `args`:

   ```
   Workflow({
     scriptPath: ".claude/workflows/file-pipeline.js",
     args: { issueNumber: <issue>, mode: <mode-if-given> },
   })
   ```

   Keep the returned **`runId`** (from the tool result). You need it to
   resume.

3. **Read the workflow's returned object.** Its `status` field tells you
   what happened:

   | `status` | Meaning | What you do |
   | --- | --- | --- |
   | `question` | An agent raised a clarification. | Ask it (step 4), relaunch with `answer`. |
   | `gate` | A manual-mode phase wrote its artifact and is awaiting approve/revise. | Ask it (step 4), relaunch with `directive`. |
   | `dependency` | A depended-on issue has no artifacts yet. | Ask it (step 4), relaunch with `directive`. |
   | `done` | Nothing left to drive; the issue reached its resting point. | Stop; report the final `state`. |
   | `rejected` | QA still rejected after the round cap; left at `in-progress`. | Stop; report it for a human. |
   | `merged` | Merge action completed. | Stop; report the merged PR. |
   | `waiting` | The human chose to wait (e.g. on a dependency). | Stop; report it. |

   For any terminal status (`done`, `rejected`, `merged`, `waiting`),
   summarize the outcome to the user and finish. Do not relaunch.

4. **Surface the decision with `AskUserQuestion`.** The returned object
   carries `pendingQuestion` with `{question, options, recommendedDefault}`
   (and `phase`/`kind`). Build the `AskUserQuestion` call directly from
   those fields, recommended option first. **Do not print any decision
   context as prose before the call; everything the user needs is inside
   the returned `question` and option text.** (The workflow already
   persisted the question to `state.json.pendingQuestion` before
   returning, so a killed session loses nothing: a re-run relaunches the
   workflow, which re-returns the same pending question, and you re-ask it.)

5. **Map the answer to a relaunch arg**, by the returned `kind`:
   - `kind: "clarification"` -> `args.answer` = the chosen option's label
     (plus any free-text the user added).
   - `kind: "gate"` -> `args.directive`:
     - user approved -> `{ kind: "approve" }`
     - user chose revise -> `{ kind: "revise", feedback: "<their feedback>" }`
   - `kind: "dependency"` -> `args.directive`:
     - proceed -> `{ kind: "proceed" }`
     - wait -> `{ kind: "wait" }`

6. **Relaunch the workflow, resuming from the same run** so completed
   phases replay from cache and only the answer-consuming call onward runs
   live:

   ```
   Workflow({
     scriptPath: ".claude/workflows/file-pipeline.js",
     resumeFromRunId: "<runId from step 2>",
     args: { issueNumber: <issue>, answer: "..." },   // or directive: {...}
   })
   ```

   Keep the new `runId` it returns; use it for the next resume.

7. **Go back to step 3** with the newly returned object. Repeat until a
   terminal status.

## If a question goes unanswered

If `AskUserQuestion` returns no usable answer (it timed out, came back
empty, or the user declined), **do not guess and do not relaunch with a
made-up answer.** Stop. The workflow already left `pendingQuestion` set in
`state.json` and did not advance the status, so a later re-run of this
skill relaunches the workflow, which re-returns the same pending question,
and you ask it again. Report to the user that the run is paused awaiting
that decision.

## Merge

`/file-pipeline-workflow <issue> merge` launches the workflow with
`mode: "merge"`. That is a standalone terminal action: the workflow
refuses unless `state.json.status` is `human-review`, then squash-merges
the linked PR and closes the issue. It returns `status: "merged"` (or
throws with a clear message). Relaunch is never needed for merge; report
the result and finish.

## Anti-patterns

- Guessing an answer, or relaunching with a default the user never chose,
  when a question went unanswered. Stop instead; the persisted
  `pendingQuestion` makes a re-run re-ask it.
- Printing decision context as prose before `AskUserQuestion`. Put all of
  it inside the question and option text (the workflow already put it in
  the returned object).
- Doing any pipeline work yourself, reading or writing `state.json`,
  running the transition script, calling the phase agents, or touching the
  artifacts. The workflow owns all of that. You only launch it, ask, and
  relaunch.
- Relaunching without `resumeFromRunId`. A fresh run re-executes every
  phase from scratch instead of replaying from cache.
- Driving the same issue with both this skill and the in-session
  `file-pipeline` skill in a way that interleaves. Pick one engine.

## Done criteria

The workflow reached a terminal status (`done`, `rejected`, `merged`, or
`waiting`), every question it raised was surfaced to the user via
`AskUserQuestion` and answered (or the run is cleanly paused on an
unanswered one, with `pendingQuestion` still set for a re-run), and you
reported the outcome. You never wrote `state.json`, ran the transition
script, or invoked a phase agent yourself.
