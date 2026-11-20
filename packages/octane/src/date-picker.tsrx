"use strong"
import {
  datePicker as datePickerPrimitive,
  type DatePickerContentProps,
  type DatePickerContentState,
  type DatePickerHintState,
  type DatePickerInputProps,
  type DatePickerInputState,
  type DatePickerOptions,
  type DatePickerPresetState,
  type DatePickerState,
  type DatePickerTriggerState,
  type DatePickerValue,
} from "@ui-sdk/core/date-picker"
import * as React from "octane"
import {
  CalendarHeading,
  CalendarGrid,
  CalendarNext,
  CalendarPrevious,
} from "./calendar.tsrx"
import { CalendarContext, type CalendarHandle } from "./calendar-context"
import { useFieldControl } from "./field-context.tsrx"
import { isStateFunction } from "./render-element.tsrx"
import {
  renderPopup,
  sheetViewport,
  useOwnContainer,
  usePopupContainer,
  usePopupTree,
  type PopupContainer,
} from "./popup.tsrx"
import {
  createParts,
  extendHandle,
  mergeRefs,
  renderElement,
  slotIn,
  usePart,
  usePrimitive,
  type PartProps,
  type PrimitiveHandle,
} from "./use-primitive.tsrx"

const parts = createParts(datePickerPrimitive, { clear: "button" })

type DatePickerContextValue = PrimitiveHandle<typeof datePickerPrimitive> & {
  field: ReturnType<typeof useFieldControl>
}

const DatePickerContext = React.createContext<DatePickerContextValue | null>(
  null
)
// Where the popup renders. Set on <DatePicker> or <DatePickerContent>.
const ContainerContext = React.createContext<PopupContainer>(undefined)

function useDatePicker(part: string) {
  const context = React.useContext(DatePickerContext)
  if (!context) {
    throw new Error(`${part} must be used inside <DatePicker>.`)
  }
  return context
}

/**
 * The root, and the hidden inputs that submit ISO dates. Without children it
 * renders an input, or two in range mode, the trigger and the popup.
 * @stable
 */
function DatePicker({
  mode,
  value,
  defaultValue,
  onValueChange,
  month,
  defaultMonth,
  onMonthChange,
  open,
  defaultOpen,
  onOpenChange,
  onOpenChangeComplete,
  closeOnSelect,
  presentation,
  dismissible,
  onDismissAttempt,
  min,
  max,
  unavailable,
  disabled,
  readOnly,
  months,
  pageBy,
  locale,
  weekStartsOn,
  weekdayFormat,
  monthFormat,
  fixedWeeks,
  showOutsideDays,
  today,
  timeZone,
  minDays,
  maxDays,
  allowUnavailable,
  name,
  startName,
  endName,
  form,
  required,
  container,
  controller,
  debug,
  children,
  ...props
}: DatePickerOptions &
  Omit<PartProps<"div", DatePickerState>, "defaultValue" | "onChange">) {
  const field = useFieldControl()
  const picker = usePrimitive(datePickerPrimitive, {
    mode,
    value,
    defaultValue,
    onValueChange,
    month,
    defaultMonth,
    onMonthChange,
    open,
    defaultOpen,
    onOpenChange,
    onOpenChangeComplete,
    closeOnSelect,
    presentation,
    dismissible,
    onDismissAttempt,
    min,
    max,
    unavailable,
    disabled: disabled || field?.disabled,
    readOnly,
    months,
    pageBy,
    locale,
    weekStartsOn,
    weekdayFormat,
    monthFormat,
    fixedWeeks,
    showOutsideDays,
    today,
    timeZone,
    minDays,
    maxDays,
    allowUnavailable,
    name: name ?? field?.name,
    startName,
    endName,
    form,
    required,
    controller,
    debug,
  })
  const context = React.useMemo(() => extendHandle(picker, { field }))
  const content = (state: DatePickerState) => {
    const range = state.mode === "range"
    const submitsStart = range
      ? (startName ?? name ?? field?.name)
      : (name ?? field?.name)
    const submitsEnd = range && (endName ?? name ?? field?.name)
    return (
      <>
        @if (children === undefined) {
          <>
            <DatePickerInput />
            @if (range) {
              <DatePickerInput end />
            }
            <DatePickerTrigger />
            <DatePickerContent />
          </>
        } @else if (isStateFunction(children)) {
          <>{children(state)}</>
        } @else {
          <>{children}</>
        }
        @if (submitsStart) {
          <input {...slotIn(picker, "hidden-input", { id: "start" })} />
        }
        @if (submitsEnd) {
          <input
            {...slotIn(picker, "hidden-input", { end: true, id: "end" })}
          />
        }
      </>
    )
  }
  const element = usePart(picker, "root", {}, { ...props, children: content })
  return (
    <DatePickerContext value={context}>
      <CalendarContext value={picker as unknown as CalendarHandle}>
        <ContainerContext value={container}>{element}</ContainerContext>
      </CalendarContext>
    </DatePickerContext>
  )
}

/**
 * A text input that reads a date typed in the page's language on Enter or
 * blur. `end` makes it a range's end.
 * @stable
 */
