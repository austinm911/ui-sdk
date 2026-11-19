// Octane's parity with React, from one Playwright JSON run of both projects.
//
//   PLAYWRIGHT_JSON_OUTPUT_NAME=../parity/run.json npx playwright test --project react --project octane --reporter=json
//   node scripts/octane-parity.mjs parity/run.json > parity/PARITY.md
//
// A test counts for parity when React passes it. Octane is at parity when it
// passes every one of those, exports every entry React exports, and has a
// fixture for every React fixture.
import { existsSync, readFileSync, readdirSync } from "node:fs"
import { join } from "node:path"

const root = new URL("..", import.meta.url).pathname
const report = JSON.parse(readFileSync(process.argv[2], "utf8"))

// Each test's outcome per project, keyed by file and title path.
const outcomes = new Map()
const walk = (suite, titles) => {
  for (const child of suite.suites ?? []) walk(child, [...titles, child.title])
  for (const spec of suite.specs ?? []) {
    for (const test of spec.tests) {
      const key = `${spec.file} › ${[...titles.slice(1), spec.title].join(" › ")}`
      const entry = outcomes.get(key) ?? { file: spec.file }
      entry[test.projectName] = test.status
      outcomes.set(key, entry)
    }
  }
}
for (const suite of report.suites) walk(suite, [suite.title])

const passes = (status) => status === "expected" || status === "flaky"
const files = new Map()
const gaps = []
for (const [key, entry] of outcomes) {
  const file = files.get(entry.file) ?? { react: 0, octane: 0 }
  if (passes(entry.react)) {
    file.react += 1
    if (passes(entry.octane)) file.octane += 1
    else gaps.push({ key, octane: entry.octane ?? "not run" })
  }
  files.set(entry.file, file)
}

const exportsOf = (pkg) =>
  Object.keys(JSON.parse(readFileSync(join(root, "packages", pkg, "package.json"), "utf8")).exports)
const octaneExports = new Set(exportsOf("octane"))
const missingExports = exportsOf("react").filter((entry) => !octaneExports.has(entry))

const fixtures = join(root, "apps/playground/src/fixtures")
const missingFixtures = readdirSync(fixtures).filter(
  (name) => existsSync(join(fixtures, name, "react.tsx")) && !existsSync(join(fixtures, name, "octane.tsx")),
)

const total = [...files.values()].reduce((sum, file) => sum + file.react, 0)
const octane = [...files.values()].reduce((sum, file) => sum + file.octane, 0)
const percent = total === 0 ? 0 : ((octane / total) * 100).toFixed(1)

const lines = [
  "# Octane parity with React",
  "",
  `Generated from ${process.argv[2]} by scripts/octane-parity.mjs. Do not edit by hand.`,
  "",
  `- Specs React passes that Octane passes: **${octane} / ${total} (${percent}%)**`,
  `- React exports Octane lacks: **${missingExports.length}**${missingExports.length ? ` (${missingExports.join(", ")})` : ""}`,
  `- React fixtures without an Octane fixture: **${missingFixtures.length}**${missingFixtures.length ? ` (${missingFixtures.join(", ")})` : ""}`,
  "",
  "## By spec file",
  "",
  "| Spec file | React passes | Octane passes |",
  "| --- | ---: | ---: |",
  ...[...files]
    .filter(([, file]) => file.react > 0)
    .sort(([a, x], [b, y]) => y.react - y.octane - (x.react - x.octane) || a.localeCompare(b))
    .map(([name, file]) => `| ${name} | ${file.react} | ${file.octane === file.react ? file.octane : `**${file.octane}**`} |`),
  "",
  "## Gaps",
  "",
  ...(gaps.length ? gaps.map((gap) => `- ${gap.key} (${gap.octane})`) : ["None."]),
  "",
]
process.stdout.write(lines.join("\n"))
if (gaps.length || missingExports.length || missingFixtures.length) process.exitCode = 1
