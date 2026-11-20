"use strong"
import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxLabel,
  ComboboxList,
  type ComboboxContentState,
} from "@ui-sdk/octane/combobox"
import * as React from "octane"
import { createRoot } from "octane"
import { longItems, scrollForRow, visibleRows } from "tests/fixtures/select.ts"

const items = longItems()
const row = 32
const height = 240

// The rows in view, out of every item that shows.
function Rows({
  state,
  scrollTop,
}: {
  state: ComboboxContentState
  scrollTop: number
}) {
  const visible = state.items as { value: string; label: string }[]
  const { start, end } = visibleRows(scrollTop, height, visible.length, row)
  const rows = visible
    .slice(start, end)
    .map((item, offset) => ({ item, index: start + offset }))
  return (
    <div style={{ height: visible.length * row, position: "relative" }}>
      @for (const { item, index } of rows; key item.value) {
        <ComboboxItem
          className="item"
          value={item.value}
          label={item.label}
          index={index}
          style={{
            position: "absolute",
            top: index * row,
            height: row,
            left: 0,
            right: 0,
          }}
        >
          {item.label}
        </ComboboxItem>
      }
    </div>
  )
}

// 10,000 items, rendering only the rows in view. The combobox navigates and
// filters every item, and tells the list which row to scroll to.
function Fixture() {
  const scroller = React.useRef<HTMLDivElement>(null)
  const [scrollTop, setScrollTop] = React.useState(0)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Combobox
        items={items}
        onHighlight={(value, { index }) => {
          const el = scroller.current
          if (el && index >= 0) {
            el.scrollTop = scrollForRow(index, el.scrollTop, height, row)
          }
        }}
      >
        <ComboboxLabel className="label">{"Item"}</ComboboxLabel>
        <ComboboxInput className="input" />
        <ComboboxContent className="popup">
          <div
            ref={scroller}
            className="long-list"
            style={{ height }}
            onScroll={(event: Event) =>
              setScrollTop((event.currentTarget as HTMLDivElement).scrollTop)
            }
          >
            <ComboboxList style={{ position: "relative", height: "auto" }}>
              {(state: ComboboxContentState) => (
                <Rows state={state} scrollTop={scrollTop} />
              )}
            </ComboboxList>
          </div>
        </ComboboxContent>
      </Combobox>
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