function DatePickerInput({
  end,
  render,
  ...props
}: Omit<
  PartProps<"input", DatePickerInputState>,
  "value" | "defaultValue" | "children" | "readOnly"
> &
  DatePickerInputProps) {
  const picker = useDatePicker("DatePickerInput")
  // Field names the first input. The core writes the text as it changes, so Octane only renders where it starts.
  const input = (merged: Record<string, any>, state: DatePickerInputState) => {
    const field = picker.field && !end ? picker.field : undefined
    const { value, ...rest }: Record<string, any> = field
      ? field.props(merged)
      : merged
    return renderElement(
      "input",
      { ...rest, defaultValue: value },
      render,
      state
    )
  }
  return usePart(
    picker,
    "input",
    { end, id: end ? "end" : "start" },
    { ...props, render: input },
    "input"
  )
}

const calendarIcon = () => (
  <svg
    width="16"
    height="16"
    viewBox="0 0 16 16"
    fill="none"
    stroke="currentColor"
    aria-hidden="true"
  >
    <rect x="2" y="3" width="12" height="11" rx="1.5" />
    <path d="M2 6.5h12M5.5 1.5v3M10.5 1.5v3" />
  </svg>
)

/**
 * Opens the calendar. Named "Choose date" and the date chosen; pass `aria-label` in another language.
 * @stable
 */
function DatePickerTrigger({
  children = calendarIcon,
  ...props
}: Omit<
  PartProps<"button", DatePickerTriggerState>,
  "value" | "defaultValue" | "onChange"
>) {
  return usePart(
    useDatePicker("DatePickerTrigger"),
    "trigger",
    {},
    { ...props, children },
    "button"
  )
}

/**
 * The popup. Without children it renders Previous, the heading, Next and a
 * grid for each month; every Calendar part works inside it.
 * @stable
 */
function DatePickerContent({
  side,
  align,
  sideOffset,
  alignOffset,
  collisionPadding,
  arrowPadding,
  anchor,
  finalFocus,
  keepMounted,
  container,
  render,
  children,
  ref,
  ...props
}: PartProps<"div", DatePickerContentState> & DatePickerContentProps) {
  const picker = useDatePicker("DatePickerContent")
  const target = usePopupContainer(useOwnContainer(container, ContainerContext))
  const tree = usePopupTree()
  const content = {
    side,
    align,
    sideOffset,
    alignOffset,
    collisionPadding,
    arrowPadding,
    anchor,
    finalFocus,
    keepMounted,
  }
  const { months } = picker.state
  const offsets = Array.from({ length: months }, (_, offset) => offset)
  const body =
    children === undefined ? (
      <>
        <div>
          <CalendarPrevious />
          <CalendarHeading />
          <CalendarNext />
        </div>
        @for (const offset of offsets; key offset) {
          <CalendarGrid offset={offset} />
        }
      </>
    ) : (
      children
    )
  const element = usePart(picker, "content", content, {
    ...props,
    ref: mergeRefs<HTMLDivElement>(ref, tree.track),
    children: body,
    render: sheetViewport(picker, render),
  })
  return element && renderPopup(element, target, tree)
}

/**
 * The format to type, like "MM/DD/YYYY". The inputs are described by it.
 * @stable
 */
function DatePickerHint({
  children = placeholder,
  ...props
}: PartProps<"span", DatePickerHintState>) {
  return usePart(
    useDatePicker("DatePickerHint"),
    "hint",
    {},
    { ...props, children },
    "span"
  )
}

const placeholder = (state: DatePickerHintState) => state.placeholder

/**
 * Clears the value and focuses the input.
 * @stable
 */
const DatePickerClear = parts.Clear

/**
 * Selects the value it holds, like the last 7 days.
 * @stable
 */
function DatePickerPreset({
  value,
  ...props
}: Omit<
  PartProps<"button", DatePickerPresetState>,
  "value" | "defaultValue" | "onChange"
> & {
  value: DatePickerValue
}) {
  // Presets are told apart by their value.
  return usePart(
    datePickerPrimitive,
    "preset",
    { value, id: JSON.stringify(value) },
    props,
    "button"
  )
}

export {
  CalendarDay,
  CalendarGrid,
  CalendarHeading,
  CalendarMonthSelect,
  CalendarNext,
  CalendarPrevious,
  CalendarWeekday,
  CalendarWeekdays,
  CalendarWeeks,
  CalendarYearSelect,
} from "./calendar.tsrx"
export { createDatePickerController } from "@ui-sdk/core/date-picker"
export type {
  CalendarDayState,
  CalendarGridCell,
  CalendarGridState,
  CalendarHeadingState,
  CalendarSelectOption,
  CalendarSelectState,
  CalendarStepState,
  CalendarWeekdayState,
  DateMatcher,
  DateMatchers,
  DatePickerApi,
  DatePickerChangeOptions,
  DatePickerClearState,
  DatePickerContentProps,
  DatePickerContentState,
  DatePickerController,
  DatePickerDismissReason,
  DatePickerHintState,
  DatePickerInputProps,
  DatePickerInputState,
  DatePickerMode,
  DatePickerMonthChangeReason,
  DatePickerOpenChangeReason,
  DatePickerOptions,
  DatePickerPresetProps,
  DatePickerPresetState,
  DatePickerPrimitive,
  DatePickerState,
  DatePickerTriggerState,
  DatePickerValue,
  DatePickerValueChangeReason,
  ISOMonth,
} from "@ui-sdk/core/date-picker"

export {
  DatePicker,
  DatePickerClear,
  DatePickerContent,
  DatePickerHint,
  DatePickerInput,
  DatePickerPreset,
  DatePickerTrigger,
}
