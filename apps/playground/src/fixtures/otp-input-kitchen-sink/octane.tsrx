"use strong"
import {
  createOTPInputController,
  OTPInput,
  OTPInputGroup,
  OTPInputSeparator,
  OTPInputSlot,
  type OTPInputSlotState,
} from "@ui-sdk/octane/otp-input"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { formData, kitchenSink, type Env } from "./shell"
import {
  groupStarts,
  maxLengthOf,
  patterns,
  presets,
  type Variant,
} from "./variants"

const masked = (state: OTPInputSlotState) => (state.char ? "•" : "")

function Slots({ variant }: { variant: Variant }) @{
  const starts = groupStarts(variant)
  // Each group with its slots, every slot by its index in the code.
  const groups = variant.groups.map((size, group) => ({
    group,
    slots: Array.from({ length: size }, (_, offset) => starts[group] + offset),
  }))
  @for (const { group, slots } of groups; key group) {
    <>
      @if (group > 0) {
        <OTPInputSeparator className={classes.separator}>{"-"}</OTPInputSeparator>
      }
      <OTPInputGroup className={classes.group}>
        @for (const slot of slots; key slot) {
          <OTPInputSlot
            index={slot}
            className={classes.slot}
            children={variant.masked ? masked : undefined}
          />
        }
      </OTPInputGroup>
    </>
  }
}

function VariantOTPInput({ variant, env }: { variant: Variant; env: Env }) {
  const { defaultValue, ...options } = variant.options ?? {}
  const [value, setValue] = React.useState(() => defaultValue ?? "")
  const [invalid, setInvalid] = React.useState(() => !!variant.invalid)
  const controller = React.useInitialValue(() =>
    variant.controller ? createOTPInputController() : undefined
  )
  React.useEffect(() => {
    if (controller) {
      env.controls([
        ["setValue(123456)", () => controller.setValue("123456")],
        ["clear()", () => controller.clear()],
        ["focus()", () => controller.focus()],
        ["getValue()", () => controller.getValue()],
      ])
    } else if (variant.controlled) {
      env.controls(
        presets[variant.controlled].map(([label, next]) => [
          label,
          () => void setValue(next),
        ])
      )
    }
  })

  const otp = (
    <OTPInput
      className={classes.root}
      aria-label="Verification code"
      {...options}
      {...(variant.controlled ? { value } : { defaultValue })}
      maxLength={maxLengthOf(variant)}
      pattern={variant.pattern && patterns[variant.pattern]}
      controller={controller}
      debug={variant.debug}
      aria-invalid={invalid || undefined}
      onValueChange={(next, details) => {
        if (variant.cancel && next.includes(variant.cancel)) {
          return details.cancel()
        }
        env.log(`valueChange "${next}" (${details.reason})`)
        if (variant.controlled) {
          setValue(
            variant.controlled === "uppercase" ? next.toUpperCase() : next
          )
        }
        if (variant.verify) {
          setInvalid(false)
        }
      }}
      onValueCommit={(next) => {
        env.log(`complete "${next}"`)
        if (variant.verify) {
          setInvalid(next !== variant.verify)
        }
      }}
    >
      <Slots variant={variant} />
    </OTPInput>
  )
  if (variant.place === "fieldset") {
    return <fieldset disabled>{otp}</fieldset>
  }
  if (!variant.form) {
    return otp
  }
  return (
    <form
      className={classes.form}
      onSubmit={(event: SubmitEvent) => {
        event.preventDefault()
        env.log(`submit ${formData(event.currentTarget as HTMLFormElement)}`)
      }}
      onReset={() => env.log("reset")}
      onInvalidCapture={(event: Event) =>
        env.log(
          `invalid: ${(event.target as HTMLInputElement).validationMessage}`
        )
      }
    >
      {otp}
      <div className={classes.row}>
        <button className={classes.button}>{"Submit"}</button>
        <button type="reset" className={classes.button}>
          {"Reset"}
        </button>
      </div>
    </form>
  )
}

function mount(root: HTMLElement) {
  kitchenSink(root, "octane", (slot, variant, env) =>
    createRoot(slot).render(<VariantOTPInput variant={variant} env={env} />)
  )
}

export { mount }
