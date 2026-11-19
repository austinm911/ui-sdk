# The Octane adapter

[Octane](https://octanejs.dev) implements React's component API, so `packages/octane` is generated from `packages/react` instead of written by hand. Nothing in `packages/octane/src` or a playground `octane.tsx` fixture is edited directly. A change goes to the React source or to `scripts/octane-port.mjs`, and then:

```sh
node scripts/octane-port.mjs
```

## What the port rewrites

Most of the port swaps `react` and `react-dom` imports for `octane`. Each remaining rewrite covers one place where Octane differs from React:

| Octane differs                                                                                                  | The port                                                                                                          |
| --------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| A context renders as its own provider, with no `.Provider`.                                                     | Renders `<Context value>`. A context in a lowercase binding goes through a `Provide` component.                   |
| A hook with no dependency list gets one inferred from its closure. React runs it every render.                  | Passes `null`, Octane's "every render".                                                                           |
| JSX children compile into a scope of their own, which owns any hook called there.                               | Moves a hook written as a JSX child, like `{usePart(...)}`, above the `return`.                                   |
| JSX children arrive as a compiled render function, not elements or text.                                        | Wraps components that read their children (`hasChild`, `learnLabels`, `textToMark`) in `descriptorChildren`.      |
| A compiled children function is a function, but not a function of the part's state.                             | Tests `typeof children === "function"` with `isChildrenBlock` too.                                                |
| Handlers get the native event, and there's no synthetic `onChange`. A text field fires `onInput` per keystroke. | Drops `nativeEvent`, maps core's `input` to `onInput`, and gives a controlled text field a no-op `onInput`.       |
| `useId` can't be called in a loop.                                                                              | Derives each part's id from one `useId`.                                                                          |
| A node is typed `unknown`, which swallows `(state) => node` in a union.                                         | Types those unions as `{} \| null \| undefined \| ((state) => node)`, so a children function gets its state type. |
| `useState` also returns a getter. A host's `style` may be a string.                                             | Lets the sheet header context take the getter, and spreads `style` only when it's an object.                      |

Fixtures also drop `<React.Profiler>`, which Octane lacks, import a sibling fixture's Octane module, and read a checkbox from `event.currentTarget`, which Octane types by the element. `<React.Activity>` goes through a lookup, since Octane 0.22's compiler drops `props` in a static `<Activity>` body that holds a component. Each rewrite that replaces exact upstream text throws when that text changes, so a React change that needs a new rewrite fails the port loudly.

## Parity

The `octane` Playwright project runs the same specs as `react`. Parity means Octane passes every spec React passes, exports every entry React exports, and has every React fixture:

```sh
cd tests
PLAYWRIGHT_JSON_OUTPUT_NAME=test-results/parity.json npx playwright test --project react --project octane --reporter=json
cd .. && node scripts/octane-parity.mjs tests/test-results/parity.json
```

It writes `parity/PARITY.md` and exits non-zero until Octane is at parity. Specs that run once, on React, because they don't depend on the framework ("Framework independent.") don't count.
