"use strong"
import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTitle,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import { createRoot } from "octane"

function Fixture() {
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Popover>
        <PopoverTrigger
          className={(state) => (state.open ? "is-open" : "is-closed")}
          render={(props, state) => (
            <button {...props}>
              {"Details "}
              <span aria-hidden="true">{state.open ? "▲" : "▼"}</span>
            </button>
          )}
        />
        <PopoverContent className="popup">
          <PopoverTitle render={(props) => <h3 {...props} />}>
            {"Shipping"}
          </PopoverTitle>
          <PopoverClose render={(props) => <a href="#done" {...props} />}>
            {"Done"}
          </PopoverClose>
        </PopoverContent>
      </Popover>
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
