"use strong"
import { Checkbox, CheckboxIndicator } from "@ui-sdk/octane/checkbox"
import { Field, FieldDescription, FieldLabel } from "@ui-sdk/octane/field"
import * as React from "octane"
import { createRoot } from "octane"
import {
  fieldChoiceCardFixture as f,
  fieldChoiceCardOptions,
} from "tests/fixtures/field.ts"

function LaterCard() {
  const [ready, setReady] = React.useState(false)
  React.useEffect(() => {
    const timer = setTimeout(() => setReady(true), f.later.delay)
    return () => clearTimeout(timer)
  })
  return (
    <FieldLabel className="choice-card">
      <Field>
        @if (ready) {
          <Checkbox className="checkbox" name={f.later.name}>
            <CheckboxIndicator className="checkbox-indicator" />
          </Checkbox>
        }
        <span>{f.later.title}</span>
        <FieldDescription>{f.later.description}</FieldDescription>
      </Field>
    </FieldLabel>
  )
}

function Fixture() {
  const { alone, later } = React.useInitialValue(fieldChoiceCardOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      @for (const card of f.cards; key card.name) {
        <FieldLabel className="choice-card">
          <Field>
            <Checkbox className="checkbox" name={card.name}>
              <CheckboxIndicator className="checkbox-indicator" />
            </Checkbox>
            <span>{card.title}</span>
            <FieldDescription>{card.description}</FieldDescription>
          </Field>
        </FieldLabel>
      }
      @if (later) {
        <LaterCard />
      }
      @if (alone) {
        <FieldLabel>{f.alone}</FieldLabel>
      }
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
