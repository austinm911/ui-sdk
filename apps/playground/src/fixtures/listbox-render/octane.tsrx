"use strong"
import { Listbox, ListboxItem } from "@ui-sdk/octane/listbox"
import * as React from "octane"
import { createRoot } from "octane"
import { listboxAction, listboxFixture as f } from "tests/fixtures/listbox.ts"

// Counts each item's renders, so a spec can check that moving focus renders
// only the items whose tab stop or selection changed.
const renders: Record<string, number> = {}
;(window as unknown as { __renders: typeof renders }).__renders = renders
const counted = (name: string) => () => {
  renders[name] = (renders[name] ?? 0) + 1
  return name
}

const items = f.items.slice(0, 3)

// Parts rendered as other elements, with render functions and class names of state.
function Fixture() {
  const [action, setAction] = React.useState("")
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Listbox
        aria-label={f.label}
        className="listbox"
        activation="manual"
        onValueChange={(value) => setAction(listboxAction(value))}
        render={(props) => <ul {...props} />}
      >
        <ListboxItem
          className="item"
          value="docs"
          render={(props) => <a href="#docs" {...props} />}
        >
          {"Docs"}
        </ListboxItem>
        <ListboxItem
          value="star"
          className={(state) =>
            `item ${state.selected ? "is-selected" : "is-unselected"}`
          }
          render={(props, state) => (
            <li {...props}>{`${state.selected ? "★" : "☆"} Star`}</li>
          )}
        />
        @for (const item of items; key item.value) {
          <ListboxItem
            className="item"
            value={item.value}
            render={(props) => <li {...props} />}
            // A prop, since Octane compiles a call between tags into a
            // render block, which never sees the item's state.
            children={counted(item.label)}
          />
        }
      </Listbox>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
