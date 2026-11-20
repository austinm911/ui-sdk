"use strong"
import {
  Checkbox,
  CheckboxIndicator,
  type CheckboxState,
} from "@ui-sdk/octane/checkbox"
import { Field, FieldControl, FieldLabel } from "@ui-sdk/octane/field"
import { Radio, RadioGroup } from "@ui-sdk/octane/radio"
import {
  Switch,
  SwitchThumb,
  type SwitchThumbState,
} from "@ui-sdk/octane/switch"
import * as React from "octane"
import { createRoot } from "octane"

const sizes = ["small", "large"]

function Fixture() {
  const [action, setAction] = React.useState("")
  const [nickname, setNickname] = React.useState("")
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <form
        className="form"
        aria-label="Rendering"
        onSubmit={(event: SubmitEvent) => event.preventDefault()}
      >
        <label>
          <Checkbox
            className="checkbox"
            render={(props) => <span {...props} />}
            onCheckedChange={(checked) => setAction(`span:${checked}`)}
          >
            <CheckboxIndicator className="checkbox-indicator" />
          </Checkbox>
          {"Rendered as a span"}
        </label>
        <Checkbox
          aria-label="Render function"
          render={(props, state: CheckboxState) => (
            <button {...props}>{state.checked ? "On" : "Off"}</button>
          )}
        />
        <Checkbox
          aria-label="Class from state"
          className={(state: CheckboxState) =>
            `checkbox ${state.checked ? "is-checked" : "is-unchecked"}`
          }
        />
        <label>
          <Switch className="switch" defaultChecked>
            <SwitchThumb
              render={(props, state: SwitchThumbState) => (
                <span {...props}>{state.checked ? "I" : "O"}</span>
              )}
            />
          </Switch>
          {"Labelled thumb"}
        </label>
        <RadioGroup
          aria-label="Size"
          defaultValue="small"
          onValueChange={(value) => setAction(`size:${value}`)}
        >
          @for (const value of sizes; key value) {
            <label>
              <Radio
                className="radio"
                value={value}
                render={(props) => <span {...props} />}
              />
              {value === "small" ? "Small" : "Large"}
            </label>
          }
        </RadioGroup>
        <Field>
          <FieldLabel>{"Nickname"}</FieldLabel>
          <FieldControl
            value={nickname}
            onInput={(event: Event) =>
              setNickname((event.currentTarget as HTMLInputElement).value)
            }
          />
        </Field>
      </form>
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
