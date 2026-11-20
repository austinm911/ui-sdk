"use strong"
import {
  createOTPInputController,
  OTPInput,
  OTPInputGroup,
  OTPInputSeparator,
  OTPInputSlot,
} from "@ui-sdk/octane/otp-input"
import * as React from "octane"
import { createRoot } from "octane"
import {
  otpInputAction,
  otpInputFixture,
  otpInputOptions,
} from "tests/fixtures/otp-input.ts"

const controller = createOTPInputController()

// The code's slots in their groups, each slot by its index in the code.
const groups = otpInputFixture.code.groups.map((size, id, sizes) => {
  const start = sizes.slice(0, id).reduce((sum, each) => sum + each, 0)
  return { id, slots: Array.from({ length: size }, (_, at) => start + at) }
})
const recoverySlots = Array.from(
  { length: otpInputFixture.recovery.length },
  (_, slot) => slot
)

function Fixture() {
  const [action, setAction] = React.useState("")
  const [submitted, setSubmitted] = React.useState("")
  const { cancel, ...options } = React.useInitialValue(otpInputOptions)
  const { code, recovery, form } = otpInputFixture
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <form
        aria-label={form.label}
        onSubmit={(event: SubmitEvent) => {
          event.preventDefault()
          setSubmitted(String(new FormData(event.currentTarget as HTMLFormElement).get(code.name)))
        }}
      >
        <OTPInput
          className="otp"
          aria-label={code.label}
          name={code.name}
          maxLength={code.length}
          controller={controller}
          {...options}
          onValueChange={(value, details) => {
            if (cancel && value.includes(cancel)) {
              return details.cancel()
            }
            setAction(otpInputAction.change(value, details.reason))
          }}
          onValueCommit={(value) => setAction(otpInputAction.complete(value))}
        >
          @for (const group of groups; key group.id) {
            <>
              @if (group.id > 0) {
                <OTPInputSeparator className="otp-separator">
                  {"-"}
                </OTPInputSeparator>
              }
              <OTPInputGroup className="otp-group">
                @for (const slot of group.slots; key slot) {
                  <OTPInputSlot index={slot} className="otp-slot" />
                }
              </OTPInputGroup>
            </>
          }
        </OTPInput>
        <button type="submit">{form.submit}</button>
        <button type="reset">{form.reset}</button>
      </form>
      <OTPInput
        className="otp"
        aria-label={recovery.label}
        maxLength={recovery.length}
        pattern="alphanumeric"
      >
        <OTPInputGroup className="otp-group">
          @for (const slot of recoverySlots; key slot) {
            <OTPInputSlot index={slot} className="otp-slot" />
          }
        </OTPInputGroup>
      </OTPInput>
      <button onClick={() => controller.setValue(otpInputFixture.filled)}>
        {"Fill code"}
      </button>
      <button onClick={() => controller.clear()}>{"Clear code"}</button>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <output aria-label="Submitted">{submitted}</output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
