"use strong"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"
import { createRoot } from "octane"
import { selectFixture as f } from "tests/fixtures/select.ts"

// Parts rendered as other elements, with render functions and class names of state.
function Fixture() {
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Select name={f.name} placeholder={f.placeholder}>
        <SelectLabel className="label">{f.label}</SelectLabel>
        <SelectTrigger
          className={(state) =>
            `trigger ${state.open ? "is-open" : "is-closed"}`
          }
          render={(props, state) => (
            <button {...props}>
              <SelectValue />
              <span aria-hidden="true">{state.open ? "▲" : "▼"}</span>
            </button>
          )}
        />
        <SelectContent className="popup list-popup">
          <SelectItem
            className="item"
            value="docs"
            render={(props) => <a {...props} href="#docs" />}
          >
            {"Docs"}
          </SelectItem>
          @for (const item of f.items.slice(0, 3); key item.value) {
            <SelectItem className="item" value={item.value}>
              {item.label}
            </SelectItem>
          }
        </SelectContent>
      </Select>
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
