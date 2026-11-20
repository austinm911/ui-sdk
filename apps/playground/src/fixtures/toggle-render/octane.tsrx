"use strong"
import { Button } from "@ui-sdk/octane/button"
import { Separator } from "@ui-sdk/octane/separator"
import { Toggle, ToggleGroup, type ToggleState } from "@ui-sdk/octane/toggle"
import * as React from "octane"
import { createRoot } from "octane"

const span = (props: Record<string, unknown>) => <span {...props} />

function Fixture() {
  const [action, setAction] = React.useState("")
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Button className="button" render={span} onClick={() => setAction("span")}>
        {"Span button"}
      </Button>
      <Button
        className="button"
        disabled
        render={(props) => <a {...props} href="#old" />}
      >
        {"Old docs"}
      </Button>
      <Toggle
        className={(state) =>
          `toggle ${state.pressed ? "is-pressed" : "is-unpressed"}`
        }
        onPressedChange={(pressed) => setAction(pressed ? "star" : "unstar")}
      >
        {(state: ToggleState) => (
          <>
            <span aria-hidden="true">{state.pressed ? "★" : "☆"}</span>
            {" Star"}
          </>
        )}
      </Toggle>
      <ToggleGroup
        className="toggle-group"
        aria-label="View"
        defaultValue={["grid"]}
        onValueChange={(value) => setAction(value.join(", "))}
      >
        <Toggle className="toggle" value="grid" render={span}>
          {"Grid"}
        </Toggle>
        <Toggle className="toggle" value="list" render={span}>
          {"List"}
        </Toggle>
      </ToggleGroup>
      <Separator className="rule" render={(props) => <hr {...props} />} />
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
