"use strong"
import { Textarea } from "@ui-sdk/octane/textarea"
import {
  type TriggerMenuContentState,
  type TriggerMenuDataItem,
  TriggerMenu,
  TriggerMenuContent,
  TriggerMenuEmpty,
  TriggerMenuHint,
  TriggerMenuInput,
  TriggerMenuItem,
  TriggerMenuList,
  TriggerMenuStatus,
} from "@ui-sdk/octane/trigger-menu"
import * as React from "octane"
import { createRoot } from "octane"
import {
  fixtureTriggers,
  selectAction,
  triggerMenuFixture as f,
  triggerMenuOptions,
} from "tests/fixtures/trigger-menu.ts"

// The input as an `<input>` with ?input, or a resizing Textarea with ?textarea.
const asInput = (props: Record<string, any>) => <input {...props} />
const asTextarea = (props: Record<string, any>) => (
  <Textarea autoResize {...props} />
)

function Composer({
  name,
  onAction,
  onOpen,
}: {
  name: string
  onAction: (action: string) => void
  onOpen: (open: string) => void
}) {
  const { input, textarea, empty, autoHighlight } =
    React.useInitialValue(triggerMenuOptions)
  const triggers = React.useInitialValue(fixtureTriggers)
  const id = React.useId()
  return (
    <TriggerMenu
      triggers={triggers}
      autoHighlight={autoHighlight}
      onOpenChange={(open, details) => onOpen(`${open}:${details.reason}`)}
      onSelect={(value, details) =>
        onAction(selectAction(value, details.arguments))
      }
    >
      <label className="label" htmlFor={id}>
        {name}
      </label>
      <TriggerMenuInput
        id={id}
        name="message"
        className="input"
        render={input ? asInput : textarea ? asTextarea : undefined}
      />
      <TriggerMenuHint className="hint" />
      <TriggerMenuStatus className="status" />
      <TriggerMenuContent className="popup list-popup">
        @if (empty) {
          <TriggerMenuEmpty className="empty">{f.empty}</TriggerMenuEmpty>
        }
        <TriggerMenuList>
          {(state: TriggerMenuContentState) => (
            <>
              @for (
                const item of state.items as TriggerMenuDataItem[];
                key item.value
              ) {
                <TriggerMenuItem
                  value={item.value}
                  label={item.label}
                  disabled={item.disabled}
                  className="item"
                >
                  {item.label}
                </TriggerMenuItem>
              }
            </>
          )}
        </TriggerMenuList>
      </TriggerMenuContent>
    </TriggerMenu>
  )
}

function Fixture() {
  const { twice } = React.useInitialValue(triggerMenuOptions)
  const [action, setAction] = React.useState("")
  const [open, setOpen] = React.useState("")
  const [submitted, setSubmitted] = React.useState("")
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <form
        className="composer"
        aria-label={f.formLabel}
        onSubmit={(event: SubmitEvent) => {
          event.preventDefault()
          setSubmitted(
            String(
              new FormData(event.currentTarget as HTMLFormElement).get(
                "message"
              )
            )
          )
        }}
      >
        <Composer name={f.label} onAction={setAction} onOpen={setOpen} />
        @if (twice) {
          <Composer name="Second" onAction={setAction} onOpen={setOpen} />
        }
        <button type="submit">{f.submit}</button>
      </form>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <output role="status" aria-label="Open">
        {open}
      </output>
      <output role="status" aria-label="Submitted">
        {submitted}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
