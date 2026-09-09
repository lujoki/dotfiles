# House Rules

Standing instructions for how I want agents to work, on **every** project, whatever the language or stack.

A project's own `AGENTS.md` / `CLAUDE.md` sits on top of this file and covers what is true of that project: its repos, ports, conventions, domain model, release process, and which Linear workspace its tickets live in.

**The project file always wins.** Not only on facts about the project: if it contradicts a rule here outright, that is a deliberate departure and it stands. Do what the project file says and carry on rather than stopping to ask which applies. Where a project file is silent, everything here still applies, and its silence is never permission to ignore a rule here.

A project file is usually an entry point rather than the whole of it: where it links out to detailed docs (coding style, component patterns, testing, routing, data access), **those docs are authoritative too**. Read the ones relevant to the work rather than stopping at the top-level file, and follow what they say about how that project does things.

Nothing here is project setup, so nothing here should be duplicated into a project file. If a rule below turns out to need a project-specific detail (a repo name, a path, a port), the detail belongs in the project file and this file stays general.

## Tool Availability

**Establish that a tool is missing by calling it, never by inspecting your own tool list.** A failed call is evidence. A belief about what you have is not, and has been wrong often enough to be worthless. This applies equally to the terminal, the Linear MCP, and the GitHub MCP.

- **"Try again" means call the tool again.** Not re-explain why it can't work. If I say a tool works elsewhere, or that I've changed a setting, that's new evidence and it outranks your previous conclusion. Retry first, then report what actually happened
- **Never theorise about causes for a tool you haven't just tried.** Ask/write mode, thread age, MCP profiles, thread configuration: all of it is speculation about internals you can't see, and it burns my time. One real call settles what any amount of reasoning cannot
- **A tool absent for one call may be present for the next.** Availability can change mid-thread. Never carry a failure forward as a standing fact, and never refuse on the strength of an earlier failure
- **Say what failed, verbatim.** Quote the actual error rather than paraphrasing it into a conclusion. "`save_issue` returned: could not resolve label" is actionable; "I don't have Linear access" is not, and may well be false

The failure mode this exists to prevent: becoming convinced a tool is unavailable, reporting that as fact, and then declining to retry when I say otherwise. Retrying costs one call. Being wrong about it costs the whole session.

## Reporting Work

**Never describe an edit you haven't made.** State what a change will be, make it, then confirm it. Do not write up a diff, quote file contents, or summarise a change as done before the tool call succeeds.

- **"I changed X" requires a successful edit in this session.** If the call failed or was never made, say so plainly
- **Verify before claiming, when the claim is cheap to check.** A `grep` or `read_file` costs one call and turns an assumption into a fact
- **Applies to every artefact**: files, tickets, comments, branches, commits, PRs

## Model Fit

Assess whether the active model is a reasonable fit for the task before doing substantial work. Continue with the current model by default.

- If the task is routine and the current model appears materially more capable than needed, briefly suggest switching to a faster or cheaper model and rerunning the prompt.
- If the task requires substantial reasoning, unfamiliar architecture, complex debugging, broad refactoring, or high-risk changes and the current model appears materially underpowered, briefly suggest switching to a stronger model and rerunning the prompt.
- Do not interrupt for marginal differences, and do not claim to know the active model unless the environment explicitly provides it.
- A model-fit suggestion is advisory. Do not block the task or change models yourself unless the user asks.

## Searching a Multi-Repo Workspace

Where a workspace repo holds child repos that its own `.gitignore` excludes, workspace-scoped search tools return nothing for anything inside them. **That is a tooling artefact, not proof the code is absent: never conclude a file or symbol does not exist from an empty result.**

1. **Use `rg` from the terminal first**, on an explicitly named path, even from the workspace root (`--no-ignore-vcs` if ever needed)
2. **`read_file` works normally** on any known path
3. **`list_directory` populates lazily** — an "empty" directory isn't proof it's empty; `read_file` something inside it first. Same for `edit_file`, which can fail with "path not found" until the file has been read

A workspace repo's ignore rules say nothing about a child repo's contents. To know whether a file is really ignored, read that child repo's own `.gitignore`.

## Working in an Existing UI

