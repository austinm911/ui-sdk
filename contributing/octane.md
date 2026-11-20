# The Octane adapter

`packages/octane` is written in Octane's own `.tsrx`, the way the Vue and
Svelte adapters use their frameworks' syntax. Every file that calls a hook or
renders markup is a `.tsrx` module that starts with `"use strong"`, Octane's
strict mode. Plain `.ts` holds only code without hooks or markup, like
contexts and re-exports. The React adapter is the model for behavior, and the
Solid adapter is the model wherever React reads its children.

Octane compiles each hook call into a slot of its own, so a hook called from a
plain `.ts` file shares its caller's slot. Keep every hook in `.tsrx`.

## Porting a component

Start from the React component and keep its parts, props, comments and order.
Then make these changes.

- **Imports.** `import * as React from "octane"`, and `createPortal` and
  `createRoot` from `"octane"`. Local modules keep their extension:
  `./use-primitive.tsrx`, `./popup.tsrx`, `./field-context.tsrx`.
- **Providers.** A context is its own provider: `<Ctx value={v}>`, never
  `<Ctx.Provider>`. Bind a context from an object to a capitalized name first:
  `const Provider = scope.context`.
- **Hooks above the markup.** Call `usePart` and every other hook before the
  `return`, and put the result in the markup: `const element = usePart(...)`,
  then `<Ctx value={v}>{element}</Ctx>`. A hook inside a JSX child runs in
  that child's scope, not the component's.
- **Effects and memos.** Omit every dependency list. The compiler infers it
  from what the callback reads, and Strong mode rejects an explicit list and
  `null`. A callback that must not re-run for a value it reads goes in
  `useEffectEvent`.
- **No state updates in effect setup,** not even in a microtask or a
  transition. Derive the value in render, use `useSyncExternalStore` for an
  outside source, or call the setter from an event or a subscription
  callback.
- **No refs read during render.** Read `ref.current` in effects and handlers.
  Initial values that never change come from `useInitialValue(() => ...)`,
  and a mutable holder from `useLazyRef`. A `useState` whose setter is
  never used is rejected.
- **No reassigned module `let`** read from render or from an effect. Keep
  module state in a `const` object and change its properties.
- **No browser globals in render,** like `location` or `window`. Read them
  in `useInitialValue`, an effect, or `useSyncExternalStore`.
- **Lists.** `@for (const item of items; key item.id) { ... }`. A key may not
  come from the loop index, so give separators and other unnamed entries an
  id from a `WeakMap` keyed by the entry object, computed in a `rows` array
  before the loop (see `list-items.tsrx`). A row may not change a variable
  declared outside the loop.
- **Conditionals.** `@if (cond) { ... } @else { ... }` in markup. A branch or
  loop body that holds more than one node, or bare text, wraps it in `<>...</>`.
  Text from a variable is `{text}`, and literal text is `{"Text"}`.
- **Children are compiled functions.** Octane passes template children as a
  render function. Never test `typeof children === "function"`. Use
  `isStateFunction(children)` from `./render-element.tsrx`, which is true only
  for a function of the part's state. Render children as `{children}`.
- **No reading children.** `createElement`, `cloneElement`, `Children`,
  `isValidElement` and `descriptorChildren` are off limits. A root that
  renders its own content part unless the app placed one uses
  `usePlacedContent` and `usePlaceContent` from `./children.tsrx`, as
  `select.tsrx` does. A root that learned labels from its children instead
  mounts its list hidden through `internal.prepare()` in an effect, as
  `Select` does.
- **`render` is a function only:** `(props, state) => <a {...props} />`.
  Drop React's element form and anything that read an element's props, like
  `ownDescription`.
- **Events are native.** Handlers receive DOM events, with no
  `nativeEvent`. React's `onChange` on text inputs is `onInput` here, and the
  element props types add `"onInput"` to each component's `Clashing` list
  where React's has `"onChange"`.
- **Popups.** A popup's content part takes the tree ref through its props:
  `const tree = usePopupTree()`, pass `ref: mergeRefs<HTMLDivElement>(ref, tree.track)` to `usePart`, and return `element && renderPopup(element,
target, tree)`. See `SelectContent`.
- **No type arguments on a JSX tag,** like `<Select<string, boolean>>`.
  Prettier's `.tsrx` parser rejects them. Let the props infer the types, or
  name an instantiation first: `const AnySelect = Select<string, boolean>`.
- **State from a prop** starts from a lazy initializer, `useState(() =>
props.value)`, since `useState(props.value)` is rejected. A remount is
  `key={value}` on the component, not a one-item `@for`.
- **Raw HTML** is `dangerouslySetInnerHTML={trustHTML(html)}`, with
  `trustHTML` imported by name from `"octane"`. `suppressHydrationWarning` is
  rejected.
- **Children as a prop.** Children written inside a part's tags reach it as a
  render function, which hides a state function and defeats a `children ??
default` fallback. Pass them on as `children={children}`.
  A child expression that holds a function, like `{error(name)}`, is
  wrapped as a children block too, so pass it as a `children={...}` prop.
- **A state function child is written inline,** `{(state) => ...}`. A
  function passed by name, like `{dataItems}`, is called as a component with
  props. Default content for `children` is a function returning the markup,
  like `defaultTriggerContent` in `select.tsrx`.
- **Render order.** Octane renders shallower components first, so a sibling
  wrapped in `@if` can bind after the part beside it. Core must not depend on
  sibling bind order.
- **Rows** that React builds with `.map` become a small component rendered
  by a keyed `@for`.
- **Types.** Content is `unknown`, not `React.ReactNode`, and a component
  returns what its JSX returns. Never use `any` beyond what the React file
  already has. A cast needs a comment that says why it holds.

`use-primitive.tsrx` deviates from Strong mode in one place. Octane runs
passive effects after paint and subscribes `useSyncExternalStore` in one
(octanejs/octane#3095), but
core needs a part subscribed at commit, since a submenu that just opened must
answer a key pressed in the same frame. Each part subscribes in a layout
effect and re-renders through a reducer, whose count it reads once with
`void`. Bind writes also run in a layout effect, before paint.

## Fixtures

Each fixture is `apps/playground/src/fixtures/<name>/octane.tsrx`, ported
from the React fixture next to it with the same rules. Mount with
`createRoot(root).render(<Fixture />)`, without `StrictMode`. Read the page's
options, like `selectOptions()`, once with `React.useInitialValue(...)`.
React-only pieces, like `React.Profiler`, are dropped.

## Checking a file

The compiler reports Strong mode errors with their rule name, like
`OCTANE_STRONG_EFFECT_STATE_UPDATE`. Compile a file from `apps/playground`:

```sh
node -e 'import("octane/compiler").then(async ({ compile }) => { const f = process.argv[1]; await compile(require("fs").readFileSync(f, "utf8"), f, {}); console.log("ok") })' <file>
```

Check types with `pnpm --filter @ui-sdk/octane typecheck`, which runs
`tsrx-tsc` over the package. Format it with `npx prettier --write <file>`, which formats `.tsrx` through
`@tsrx/prettier-plugin`. Then run the component's specs on the playground dev server:

```sh
cd tests && PLAYGROUND_PORT=<port> npx playwright test specs/<name> --project octane
```

## Parity

`node scripts/octane-parity.mjs tests/test-results/parity.json` writes
`parity/PARITY.md` from a JSON run of the `react` and `octane` projects:

```sh
cd tests && PLAYWRIGHT_JSON_OUTPUT_NAME=test-results/parity.json npx playwright test --project react --project octane --reporter=json
```
