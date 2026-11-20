"use strong"
import { Field, FieldLabel, FieldLegend, FieldSet } from "@ui-sdk/octane/field"
import {
  Input,
  InputClear,
  InputGroup,
  type InputState,
} from "@ui-sdk/octane/input"
import { Textarea, type TextareaState } from "@ui-sdk/octane/textarea"
import * as React from "octane"
import { createRoot } from "octane"

// Parts rendered as other elements, and render functions reading state.
function Fixture() {
  const [renders, setRenders] = React.useState(0)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <FieldSet className="form">
        <FieldLegend render={(props) => <div {...props} />}>{"Legend as a div"}</FieldLegend>
        <Field>
          <FieldLabel>{"Render function"}</FieldLabel>
          <Input
            className="input"
            render={(props, state: InputState) => (
              <input
                {...props}
                data-state={state.filled ? "filled" : "empty"}
              />
            )}
          />
        </Field>
        <Field>
          <FieldLabel>{"Class from state"}</FieldLabel>
          <Textarea
            autoResize
            className={(state: TextareaState) =>
              `textarea ${state.filled ? "is-filled" : "is-empty"}`
            }
          />
        </Field>
        <InputGroup className="input-group">
          <Input className="input" aria-label="Search" />
          <InputClear
            render={(props) => <span role="button" tabIndex={0} {...props} />}
            aria-label="Clear search"
          >
            {"×"}
          </InputClear>
        </InputGroup>
      </FieldSet>
      <button type="button" onClick={() => setRenders((count) => count + 1)}>
        {`Render again (${renders})`}
      </button>
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
