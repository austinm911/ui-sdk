"use strong"
import { meter, type MeterValueState } from "@ui-sdk/core/meter"
import { createParts, type PartProps } from "./use-primitive.tsrx"

const parts = createParts(meter, {
  root: "div",
  track: "div",
  indicator: "div",
  label: "span",
  value: "span",
})

/**
 * The root, which is the meter.
 * @stable
 */
const Meter = parts.Root

/**
 * The rail the indicator fills.
 * @stable
 */
const MeterTrack = parts.Track

/**
 * The filled part of the track, as wide as the value.
 * @stable
 */
const MeterIndicator = parts.Indicator

/**
 * Names the meter.
 * @stable
 */
const MeterLabel = parts.Label

const text = (state: MeterValueState) => state.text

/**
 * The formatted value, like "40%". Children replace it.
 * @stable
 */
function MeterValue({
  children = text,
  ...props
}: PartProps<"span", MeterValueState>) {
  // Passed as a prop, so a function of the state reaches the part as one
  // rather than as a compiled child block.
  const Value = parts.Value
  return <Value {...props} children={children} />
}

export type {
  MeterLabelDetails,
  MeterOptions,
  MeterPrimitive,
  MeterState,
  MeterValueState,
  NumberFormat,
} from "@ui-sdk/core/meter"

export { Meter, MeterIndicator, MeterLabel, MeterTrack, MeterValue }
