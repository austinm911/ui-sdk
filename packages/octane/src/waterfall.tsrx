"use strong"
import {
  waterfall as waterfallPrimitive,
  type WaterfallAxisProps,
  type WaterfallAxisState,
  type WaterfallDataItem,
  type WaterfallOptions,
  type WaterfallState,
  type WaterfallTimeState,
} from "@ui-sdk/core/waterfall"
import {
  createParts,
  readIn,
  usePart,
  usePrimitive,
  type PartProps,
} from "./use-primitive.tsrx"

const parts = createParts(waterfallPrimitive, {
  "header-row": "div",
  "column-header": "div",
  axis: "div",
  tick: "span",
  mark: "span",
  row: "div",
  "row-header": "div",
  indicator: "span",
  cell: "div",
  bar: "div",
})

// Element props that mean something else on a waterfall.
type Clashing = "defaultValue" | "onChange" | "onSelect"

/**
 * The props of `Waterfall`.
 * @experimental
 */
type WaterfallProps = Omit<
  PartProps<"div", WaterfallState>,
  Clashing | keyof WaterfallOptions
> &
  WaterfallOptions

/**
 * A trace's spans on a shared time axis, as a tree of rows you expand and
 * collapse, with one tab stop. Without children, it renders a row for every span.
 * @experimental
 */
function Waterfall({
  items,
  range,
  value,
  defaultValue,
  onValueChange,
  expanded,
  defaultExpanded,
  onExpandedChange,
  onHighlight,
  format,
  locale,
  getBarLabel,
  controller,
  debug,
  children,
  ...props
}: WaterfallProps) {
  const waterfall = usePrimitive(waterfallPrimitive, {
    items,
    range,
    value,
    defaultValue,
    onValueChange,
    expanded,
    defaultExpanded,
    onExpandedChange,
    onHighlight,
    format,
    locale,
    getBarLabel,
    controller,
    debug,
  })
  const content =
    children ??
    <WaterfallRows
      items={readIn(waterfall, () => waterfall.api.internal.all())}
    />
  return usePart(waterfall, "root", {}, { ...props, children: content })
}

// A row for every span, for a waterfall without children.
function WaterfallRows({
  items,
}: {
  items: WaterfallDataItem[]
}) @{
  @for (const item of items; key item.value) {
    <WaterfallRow value={item.value}>
      <WaterfallRowHeader>
        @if (item.children) {
          <WaterfallIndicator />
        }
        {item.label}
      </WaterfallRowHeader>
      <WaterfallBar />
    </WaterfallRow>
  }
}

/**
 * The row of column headers, above the rows.
 * @experimental
 */
const WaterfallHeaderRow = parts.HeaderRow

/**
 * A column's header, like "Name" or "Timeline".
 * @experimental
 */
const WaterfallColumnHeader = parts.ColumnHeader

/**
 * The ruler of round times above the bars, hidden from screen readers. Without children, it renders its ticks.
 * @experimental
 */
function WaterfallAxis({
  children = ticks,
  ...props
}: PartProps<"div", WaterfallAxisState> & WaterfallAxisProps) {
  const Axis = parts.Axis
  return <Axis {...props} children={children} />
}

const ticks = (state: WaterfallAxisState) => <WaterfallTicks ticks={state.ticks} />

function WaterfallTicks({ ticks }: { ticks: WaterfallAxisState["ticks"] }) @{
  @for (const tick of ticks; key tick.time) {
    <WaterfallTick time={tick.time} />
  }
}

/**
 * One time on the axis, placed by `--waterfall-tick`. Without children, it shows the time.
 * @experimental
 */
function WaterfallTick({
  children = label,
  ...props
}: Parameters<typeof parts.Tick>[0]) {
  const Tick = parts.Tick
  return <Tick {...props} children={children} />
}

const label = (state: WaterfallTimeState) => state.label

/**
 * A moment across every row, like DOMContentLoaded, placed by `--waterfall-mark`.
 * @experimental
 */
const WaterfallMark = parts.Mark

/**
 * One span's row. Its `--waterfall-start` and `--waterfall-size` place the span's bar.
 * @experimental
 */
const WaterfallRow = parts.Row

/**
 * The cell that names the span. Put the indicator and the span's label in it.
 * @experimental
 */
const WaterfallRowHeader = parts.RowHeader

/**
 * The arrow that expands and collapses a span with children.
 * @experimental
 */
const WaterfallIndicator = parts.Indicator

/**
 * A cell of your own, like a status or a size.
 * @experimental
 */
const WaterfallCell = parts.Cell

/**
 * The cell on the time axis, which screen readers hear as the span's start and duration.
 * @experimental
 */
const WaterfallBar = parts.Bar

export {
  createWaterfallController,
  visibleWaterfallRows,
} from "@ui-sdk/core/waterfall"
export type {
  ListHighlightDetails,
  NumberFormat,
  WaterfallApi,
  WaterfallAxisProps,
  WaterfallAxisState,
  WaterfallBarLabelDetails,
  WaterfallChangeOptions,
  WaterfallController,
  WaterfallData,
  WaterfallDataItem,
  WaterfallDataRow,
  WaterfallExpandedChangeReason,
  WaterfallOptions,
  WaterfallPrimitive,
  WaterfallRowPartProps,
  WaterfallRowProps,
  WaterfallRowState,
  WaterfallState,
  WaterfallTickData,
  WaterfallTimeProps,
  WaterfallTimeState,
  WaterfallValueChangeReason,
} from "@ui-sdk/core/waterfall"

export {
  Waterfall,
  WaterfallAxis,
  WaterfallBar,
  WaterfallCell,
  WaterfallColumnHeader,
  WaterfallHeaderRow,
  WaterfallIndicator,
  WaterfallMark,
  WaterfallRow,
  WaterfallRowHeader,
  WaterfallTick,
  type WaterfallProps,
}
