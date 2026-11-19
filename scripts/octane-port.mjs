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

// Octane has no synthetic onChange: text controls fire onInput per keystroke.
const inputEvent = (source) => replaceOnce(source, 'input: "onChange",', 'input: "onInput",')

const OVERRIDES = {
  "use-primitive.tsx": (source) => inputEvent(oneIdPerPart(nativeEvents(source))),
  "button.tsx": nativeEvents,
}

// Octane compiles JSX children into a render function, so "children is a function"
// no longer means a function of the part's state. `isStateFunction` excludes them.
const childrenTest = /typeof ((?:[\w.?]+\.)?children) === "function"/g
const stateFunctionHelper = `import { isChildrenBlock } from "octane"

function isStateFunction<T>(value: T): value is Extract<T, (...args: never[]) => unknown> {
  return typeof value === "function" && !isChildrenBlock(value)
}
`
const stateFunctions = (source) => {
  if (!source.match(childrenTest)) return source
  return stateFunctionHelper + source.replace(childrenTest, "isStateFunction($1)")
}

// React runs a hook with no dependency list on every render. Octane infers one
// from the closure instead, and \`null\` means every render, so each such call
// gets \`null\`. Scans to the call's closing paren, skipping strings and comments.
const everyRender = /\b(?:React\.)?(useEffect|useLayoutEffect|useInsertionEffect|useImperativeHandle)\(/g
const argCount = { useEffect: 1, useLayoutEffect: 1, useInsertionEffect: 1, useImperativeHandle: 2 }
// Index of the paren, bracket or brace that closes the one before \`i\`, and the
// top-level argument count, skipping strings and comments.
const closing = (source, i) => {
  let depth = 0
  let args = 1
  for (; i < source.length; i++) {
    const c = source[i]
    if (c === "/" && source[i + 1] === "/") i = source.indexOf("\n", i)
    else if (c === "/" && source[i + 1] === "*") i = source.indexOf("*/", i) + 1
    else if (c === '"' || c === "'" || c === "\`") {
      for (i++; source[i] !== c; i++) if (source[i] === "\\") i++
    } else if ("([{".includes(c)) depth++
    else if (")]}".includes(c)) {
      if (depth === 0) return { end: i, args }
      depth--
    } else if (c === "," && depth === 0 && source.slice(i + 1).trimStart()[0] !== ")") args++
  }
  throw new Error("octane-port: unbalanced call")
}

const reactDeps = (source) => {
  let out = ""
  let last = 0
  for (const match of source.matchAll(everyRender)) {
    const { end: close, args } = closing(source, match.index + match[0].length)
    if (args === argCount[match[1]]) {
      const end = source.slice(0, close).trimEnd().replace(/,$/, "").length
      out += source.slice(last, end) + ", null"
      last = end
    }
  }
  return out + source.slice(last)
}

// React runs a hook written as a JSX child, like \`<Context value>{usePart(...)}</Context>\`,
// while the component renders. Octane compiles children into a scope of their own,
// which then owns the hook's state, so the call moves above the \`return\`.
const jsxHook = /\{\s*((?:React\.)?use[A-Z]\w*)\(/g
const hoistJsxHooks = (source) => {
  let count = 0
  for (let match; (match = jsxHook.exec(source)); ) {
    const open = match.index + match[0].length
    const { end } = closing(source, open)
    const after = source.slice(end + 1).trimStart()
    // A JSX child follows a tag or another hoisted child.
    const before = source.slice(0, match.index).trimEnd()
    if (after[0] !== "}" || !(before.endsWith(">") || /\{jsxHook\d+\}$/.test(before))) continue
    const call = source.slice(match.index + 1, end + 1).trim()
    const ret = source.lastIndexOf("\n", source.lastIndexOf("return", match.index)) + 1
    const indent = source.slice(ret).match(/^\s*/)[0]
    const name = `jsxHook${count++}`
    const closeBrace = source.indexOf("}", end + 1)
    source =
      source.slice(0, ret) +
      `${indent}const ${name} = ${call}\n` +
      source.slice(ret, match.index) +
      `{${name}}` +
      source.slice(closeBrace + 1)
    jsxHook.lastIndex = 0
  }
  return source
}

// A component that reads its children, for an item's text or for which parts the
// markup places, gets them as elements and strings, as in React, through
// Octane's \`descriptorChildren\`. Otherwise they arrive as a compiled render body.
const inspectsChildren = /\b(hasChild|learnLabels|textToMark)\(/
const descriptorComponents = (source) => {
  let changed = false
  for (let at = 0; (at = source.indexOf("\nfunction ", at)) !== -1; ) {
    const start = at + 1
    const name = source.slice(start + 9).match(/^[A-Z]\w*/)?.[0]
    // The parameter list may hold braces, so the body is the brace after \`) {\`.
    const open = source.slice(start).search(/\)(?::[^{]*)?\s*\{\n/) + start
    const brace = source.indexOf("{", open)
    const { end } = closing(source, brace + 1)
    at = end
    if (!name || !inspectsChildren.test(source.slice(brace, end))) continue
    source =
      source.slice(0, start) +
      `const ${name} = descriptorChildren(` +
      source.slice(start, end + 1) +
      ")" +
      source.slice(end + 1)
    changed = true
  }
  return changed ? `import { descriptorChildren } from "octane"\n` + source : source
}

// The adapter.
const from = join(root, "packages/react/src")
const to = join(root, "packages/octane/src")
rmSync(to, { recursive: true, force: true })
mkdirSync(to, { recursive: true })
for (const file of readdirSync(from)) {
  let source = rewrite(readFileSync(join(from, file), "utf8"))
  source = OVERRIDES[file]?.(source) ?? source
  writeFileSync(join(to, file), pragma + descriptorComponents(hoistJsxHooks(reactDeps(stateFunctions(source)))))
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

// A fixture's text field listens to onInput, Octane's per-keystroke event.
// Checkboxes keep onChange, which fires per toggle in both.
const textInputs = (source) =>
  source.replace(/onChange=\{([^}]*)\}/g, (all, handler) => (handler.includes("checked") ? all : `onInput={${handler}}`))

// Octane has no Profiler. Specs read its commit count on React only.
const fixtureOnly = (source) =>
  textInputs(source).replace(/<React\.Profiler\b[\s\S]*?\}>/g, "<>").replaceAll("</React.Profiler>", "</>")

// The fixtures: each React fixture's Octane twin, unless one is written by hand (`octane.manual.tsx`).
const fixtures = join(root, "apps/playground/src/fixtures")
let count = 0
for (const name of readdirSync(fixtures)) {
  const react = join(fixtures, name, "react.tsx")
  if (!existsSync(react) || existsSync(join(fixtures, name, "octane.manual.tsx"))) continue
  writeFileSync(join(fixtures, name, "octane.tsx"), pragma + reactDeps(fixtureOnly(rewrite(readFileSync(react, "utf8")))))
  count += 1
}
console.log(`octane-port: ${readdirSync(to).length} adapter files, ${count} fixtures`)
