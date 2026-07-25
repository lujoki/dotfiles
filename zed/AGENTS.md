# Global Agent Rules (all projects)

These rules apply across every project Zed works in, in addition to any
project-specific rules (e.g. `AGENTS.md` or `CLAUDE.md` at a project root).
If a project-specific rule conflicts with one of these, the project-specific
rule wins.

## Reuse existing UI components before creating new ones

- Before writing a new component (badge, button, modal, tooltip, dropdown,
  card, table, etc.), search the codebase for an existing implementation first
  (e.g. a `components/ui/` or `components/` directory, or similar shared
  component location for the project's framework).
- If a suitable component already exists, use/extend it (via props, variants,
  or composition) instead of creating a duplicate. Only create a new component
  when nothing reusable exists, and place it consistent with the project's
  existing component organization (folder structure, naming, test co-location).
- If an existing component is close but not quite sufficient, prefer adding a
  variant/prop to it over forking a near-duplicate copy.

## Never guess Tailwind colors

- Never hardcode raw hex/rgb/hsl color values or invent arbitrary Tailwind
  values (e.g. `bg-[#1a2b3c]`) unless there is truly no existing token for it
  and the user has explicitly approved a one-off color.
- Always use the color tokens/utilities already defined in the project's
  `tailwind.config.js`/`tailwind.config.ts` (or CSS variables consumed by it).
  Check that config file (and how colors are used elsewhere in the codebase)
  before picking a class name.
- Prefer semantic tokens (e.g. `bg-background-brand`, `text-foreground-primary`,
  `border-critical`) over generic palette classes (e.g. `bg-blue-500`) when the
  project has semantic tokens defined.

## Keep visual details consistent with the existing UI

- Things like border radius, font size/weight, padding/spacing scale, shadow
  usage, and transition timing must match how they're already used elsewhere
  in the app for the same kind of element (e.g. all buttons should share the
  same corner radius and font-size scale unless a variant intentionally
  differs).
- Before styling a new element, find 1-2 existing examples of the same kind of
  element (button, badge, input, card, etc.) in the codebase and mirror their
  classes/spacing/sizing conventions rather than picking new values.
- If the codebase defines size/variant config objects for components (e.g. a
  `config.ts` next to a component with `sizeClasses`/`variantClasses` maps),
  extend those maps rather than inlining one-off classes.

## Respect SSR architecture (Vike / Vite SSR, or similar)

- When a project uses Vike, a custom Vite SSR server, Next.js, or any other
  SSR framework, understand its data-fetching boundary before writing code:
  identify where server-only data fetching happens (e.g. Vike's `+data.ts`,
  a `*.server.ts` file, loader/route data functions, etc.) versus where the
  client component consumes already-fetched data (e.g. `useData()`).
- Do not introduce client-side `fetch`/`useEffect` calls for a page's initial
  data load in an SSR project — that breaks the SSR contract (empty
  server-rendered HTML, extra waterfalls, potential leaking of server-only
  logic into the client bundle). Client-side fetching is fine only for
  user-triggered interactions after the initial render (form submits, "load
  more", etc.).
- Keep server-only code (DB access, secrets, internal API calls) out of files
  that are part of the client bundle. When unsure whether a file is
  server-only, check how similar existing pages/routes in the project are
  structured and follow the same pattern.

## Translate `.claude` directory instructions for Zed

- If a project contains a `.claude` directory (e.g. `CLAUDE.md`,
  `.claude/docs/*.md`, `.claude/settings*.json`), treat its contents as
  authoritative project conventions and follow them, even though it was
  written for Claude Code rather than Zed.
- Read `CLAUDE.md` and any referenced docs under `.claude/docs/` (coding
  style, component patterns, testing, routing/guards, API resource patterns,
  types/codegen, etc.) and apply that guidance directly.
- Translate tool-specific bits to their Zed equivalent instead of ignoring
  them:
  - Claude Code slash commands / custom commands → there's no direct Zed
    equivalent; just perform the underlying task manually (e.g. run the same
    terminal commands the slash command would have run).
  - `.claude/settings*.json` `permissions.allow` entries (e.g.
    `"Bash(npm run build)"`) → treat these as a signal of which terminal
    commands are expected/safe to run in that project; use the `terminal`
    tool for the equivalent command.
  - Any Claude-specific "memory"/context file references → read the
    referenced file directly with the file-reading tool instead of relying on
    Claude's automatic context injection.
- If a project has both a top-level `CLAUDE.md`/`AGENTS.md` and a `.claude/`
  directory with additional docs, read both — the top-level file is usually
  the entry point and links out to the detailed docs.

## Keep technical implementation detail out of issue tracker descriptions

- When creating or updating a ticket in an issue tracker (Linear, Jira,
  GitHub Issues, etc.), the **description** is written for QA, product and
  other non-implementers. Keep it focused on *what* the change is and *how it
  will be verified*: the user story, acceptance criteria, reproduction steps,
  expected vs actual behaviour, impact, and business-facing notes.
- **Do not put technical implementation details in the description** — no
  file paths, function/component/class names, API or GraphQL field names, DB
  collections/schemas, migration plans, library choices, code snippets, or
  step-by-step implementation approaches. They add noise and make the ticket
  harder for QA to use.
- **Put technical detail in a comment on the ticket instead.** Implementation
  notes, technical decisions, trade-offs, spike findings, and code references
  are worth recording — add them as a comment (via the relevant MCP/tool),
  not in the description.
- **Keep any "Notes" section business-facing** — constraints, dependencies,
  risks and links a non-engineer needs. Anything only an engineer would care
  about belongs in a comment.
- **The same rule applies to updates** — as work develops, description edits
  should only refine the story/acceptance criteria; evolving technical detail
  goes in comments.
