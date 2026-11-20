"use strong"
import {
  fromText,
  toText,
  TokenInput,
  TokenInputEditor,
  TokenInputToken,
  TokenInputTokenRemove,
} from "@ui-sdk/octane/token-input"
import {
  type TriggerMenuContentState,
  type TriggerMenuDataItem,
  TriggerMenu,
  TriggerMenuContent,
  TriggerMenuHint,
  TriggerMenuItem,
  TriggerMenuList,
} from "@ui-sdk/octane/trigger-menu"
import * as React from "octane"
import { createRoot } from "octane"
import {
  pendingSelect,
  tokenInputFixture as f,
  tokenInputOptions,
  tokenTriggers,
} from "tests/fixtures/token-input.ts"

function Fixture() {
  const { value, pending, fail, form, otherForm, controlled, ...options } =
    React.useInitialValue(tokenInputOptions)
  const [action, setAction] = React.useState("")
  const [submitted, setSubmitted] = React.useState("")
  const triggers = React.useInitialValue(tokenTriggers)
  const initial = React.useInitialValue(() => fromText(value))
  const [current, setCurrent] = React.useState(() => initial)
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
              new FormData(event.currentTarget as HTMLFormElement).get(f.name)
            )
          )
        }}
      >
        <TokenInput
          {...options}
          name={f.name}
          form={otherForm ? "other" : undefined}
          defaultValue={controlled ? undefined : initial}
          value={controlled ? current : undefined}
          onValueChange={(next, details) => {
            setCurrent(next)
            setAction(`${details.reason}:${toText(next)}`)
          }}
          onSubmit={form ? undefined : (next) => setSubmitted(toText(next))}
          renderToken={(token) => (
            <TokenInputToken className="token">
              {token.label}
              <TokenInputTokenRemove>{" ×"}</TokenInputTokenRemove>
            </TokenInputToken>
          )}
        >
          <label className="label" id="prompt-label">
            {f.label}
          </label>
          <TokenInputEditor
            aria-labelledby="prompt-label"
            className="editor"
            placeholder={f.placeholder}
          />
          <TriggerMenu
            triggers={triggers}
            onSelect={(selected, details) =>
              pending && details.trigger === "@"
                ? pendingSelect({ fail })
                : undefined
            }
          >
            <TriggerMenuHint className="hint" />
            <TriggerMenuContent className="popup list-popup">
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
        </TokenInput>
        <button type="submit">{f.submit}</button>
      </form>
      @if (otherForm) {
        <form
          id="other"
          aria-label="Other"
          onSubmit={(event: SubmitEvent) => {
            event.preventDefault()
            setSubmitted(
              `other:${new FormData(event.currentTarget as HTMLFormElement).get(f.name)}`
            )
          }}
        />
      }
      <textarea aria-label={f.scratch} />
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
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
