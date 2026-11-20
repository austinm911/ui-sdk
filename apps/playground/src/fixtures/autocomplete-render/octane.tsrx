"use strong"
import {
  Autocomplete,
  AutocompleteContent,
  AutocompleteInput,
  AutocompleteItem,
  AutocompleteLabel,
  AutocompleteList,
  AutocompleteTrigger,
} from "@ui-sdk/octane/autocomplete"
import { createRoot } from "octane"
import { autocompleteFixture as f } from "tests/fixtures/autocomplete.ts"

const items = f.items.slice(0, 3)

// Parts rendered as other elements, with render functions and class names of state.
function Fixture() {
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Autocomplete name={f.name}>
        <AutocompleteLabel className="label">{f.label}</AutocompleteLabel>
        <AutocompleteInput
          className={(state) => `input ${state.open ? "is-open" : "is-closed"}`}
        />
        <AutocompleteTrigger aria-label={f.trigger}>{"▾"}</AutocompleteTrigger>
        <AutocompleteContent className="popup list-popup">
          <AutocompleteList>
            <AutocompleteItem
              className="item"
              value="docs"
              label="Docs"
              render={(props) => <a href="#docs" {...props} />}
            >
              {"Docs"}
            </AutocompleteItem>
            @for (const item of items; key item.value) {
              <AutocompleteItem
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
          </AutocompleteList>
        </AutocompleteContent>
      </Autocomplete>
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
