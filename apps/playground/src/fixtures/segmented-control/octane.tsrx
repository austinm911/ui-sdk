"use strong"
import {
  createSegmentedControlController,
  SegmentedControl,
  SegmentedControlIndicator,
  SegmentedControlItem,
} from "@ui-sdk/octane/segmented-control"
import * as React from "octane"
import { createRoot } from "octane"
import { segmentedControlOptions } from "tests/fixtures/page.ts"
import { segmentedControlFixture } from "tests/fixtures/segmented-control.ts"

const controller = createSegmentedControlController()

const entries = (form: HTMLFormElement) =>
  Array.from(new FormData(form), ([key, value]) => `${key}=${value}`).join("&")

function Fixture() {
  const [action, setAction] = React.useState("")
  const [submitted, setSubmitted] = React.useState("")
  const { cancel, ...options } = React.useInitialValue(segmentedControlOptions)
  return (
    <form
      className="fixture"
      onSubmit={(event: SubmitEvent) => {
        event.preventDefault()
        setSubmitted(entries(event.currentTarget as HTMLFormElement))
      }}
    >
      <button type="button">{"Before"}</button>
      <SegmentedControl
        aria-label={segmentedControlFixture.label}
        name={segmentedControlFixture.name}
        controller={controller}
        {...options}
        onValueChange={(value, details) => {
          if (value === cancel) {
            return details.cancel()
          }
          setAction(`${value}:${details.reason}`)
        }}
      >
        <SegmentedControlIndicator />
        @for (const item of segmentedControlFixture.items; key item.value) {
          <SegmentedControlItem value={item.value} disabled={item.disabled}>
            {item.label}
          </SegmentedControlItem>
        }
      </SegmentedControl>
      <button type="button">{"After"}</button>
      <button type="submit">{"Save"}</button>
      <button type="reset">{"Reset"}</button>
      <button type="button" onClick={() => controller.setValue("calendar")}>
        {"Show calendar"}
      </button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <output aria-label="Submitted">{submitted}</output>
    </form>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
