"use strong"
import {
  DatePicker,
  DatePickerContent,
  DatePickerHint,
  DatePickerInput,
  DatePickerTrigger,
} from "@ui-sdk/octane/date-picker"
import {
  Field,
  FieldDescription,
  FieldError,
  FieldLabel,
} from "@ui-sdk/octane/field"
import * as React from "octane"
import { createRoot } from "octane"
import {
  datePickerFieldFixture as f,
  datePickerFieldOptions,
  datePickerFixture,
} from "tests/fixtures/date-picker.ts"

function Fixture() {
  // The page's options, read once, as the page's URL never changes.
  const { required, disabled } = React.useInitialValue(datePickerFieldOptions)
  const [submitted, setSubmitted] = React.useState("")
  const [shown, setShown] = React.useState(true)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <form
        onSubmit={(event: SubmitEvent) => {
          event.preventDefault()
          // A form's submit event comes from the form.
          const form = event.currentTarget as HTMLFormElement
          setSubmitted(JSON.stringify([...new FormData(form)]))
        }}
      >
        <Field
          className="field"
          name={datePickerFixture.name}
          disabled={disabled}
        >
          <FieldLabel>{f.label}</FieldLabel>
          @if (shown) {
            <DatePicker
              className="date-picker"
              today={datePickerFixture.today}
              required={required}
            >
              <DatePickerInput />
              <DatePickerTrigger />
              <DatePickerHint className="date-picker-hint" />
              <DatePickerContent className="date-picker-content" />
            </DatePicker>
          }
          <FieldDescription>{f.description}</FieldDescription>
          <FieldError className="field-error" />
        </Field>
        <button type="submit">{"Submit"}</button>
        <button type="button" onClick={() => setShown(false)}>
          {"Remove date picker"}
        </button>
      </form>
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
