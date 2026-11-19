// Generates the Octane adapter and its playground fixtures from the React ones.
//
// Octane implements React's component API (hooks, context, createElement,
// cloneElement, createPortal), so the React adapter ports by rewriting its
// imports. What differs is listed in OVERRIDES and applied after the rewrite:
// Octane hands handlers the native event, where React wraps it.
//
//   node scripts/octane-port.mjs        regenerate packages/octane/src and every octane.tsx fixture
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs"
import { join } from "node:path"

const root = new URL("..", import.meta.url).pathname
const pragma = "/** @jsxImportSource octane */\n"

// Octane renders a context as its own provider: `<Context value>`, with no `.Provider`.
// A context held in a lowercase binding would then read as an HTML tag, so it renders
// through `Provide`, which `providerHelper` adds to the file.
const providerHelper = `
function Provide({ context: Context, value, children }: { context: React.Context<any>; value: unknown; children?: React.ReactNode }) {
  return <Context value={value}>{children}</Context>
}
`
const rewrite = (source) => {
  const lowercase = /<([a-z]\w*)\.Provider\b/.test(source)
  const out = rewrite2(
    source
      .replace(/<([a-z]\w*)\.Provider\b/g, "<Provide context={$1}")
      .replace(/<\/[a-z]\w*\.Provider>/g, "</Provide>"),
  )
  return lowercase ? out + providerHelper : out
}
const rewrite2 = (source) =>
  source
    .replace(/(<\/?[\w.]+)\.Provider\b/g, "$1")
    .replace(/= (\w+)\.Provider\b/g, "= $1")
    .replaceAll('from "react-dom/client"', 'from "octane"')
    .replaceAll('from "react-dom"', 'from "octane"')
    .replaceAll('from "react"', 'from "octane"')
    .replaceAll('from "@ui-sdk/react/', 'from "@ui-sdk/octane/')
    .replaceAll('from "@ui-sdk/react"', 'from "@ui-sdk/octane"')

// Octane events are the DOM's own: no `nativeEvent`, no `isDefaultPrevented()`.
const nativeEvents = (source) =>
  source
    .replaceAll("event.nativeEvent.defaultPrevented && !event.isDefaultPrevented()", "false")
    .replaceAll("event.nativeEvent", "event")

// Octane keys hooks by call site, not call order, so a hook in a loop shares one slot.
const oneIdPerPart = (source) =>
  replaceOnce(
    source,
    `      for (const key of ids) {
        const id = React.useId()
        slotProps[key] ??= id
      }`,
    `      const base = React.useId()
      for (const key of ids) {
        slotProps[key] ??= \`\${base}-\${key}\`
      }`
  )

const replaceOnce = (source, before, after) => {
  if (!source.includes(before)) throw new Error(`octane-port: upstream changed, update the override for:\n${before}`)
  return source.replace(before, after)
}

const OVERRIDES = {
  "use-primitive.tsx": (source) => oneIdPerPart(nativeEvents(source)),
  "button.tsx": nativeEvents,
}

// The adapter.
const from = join(root, "packages/react/src")
const to = join(root, "packages/octane/src")
rmSync(to, { recursive: true, force: true })
mkdirSync(to, { recursive: true })
for (const file of readdirSync(from)) {
  let source = rewrite(readFileSync(join(from, file), "utf8"))
  source = OVERRIDES[file]?.(source) ?? source
  writeFileSync(join(to, file), pragma + source)
}

// The package manifest: React's exports, Octane's peer.
const manifest = JSON.parse(readFileSync(join(root, "packages/react/package.json"), "utf8"))
manifest.name = "@ui-sdk/octane"
manifest.description = "UI SDK for Octane."
manifest.repository.directory = "packages/octane"
manifest.peerDependencies = { "@ui-sdk/core": "workspace:^", octane: ">=0.18.0" }
delete manifest.peerDependenciesMeta
manifest.devDependencies = { "@ui-sdk/core": "workspace:*", octane: "0.18.0" }
delete manifest.scripts
writeFileSync(join(root, "packages/octane/package.json"), JSON.stringify(manifest, null, 2) + "\n")

// The fixtures: each React fixture's Octane twin, unless one is written by hand (`octane.manual.tsx`).
const fixtures = join(root, "apps/playground/src/fixtures")
let count = 0
for (const name of readdirSync(fixtures)) {
  const react = join(fixtures, name, "react.tsx")
  if (!existsSync(react) || existsSync(join(fixtures, name, "octane.manual.tsx"))) continue
  writeFileSync(join(fixtures, name, "octane.tsx"), pragma + rewrite(readFileSync(react, "utf8")))
  count += 1
}
console.log(`octane-port: ${readdirSync(to).length} adapter files, ${count} fixtures`)
