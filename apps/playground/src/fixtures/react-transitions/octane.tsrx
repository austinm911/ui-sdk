"use strong"
import { Checkbox, CheckboxGroup } from "@ui-sdk/octane/checkbox"
import {
  Menu,
  MenuContent,
  MenuRadioGroup,
  MenuRadioItem,
  MenuTrigger,
} from "@ui-sdk/octane/menu"
import { Toggle, ToggleGroup } from "@ui-sdk/octane/toggle"
import * as React from "octane"
import { createRoot } from "octane"

// A controlled group, changed in a transition, whose newly selected item
// suspends as it renders selected. ?group= picks menu, toggle or checkbox.
// The page counts the item's tries to render its details, and marks the body
// once the fallback shows. `window.loadDetails()` lets the details through.

// Render reads no browser globals, so the tries count in a module object
// that the window reads through a getter.
const tries = { details: 0 }
const details = new Promise<void>((resolve) =>
  Object.defineProperties(window, {
    detailsRendered: { get: () => tries.details },
    loadDetails: { value: resolve },
  })
)

function Details() {
  tries.details++
  React.use(details)
  return <span>{" details"}</span>
}

function Fallback() {
  React.useLayoutEffect(() => {
    document.body.dataset.fellBack = ""
  })
  return <p>{"Loading"}</p>
}

function Group({
  value,
  choose,
}: {
  value: string
  choose: (value: string) => void
}) {
  // The page's group, read once, as the page's URL never changes.
  const group = React.useInitialValue(() =>
    new URLSearchParams(location.search).get("group")
  )
  if (group === "toggle") {
    return (
      <ToggleGroup
        value={[value]}
        onValueChange={([next]) => next && choose(next)}
      >
        <Toggle value="left">{"Left"}</Toggle>
        <Toggle value="right">
          {(state: { pressed: boolean }) => (
            <>
              {"Right"}
              @if (state.pressed) {
                <Details />
              }
            </>
          )}
        </Toggle>
      </ToggleGroup>
    )
  }
  if (group === "checkbox") {
    return (
      <CheckboxGroup
        value={[value]}
        onValueChange={(next) =>
          choose(next.find((item) => item !== value) ?? value)
        }
      >
        <Checkbox value="left" aria-label="Left" />
        <Checkbox value="right" aria-label="Right">
          {(state: { checked: boolean | "indeterminate" }) => (
            <>
              @if (state.checked === true) {
                <Details />
              }
            </>
          )}
        </Checkbox>
      </CheckboxGroup>
    )
  }
  return (
    <Menu defaultOpen modal={false}>
      <MenuTrigger>{"Align"}</MenuTrigger>
      <MenuContent>
        <MenuRadioGroup value={value} onValueChange={choose}>
          <MenuRadioItem value="left" closeOnSelect={false}>
            {"Left"}
          </MenuRadioItem>
          <MenuRadioItem value="right" closeOnSelect={false}>
            {(state: { checked: boolean }) => (
              <>
                {"Right"}
                @if (state.checked) {
                  <Details />
                }
              </>
            )}
          </MenuRadioItem>
        </MenuRadioGroup>
      </MenuContent>
    </Menu>
  )
}

function Fixture() {
  const [value, setValue] = React.useState("left")
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <React.Suspense fallback={<Fallback />}>
        <Group
          value={value}
          choose={(next) => React.startTransition(() => setValue(next))}
        />
      </React.Suspense>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
