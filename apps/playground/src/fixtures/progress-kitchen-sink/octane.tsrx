"use strong"
import {
  Progress,
  ProgressIndicator,
  ProgressLabel,
  ProgressTrack,
  ProgressValue,
  type ProgressValueState,
} from "@ui-sdk/octane/progress"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import { formats, progressSteps, valueLabels, type Variant } from "./variants"

// The props every variant passes, with named formats and value labels resolved.
const rich = (variant: Variant) => ({
  format: variant.format && formats[variant.format],
  getValueLabel: variant.valueLabel && valueLabels[variant.valueLabel],
})

const statusText = (state: ProgressValueState) =>
  `${state.text || "…"} · ${state.status}`

function VariantProgress({ variant, env }: { variant: Variant; env: Env }) {
  const [value, setValue] = React.useState(() => variant.options.value)
  // Only the step buttons change the value, so they keep the latest one here.
  const latest = React.useRef(value)
  React.useEffect(() => {
    if (!variant.steps) {
      return
    }
    env.controls(
      progressSteps.map(([label, step]) => [
        label,
        () => {
          latest.current = step(latest.current)
          setValue(latest.current)
          env.log(`value ${latest.current}`)
        },
      ])
    )
  })
  return (
    <Progress
      className={classes.root}
      {...variant.options}
      {...rich(variant)}
      value={value}
    >
      <ProgressLabel className={classes.label}>{variant.label}</ProgressLabel>
      <ProgressValue
        className={classes.value}
        children={variant.render ? statusText : undefined}
      />
      <ProgressTrack className={classes.track}>
        <ProgressIndicator className={classes.progressIndicator} />
      </ProgressTrack>
    </Progress>
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links to, so this page shows as React's.
  kitchenSink(root, "react", (slot, variant, env) =>
    createRoot(slot).render(<VariantProgress variant={variant} env={env} />)
  )
}

export { mount }
