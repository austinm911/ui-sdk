"use strong"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"
import { createRoot } from "octane"
import {
  countRender,
  mountWhenAsked,
  perfItems,
  perfSize,
} from "tests/fixtures/perf.ts"

// A long select for the counts specs. Every other option reads
// `highlighted` in its render function, so specs can tell plain options'
// renders from watched ones.
const items = perfItems(perfSize())
const rows = items.map((item, index) => ({ item, watched: index % 2 === 1 }))

function Fixture() {
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Select defaultValue={items[0].value}>
        <SelectTrigger aria-label="Pick" className="trigger">
          <SelectValue />
        </SelectTrigger>
        <SelectContent className="popup list-popup">
          @for (const row of rows; key row.item.value) {
            @if (row.watched) {
              <SelectItem
                className="item"
                value={row.item.value}
                label={row.item.label}
                render={(props, state) => {
                  countRender("watched")
                  return (
                    <div {...props}>
                      {state.highlighted ? "→ " : ""}
                      {props.children}
                    </div>
                  )
                }}
              >
                {row.item.label}
              </SelectItem>
            } @else {
              <SelectItem
                className="item"
                value={row.item.value}
                label={row.item.label}
                render={(props) => {
                  countRender("plain")
                  return <div {...props} />
                }}
              >
                {row.item.label}
              </SelectItem>
            }
          }
        </SelectContent>
      </Select>
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  mountWhenAsked(root, (target) => createRoot(target).render(<Fixture />))
}

export { mount }
