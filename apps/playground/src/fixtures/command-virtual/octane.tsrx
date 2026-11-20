"use strong"
import {
  Command,
  CommandInput,
  CommandItem,
  CommandList,
  type CommandListState,
} from "@ui-sdk/octane/command"
import * as React from "octane"
import { createRoot } from "octane"
import { longItems, scrollForRow, visibleRows } from "tests/fixtures/select.ts"

const items = longItems()
const row = 32
const height = 240

// The rows in view, out of every command that shows.
function Rows({
  state,
  scrollTop,
}: {
  state: CommandListState
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
        <CommandItem
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
        </CommandItem>
      }
    </div>
  )
}

// 10,000 commands, rendering only the rows in view. The command ranks and
// moves through every one, and its value change says which row to scroll to.
function Fixture() {
  const scroller = React.useRef<HTMLDivElement>(null)
  const [scrollTop, setScrollTop] = React.useState(0)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Command
        className="command"
        items={items}
        onValueChange={(value, { index }) => {
          const el = scroller.current
          if (el && index >= 0) {
            el.scrollTop = scrollForRow(index, el.scrollTop, height, row)
          }
        }}
      >
        <CommandInput className="input" aria-label="Search items" />
        <div
          ref={scroller}
          className="long-list"
          style={{ height }}
          onScroll={(event: Event) =>
            setScrollTop((event.currentTarget as HTMLDivElement).scrollTop)
          }
        >
          <CommandList
            style={{
              position: "relative",
              maxHeight: "none",
              overflow: "visible",
            }}
          >
            {(state: CommandListState) => (
              <Rows state={state} scrollTop={scrollTop} />
            )}
          </CommandList>
        </div>
      </Command>
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