The default is to look like it was already there. Three habits, in order of how often they get skipped.

### Reuse a component before creating one

- **Search for an existing implementation first**, before writing any badge, button, modal, tooltip, dropdown, card, table or similar. Look wherever that project keeps shared components (`components/ui/`, `components/`, or whatever its framework's equivalent is)
- **If something suitable exists, use or extend it** through props, variants or composition. Only write a new one when nothing reusable exists, and then place it the way that project organises components: folder structure, naming, test co-location
- **If an existing component is close but not quite enough, add a variant or a prop to it.** Never fork a near-duplicate copy

### Never guess a colour

- **Use the colour tokens the project already defines**, in its Tailwind config or the CSS variables that feed it. Read that config, and read how colours are used elsewhere in the codebase, before picking a class name
- **Prefer semantic tokens over generic palette classes** wherever the project defines them: `bg-background-brand` or `text-foreground-primary` rather than `bg-blue-500`
- **Never hardcode a raw hex, rgb or hsl value, or invent an arbitrary Tailwind value** like `bg-[#1a2b3c]`, unless there is genuinely no token for it and I have explicitly approved the one-off

### Match the visual details already in use

- **Border radius, font size and weight, padding and spacing scale, shadows, transition timing** all follow how they are already used for that kind of element. Every button shares a corner radius and a font-size scale unless a variant intentionally differs
- **Before styling a new element, find one or two existing examples of the same kind** and mirror their classes, spacing and sizing rather than picking new values
- **Where a component defines its sizes and variants in config maps** (a `config.ts` alongside it with `sizeClasses` / `variantClasses`), extend the map. Never inline a one-off class to get around it

## Server-Rendered Apps

In any project using Vike, Next.js, a custom Vite SSR server or another SSR framework, **work out the data-fetching boundary before writing code**: where server-only fetching happens (Vike's `+data.ts`, a `*.server.ts`, a loader or route data function) and where the client merely consumes what was already fetched.

- **Never add a client-side `fetch` or `useEffect` for a page's initial data.** It renders empty HTML on the server, adds a waterfall, and risks pulling server-only logic into the client bundle. Client fetching is for user-triggered interactions after the first render: form submits, load-more, opening a control
- **Fetch what the page renders, and no more.** Data that only fills a control the user has yet to touch loads on interaction instead. Every such fetch blocks TTFB for everyone to serve the few who open the control, and an unbounded one grows with tenant size
- **Keep server-only code out of anything in the client bundle**: DB access, secrets, internal service calls. When unsure whether a file reaches the client, check how comparable pages in that project are structured and follow the same pattern

## Validation Workflow

Don't run the full gauntlet after every small change.

- After an edit, pull `diagnostics` for the touched file(s) only — usually enough on its own
- Skip formatters where a pre-commit hook already handles them
- Skip project-wide `lint` / `type-check` unless asked, the change is cross-cutting, or you're about to push
- Prefer the narrowest useful command over the project-wide run

## Generated Files

- **Never manually edit generated output.** Change the source and rerun the project's codegen command
- **Never resolve a conflict in a generated file by choosing or editing conflict hunks.** Rebase first, keep the intended source documents, make sure the upstream schema or input is final and available, then regenerate against it and stage the result. Keep generated output in its own commit where practical, so rebases and reviews isolate it
- **Discard uncommitted changes limited to generated directories during clean-up.** They are artefacts and do not need preserving: `git restore` the tracked files, then continue the normal worktree safety checks. Do not discard one if it comes with a related source change that still needs committing

## Dev Servers

Assume the project's dev servers are **already running** with hot reload, and that I am using them. No restart is needed after an edit.

**Never run a command that seizes or force-kills a port from a ticket worktree without asking me first.** A dev script that kills whatever holds its port makes checking the port first useless, and takes down the server I am working in. Stick to port-free validation (type-check, lint, unit tests), which runs fine in a worktree, and leave browser checks to me.

## Git Workflow

- **Start ticket work from the latest `main`** (unless intentionally stacking on a feature branch)
- **One worktree + branch per ticket**, with matching branch names across repos where work spans more than one
- **Add or update tests** for any change
- **Before requesting review or handing off, fetch and rebase onto the current target branch** (`origin/main` unless intentionally stacked), then rerun the relevant validation and force-push with `--force-with-lease` when the rebase rewrites history
- **Run the test suite before pushing**

## Linear Tickets

Every project of mine that uses Linear uses a different workspace and board, and possibly a different account. **The project file names the board, the label set and any project-specific defaults.** Everything in this section is how I want tickets handled whichever board they are on.

Defaults for new tickets: status **Todo**, assigned to **the person prompting**.

Do all ticket updates via the Linear MCP, and **surface any failure** rather than silently continuing.

### Descriptions are for QA and product

The description is read by QA, product and other non-implementers. It says **what** the change is and **how it will be verified**: the user story, the acceptance criteria, reproduction steps, expected against actual behaviour, impact, and notes a non-engineer needs.

- **Never put implementation detail in the description.** No file paths, function, component or class names, API or GraphQL field names, DB collections or schemas, migration plans, library choices, code snippets, or a step-by-step approach. To the person the description is addressed to, all of it is noise, and it makes the ticket harder to test from
- **Put it in a comment on the ticket instead.** Implementation notes, technical decisions, trade-offs, spike findings and code references are all worth recording. Just not there
- **Keep any Notes section business-facing**: constraints, dependencies, risks, links. Anything only an engineer would care about is a comment
- **The same holds for updates.** An edit refines the story and the criteria; evolving technical detail goes in comments

The reconciliation pass below is the one thing that edits criteria at handoff, and it is not an exception to this: it rewrites them to match what shipped, still in the language QA can test, never by importing implementation detail as justification.

### Accessibility and dark mode are out of scope

**Never write an acceptance criterion about accessibility conformance or a dark
mode interface.** An A/C that names one sends QA looking for behaviour nobody
agreed to build, and neither is a goal on my projects unless a ticket has been
raised specifically to make it one.

Do not write A/Cs that require:

- WCAG conformance, contrast ratios, or colour not being the sole signal
- Screen reader announcement, `aria-*` state, or semantic-role verification
- Keyboard reachability, focus order, or tab traps
- Colour-blind-safe palettes
- A dark theme, dark palette, or `prefers-color-scheme` behaviour

This is about **what gets promised in a ticket**, not what gets written in code.
Keep using semantic HTML, real `<button>`s and labelled inputs where they are
the natural thing to reach for. Just do not turn any of it into an A/C that QA
is then asked to sign off.

Two things this rule does **not** cover, and which stay legitimate A/Cs:

- **Touch and mobile.** "Readable at 375px", "works without hover" and "tappable"
  are device requirements, and people genuinely use these things on a phone
- **Plain language.** "Each state carries a plain-English explanation rather than
  an icon alone" is a legibility requirement about the words chosen

If a ticket arrives carrying one of the banned criteria, strip it before starting
work and say so in a comment rather than silently building to it.

The one exception is a project whose own file says accessibility or a dark theme
**is** a product goal. Then that file wins, and the A/Cs are legitimate there.

### Criteria QA cannot test

An unticked checkbox is an instruction to QA to go and test that thing. So a
criterion nobody can observe through the interface, left unticked at handoff,
guarantees the ticket comes back: the tester does the only honest thing
available and reports that they could not verify it.

**Split the A/C list at writing time.** Criteria that can only be established in
code go under their own heading, and get ticked at handoff rather than sent to
QA:

```markdown
**Acceptance Criteria**
- [ ] What somebody can see happen on screen

**Verified in development**
Ticked at handoff with the evidence, not sent to QA. Reason each one.
- [ ] Criterion — why it is not observable: e.g. an internal threshold with no
      on-screen expression, so it is pinned by `foo.spec.ts` instead
```

**Ticking one requires the evidence in the implementation comment**, to the same
standard as the handoff table: the file and the test name, or the command output.
"Verified in development" is not a lower bar than QA, it is the same bar checked
by a different person against different material.

**What legitimately belongs there:**

- Internal heuristics, thresholds and tuning constants with no on-screen
  expression
- "No calculation, aggregation or fetching behaviour changed"
- Cross-tenant and cross-account isolation, where the environment holds one
  tenant
- The output of a script or a job, rather than a page
- Data-model invariants, resolver scoping, guard coverage

**What does not**, however inconvenient:

- Anything visible on screen given the right data. If QA cannot reach the state,
  the answer is a **fixture**, not a dev sign-off. Name the fixture in the
  ticket, so the tester is not hunting for an account that happens to exhibit
  it: "needs a plan with 3+ tactics sharing one identical KPI target"
- Anything I have not actually verified this session. An unverified criterion
  ticked as "verified in development" is worse than one QA could not reach,
  because nobody is looking at it any more

**Never point a criterion at a handoff document, brief or spec.** "Copy matches
the approved source copy exactly", "matches the design in the handoff", "as
specified in the brief": a tester has no access to any of those by default, so
the criterion cannot be passed or failed by the person it is addressed to. It
comes back as "blocked, we don't have the document", every time, and it is the
single easiest reopen to prevent.

Two ways to write it instead:

- **Put the substance in the criterion.** If the copy, the figure or the
  behaviour matters, state it in the ticket where QA can read it. A criterion
  quoting the actual heading is testable; one deferring to a file is not
- **Or move it under Verified in development**, reasoned as "the source is a
  document QA does not hold", and check it myself against the source

The source document still belongs in **Notes**, as provenance for whoever picks
the work up. What it must never be is the thing a tester is sent to go and find.

**The classification is challengeable, so state the reason.** If QA or I think
something has been moved out of testing to avoid testing it, the reason is what
we argue with. A criterion moved with no reason given reads as ducking it.

**Retrofitting the split onto somebody else's ticket is my call, not yours.**
Where a reopened ticket is back solely because of criteria in this category, say
so and propose the split in a comment. Do not reorganise somebody else's A/Cs to
close a reopen.

### Starting work

For **new work with no ticket**, create the ticket first (correct label + the project's template), then follow the same flow as an existing ticket. Keep the description current as scope becomes clearer — don't backfill at the end. A ticket written in this session is the one most likely to carry A/Cs we then decided against, so the reconciliation pass at handoff still runs on it.

For **an existing ticket**, as soon as you fetch its details and before any implementation:

1. Rename this agent thread so its title **starts with the ticket identifier**, followed by a short description of the work, e.g. `ENG-1837: relative worktree paths in handoff`. Identifier first, in caps, so threads are scannable and sortable by ticket
2. Assign it to me (unless told otherwise) and move it to **In Progress**
3. Pull `main`, then create the worktree + branch — use Linear's suggested branch name, or at minimum include the ticket identifier. Same branch name in every repo the work spans. For intentional stacked work, branch from the feature base and target it in the PR
4. Do whatever the project file says is needed to make a fresh worktree runnable, since gitignored local config (`.env` and friends) does not come across with it

Implement inside the worktree, never the base checkout. **If the lockfile or manifest changes**, do a real dependency install in the worktree rather than relying on a symlinked module directory — installing through a symlink mutates the main checkout.

### Check the acceptance criteria before handing off

Immediately before writing the handoff summary, re-fetch the ticket from Linear
and walk its acceptance criteria one at a time. Re-fetch rather than working
from the copy pulled at the start: A/Cs get edited mid-flight, and building to a
remembered list is how a ticket comes back from QA.

Each criterion gets one of three verdicts and nothing else:

- **Met**, with the evidence that proves it: the file and line implementing it,
  the test covering it, or the command output showing it pass. "It should work"
  is not evidence. Same standard as the rest of this file: if it wasn't verified
  in this session, it isn't met
- **Not met**, with one line on why: out of scope once the work took shape,
  blocked on something, more effort than the criterion is worth, or simply
  missed
- **Not verifiable here**, for anything needing a browser, real data, staging or
  a third party. Say what needs doing to check it, so it can go straight into
  the manual verification steps

Report it as a table, as the first item in the handoff summary:

| # | Criterion | Verdict | Evidence or reason |
|---|-----------|---------|--------------------|

**Never quietly close the gap.** If a criterion is unmet because it turned out
to be bigger than the ticket, or because the implementation went a different
way, that's the thing to surface. Don't rush a thin version in at the end so the
row can read "met", and don't drop a passing test in to cover something the code
doesn't actually do.

**Never tick off the A/Cs in Linear yourself.** An unticked box is QA's
instruction to go and test that thing, and ticking it takes it out of testing.
The only exception is the "Verified in development" block, which is ticked at
handoff with its evidence as described above.

**Unmet criteria that are still wanted stay in the ticket.** Whether one gets
built now, deferred to a follow-up or struck from the scope is my call, and I
need it in front of me on the table to make it. What does get edited out is
covered by the next section, which is about criteria we already decided against
during the work.

**Flag work that went past the A/Cs as well.** Anything built that no criterion
asked for gets its own row under the table. Either the ticket is missing a
criterion or the change is scope creep, and both are worth knowing about before
review.

**Say when a criterion is ambiguous rather than picking a reading.** If two
readings would produce different code and the code is already written, say which
reading was built to.

**Strip banned criteria and report them.** Anything covered by "Accessibility
and dark mode are out of scope" gets removed from the ticket with a comment
saying so, and appears in the table with the verdict "removed, out of scope".

This runs every time, without being asked, and runs again on any re-handoff
after review changes.

### Reconcile the ticket description with what was built

**The description is the only thing QA has.** A criterion that was written
before the work started, decided against during the work, and then left sitting
in the description gets tested anyway, fails, and reopens the ticket for
behaviour nobody agreed to build. Preventing that is part of finishing the work,
not a nicety.

So immediately after the A/C check, and before the handoff summary, **update the
Linear description so it describes what we actually decided and built.** This
applies with double force to a ticket created in this same session: its
description was drafted before a line of code existed, off a rough
understanding, and is the most likely of all to have drifted.

What to change:

- **Remove criteria we deliberately did not implement**: dropped as out of
  scope once the shape of the work was clear, superseded by a different
  approach, or agreed away in conversation. Move them into a follow-up ticket
  where they still have value, and link it in Notes
- **Rewrite criteria whose behaviour came out different** from what was
  written, so the criterion describes the behaviour that exists
- **Add criteria for behaviour that was built and that QA should test** but
  which no existing criterion covers. These are the same rows flagged as
  scope creep on the table, and QA needs them to be testable
- **Fix stale description prose**: screens, routes, field names, flows or
  figures described one way in the ticket and built another

What to leave alone:

- **Unmet criteria that are still wanted.** Those belong on the table as "not
  met" and stay in the ticket for me to rule on
- **Every checkbox tick**, per the rule above
- **Somebody else's framing** where the substance is right. Reconciling is not
  rewriting the ticket in my voice

**Do this without asking, but report every change.** No approval is needed
before editing, and nothing waits on me. In exchange, I need full visibility
after the fact, so the edits appear in chat as their own table, immediately
after the A/C table in the handoff summary:

| Change | Before | After | Why |
|--------|--------|-------|-----|

Use "removed" or "added" in the After or Before cell as appropriate, quote the
criterion text rather than summarising it, and give the actual reason: "agreed
in conversation to defer the bulk path", not "no longer needed". If nothing
needed changing, say so in one line rather than omitting the table, so I know
the pass ran.

Also leave a short comment on the ticket saying the description was reconciled
at handoff and listing the same changes, so the trail is on the ticket for QA
and not only in this thread. Linear keeps description history, so there is no
need to paste the old version anywhere.

**Never use this to quietly close the gap.** Deleting a criterion is not a way
to make an unmet row disappear. The test is whether we decided against it during
the work: if we did, it goes, with the decision named in the Why column. If it
is simply unbuilt, it stays and shows on the table as "not met".

### Handing off for review

End with a handoff summary, in this order:

1. **The acceptance criteria table** from the check above, unmet and out-of-scope rows included
2. **The description changes table** from the reconciliation pass, or one line saying nothing needed changing
3. **Commands run and their results** — type-check, lint, test. Never claim a command passed unless you ran it and saw it pass
4. **What couldn't be verified and why** — anything needing a browser, real data, or a third party
5. **Manual verification steps** — the URL to visit and what should be seen
6. **Anything else I must know** — dependency, schema or migration changes; deliberate follow-ups left undone
7. **The final block — always the very last thing in the message**, so I can act on it without scrolling:
   - **TL;DR** — one or two lines on what was asked and what changed
   - **Linear ticket link** — the full `https://linear.app/...` URL
   - **Worktree path** and **branch name** (per repo)
   - **PR link(s)** — one per repo, or why none was opened
   - **To get there locally** — a bare `cd` per affected repo, each in its own code block so they can be copied independently, and written relative to where I actually am rather than to a nested path a workspace tool reports

Nothing comes after that block — no commentary, questions, or suggested next steps. Don't explain the dev server, the bundler cache, or checking the branch out in the main checkout; I know all that. Only exception: one line if a dependency install is needed.

### Finishing work

Once implementation is done and tests pass, without waiting for a prompt: **commit** from the worktree referencing the ticket number, **push** the branch, and **open a PR** per affected repo targeting `main` (or the feature base for stacked work). Surface any failure.

Removing the worktree and any release-note duties happen later, once merged — see Clean Up.

### Adding to work already pushed

**Check whether the PR is still open before pushing another commit to its
branch.** A push to a branch whose PR has already merged changes nothing: the
commit lands on a dead branch, no reviewer sees it, and it never reaches
`main`. The push succeeds, which is what makes this so easy to miss.

```bash
gh pr view <number> --repo <owner>/<repo> --json state,mergedAt
```

**Check immediately before the push, not before the validation run.** A full
test suite takes minutes, and that is long enough for somebody to merge the PR
while it runs. A state check from the top of the turn is not evidence about the
state at the moment of pushing, and reporting "it was open when I looked" is an
excuse rather than an outcome. Re-read it as the last thing before the push, or
make the check and the push a single command so nothing can land in between:

```bash
gh pr view <number> --repo <owner>/<repo> --json state --jq .state | grep -qx OPEN && git push
```

- **Open**: push to the same branch as normal
- **Merged or closed**: that branch is finished. Branch fresh from the latest
  `main`, bring the change across with `git cherry-pick`, and open a **new**
  PR. Never reopen a merged PR, and never try to revive its branch
- **Before redoing a commit that was already pushed to the dead branch**,
  confirm it did not somehow make it in:
  `git merge-base --is-ancestor <sha> origin/main`. An ancestor is already on
  `main`, so there is nothing to redo and applying it again would duplicate it

The same check applies to a branch that was never merged but has drifted: if
`origin/main` has moved on, rebase before pushing rather than after review
starts.

This bites hardest on the change that feels too small to deserve its own PR: a
follow-up fix, a review tweak, an env var somebody asked about. That is exactly
when the original PR is most likely to have been merged while the follow-up was
being written.

**Say so plainly when it happens.** "Fixed and pushed" is untrue if the push
went to a merged branch, and per Reporting Work above, the claim needs the
change to actually be somewhere it can ship. Correcting it costs one message;
not correcting it means the fix silently never lands.

### Reopened tickets

"What's reopened" / "triage reopened" is a standing command: sweep every ticket
on the project's board in the **Reopened** status **assigned to me** and report
the table below. It is a read-only triage pass. Do not write to Linear, create a
worktree or start implementing anything until I pick rows off the table.

Somebody else's reopened ticket is not mine to triage or to fix: their QA notes
are addressed to them, and a recommendation from me on their ticket is noise on
somebody else's queue. **List those as a one-line tally under the table**,
identifiers and assignees only, so nothing is invisible, and say nothing about
what should happen to them. Only pull one into the table if I ask for it by
name.

For each reopened ticket, read in this order:

1. The ticket itself, re-fetched, for the **current** A/Cs
2. Every comment added since it last moved into Reopened: that's the tester
   note, and it is the reason it is back
3. The merged PR(s), to see what actually shipped against what was asked
4. Whether it was tested against a build that contains the merge. A ticket
   tested on staging before the deploy, or on a stale local build, is a false
   reopen and the recommendation is to say so, not to change code

Then report:

| Ticket | What it was | Why it's back | Recommended | Size |
|---|---|---|---|---|
| [ENG-1234](https://linear.app/...) | One line, what the ticket set out to do | • **A/C 3 failed.** "Totals still show gross when the toggle is off" (Sam, 4 Sep)<br>• **New:** "column header wraps at 1280px" | • **Fix.** `usePlanTotals` reads the toggle but the footer row calls the raw sum; point it at the same hook<br>• **Split.** Layout bug, not in scope of this ticket, own Improvement | M |

Rules for the table:

- **The bullets in "Why it's back" and "Recommended" line up one to one.** Third
  bullet in one column answers the third bullet in the other. Same order, same
  count, every row
- **Quote the tester verbatim** in "Why it's back", with who said it and when.
  Never paraphrase a note into a conclusion: "totals still show gross" is
  actionable, "totals are wrong" is not
- **Label each failure** as either `A/C n failed` (a criterion the ticket
  promised and the code does not do) or `New` (something found nearby that no
  criterion covers). They lead to different recommendations
- **Every recommendation opens with one of five verdicts**, bolded:
  - **Fix** for a real defect or genuinely unmet criterion, followed by the
    actual cause and the change, not "investigate"
  - **Challenge** where the note or the criterion does not warrant work
  - **Split** where the finding is real but new: own ticket, this one closes
  - **Clarify** where I or the tester have to answer something before it can be
    written either way
  - **Reproduce first** where it is plausible but has not been reproduced yet,
    with the one thing needed to try (data, workspace, account)
- **Size** is `S` (under an hour), `M` (half a day), `L` (bigger than the
  original ticket, and probably should not be a reopen at all)
- **Order rows by what I have to decide, not by ticket number.** Rows carrying a
  **Challenge** or **Clarify** first, since nothing can proceed on those without
  me; then **Fix** rows, release-blocking ones first
- Anything that will not fit in a cell goes in a short block under the table,
  one heading per ticket. Keep the cells scannable

#### Challenging a note

A **Challenge** is the point of the exercise as much as a fix is, and it needs
an argument I can forward to the tester as written: one or two factual lines
saying what the code does, why that is what was asked for, and what would need
to change on the ticket for it to become work. Reach for it when:

- The behaviour matches the A/C as written and the tester expected something the
  A/C never promised
- The finding is real but pre-existing, in code the ticket never touched
- It is an environment, seed data or permissions artefact rather than a defect
- The criterion is one of the banned ones (see "Accessibility and dark mode are
  out of scope"). Those are always a Challenge: strip the criterion, comment
  saying so, and give the row the verdict `Challenge, out of scope`
- The ticket was tested against a build that predates the merge

"Harder than it's worth" is a legitimate Challenge too, as long as the row says
what the cost actually is.

#### Second and later reopens

Say in the row when a ticket has been round more than once, and on which
bullet. **A bullet that comes back a second time is evidence the criterion is
ambiguous**, not that the last attempt was careless: the recommendation for
those is usually **Clarify** with the two readings written out, and a rewritten
criterion proposed for me to approve.

#### Once I pick rows

Per ticket picked, follow **Starting work** as normal, with three differences:

- **The old worktree is gone**, removed at clean-up when the PR merged. Branch
  fresh from latest `main` as `luke/eng-1234-qa-fixes`; do not resurrect the old
  branch
- **If the ticket's release has already shipped**, the fix gets its own entry in
  whatever the current draft is at clean-up. Never edit a shipped release note
- The handoff A/C table gets a line under it mapping each reopen bullet to what
  was done about it, so the tester can retest exactly what they raised
- **End every ticket by re-printing the next row from the table**, re-fetched
  rather than repeated from earlier in the session, so the next decision is in
  front of me without asking. Revise the recommendation if the re-fetch changed
  the picture, and say what changed

Never move a reopened ticket to Done, edit its A/Cs, or resolve the tester's
comment yourself. Reporting is the job; deciding is mine.

### Issue Templates

The label names and emoji are per-board, so the project file owns those. These
bodies are how I want a ticket written on any board.

**Feature**

```markdown
> As a [role],
> I want to [outcome],
> So that [reason]

**Acceptance Criteria**
- [ ] Criterion 1
- [ ] Criterion 2

**Verified in development**
Only where something genuinely cannot be observed through the UI. Reason each
one, and delete the heading if there are none.
- [ ] Criterion — why it is not observable

**Notes**
Optional — relevant notes, constraints, links, risks
```

**Improvement**

```markdown
A short statement of what needs improving and why it matters

**Acceptance Criteria**
- [ ] Criterion 1
- [ ] Criterion 2

**Verified in development**
Only where something genuinely cannot be observed through the UI. Reason each
one, and delete the heading if there are none.
- [ ] Criterion — why it is not observable

**Notes**
Optional — dependencies, constraints or related work
```

**Bug**

```markdown
**Summary**
Concise description of the bug

**Steps to Reproduce**
1. Step 1
2. Step 2

**Expected Behaviour**
What should happen?

**Actual Behaviour**
What is happening?

**Frequency**
Always / Sometimes / Rarely

**Impact**
Critical / Major / Minor / Cosmetic

**URL**
Where did this happen

**Environment**
e.g. Browser, Operating System, Device, Version

**Screenshots / Videos**
Please include screenshots and / or a video
```

**Tech Debt**

```markdown
Description of what needs refactoring, cleaning up, or improving and why

**Acceptance Criteria**
- [ ] Criterion 1
- [ ] Criterion 2
```

## Clean Up

"Clean up" is a standing command: do the sweep below, in order, then report. It's not licence to reformat, refactor or delete anything else, and needs no new ticket.

`gh` is installed, you can also use the GitHub MCP tools for PR state, plain `git` for everything local.

### 1. Reconcile worktrees against their PRs

Enumerate worktrees rather than guessing which PRs are recent, one call per repo in the workspace:

```bash
git -C <repo> worktree list
```

For each ticket worktree, resolve its branch and find that branch's PR:

| PR state | Action |
|---|---|
| **Merged** | Remove the worktree and delete the branch, if the safety checks pass |
| **Closed, not merged** | Stop and ask me — the branch may be the only copy |
| **Open** | Leave it; report as still in flight |
| **No PR found** | Leave it and flag it — probably never pushed |

**Safety checks — all must pass, else leave it and report:** `git -C <worktree> status --porcelain` empty; `git -C <worktree> log --oneline @{u}..` empty; the path is a worktree, not a base checkout.

**Remove with git, never `rm -rf`** — worktrees commonly symlink dependency directories and local config into the main checkout, so a stray `rm -rf` resolves through the link and destroys it:

```bash
git -C <repo> worktree remove ../<repo>-eng-1234   # no --force
git -C <repo> branch -d luke/eng-1234-short-description
git -C <repo> worktree prune
```

A refusal from `worktree remove` (dirty) or `branch -d` (unmerged) is information — report it, never escalate to `--force`/`-D` without asking.

Judge each repo's worktree on its own PR state but group them under one ticket in the report. Flag any ticket whose PRs are all merged but isn't in Done.

### 2. The project's own clean-up steps

Whatever the project file adds: release notes for merged work, changelog entries, docs. Do those before retiring the thread, and follow that file's rules on what warrants a mention.

### 3. Retire the ticket's agent thread

A ticket is finished with once its PRs are merged and any release-note duties are settled. For each such ticket, find the agent thread whose title starts with that ticket identifier and:

1. **Rename it to end with `[Cleaned]`** — identifier first as always, so `ENG-1837: relative worktree paths in handoff` becomes `ENG-1837: relative worktree paths in handoff [Cleaned]`
2. **Archive the thread**

Both steps apply whether a release notes entry was added or judged unnecessary — "settled" means a decision was made, not that something was written. Only skip a thread when its worktree was left in place (open PR, closed PR, no PR, or a failed safety check): if step 1 didn't finish the ticket, leave its thread alone and say so in the report.

The thread being cleaned up may well be the one doing the cleaning up. Rename and archive it last, after the report, so nothing is lost mid-sweep.

### 4. Commit and report

Any file changes the sweep produced are a normal code change: branch + PR, never on `main` and never in a main checkout.

Report: worktrees removed, worktrees left and why, entries added or judged unnecessary, threads marked `[Cleaned]` and archived, anything needing a decision.
