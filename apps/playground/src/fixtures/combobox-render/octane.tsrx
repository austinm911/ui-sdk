"use strong"
import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxLabel,
  ComboboxList,
  ComboboxTrigger,
} from "@ui-sdk/octane/combobox"
import { createRoot } from "octane"
import { comboboxFixture as f } from "tests/fixtures/combobox.ts"

const items = f.items.slice(0, 3)

// Parts rendered as other elements, with render functions and class names of state.
function Fixture() {
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Combobox name={f.name}>
        <ComboboxLabel className="label">{f.label}</ComboboxLabel>
        <ComboboxInput
          className={(state) => `input ${state.open ? "is-open" : "is-closed"}`}
        />
        <ComboboxTrigger aria-label={f.trigger}>{"▾"}</ComboboxTrigger>
        <ComboboxContent className="popup list-popup">
          <ComboboxList>
            <ComboboxItem
              className="item"
              value="docs"
              label="Docs"
              render={(props) => <a href="#docs" {...props} />}
            >
              {"Docs"}
            </ComboboxItem>
            @for (const item of items; key item.value) {
              <ComboboxItem
                className="item"
                value={item.value}
                label={item.label}
                render={(props, state) => (
                  <div {...props}>
                    {item.label}
                    {state.highlighted ? " ←" : ""}
                  </div>
                )}
              />
            }
          </ComboboxList>
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
