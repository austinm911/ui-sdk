"use strong"
import {
  createWaterfallController,
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
} from "@ui-sdk/octane/waterfall"
import * as React from "octane"
import { createRoot } from "octane"
import { flatWaterfall, waterfallFixture } from "tests/fixtures/waterfall.ts"
import { kitchenSink, type Env } from "./shell"
import { barLabels, formats, items, type Variant } from "./variants"

const spans = flatWaterfall(items)

function Columns() {
  return (
    <>
      <WaterfallHeaderRow>
        <WaterfallColumnHeader>{"Name"}</WaterfallColumnHeader>
        <WaterfallColumnHeader>{"Status"}</WaterfallColumnHeader>
        <WaterfallColumnHeader aria-label="Timeline">
          <WaterfallAxis maxTicks={4} />
          <WaterfallMark time={waterfallFixture.mark.time}>
            {waterfallFixture.mark.label}
          </WaterfallMark>
        </WaterfallColumnHeader>
      </WaterfallHeaderRow>
      @for (const span of spans; key span.value) {
        <WaterfallRow value={span.value}>
          <WaterfallRowHeader>
            @if (span.children) {
              <WaterfallIndicator />
            }
            {span.label}
          </WaterfallRowHeader>
          <WaterfallCell>{span.status}</WaterfallCell>
          <WaterfallBar />
        </WaterfallRow>
      }
    </>
  )
}

function VariantWaterfall({ variant, env }: { variant: Variant; env: Env }) {
  const controller = React.useInitialValue(createWaterfallController)
  React.useEffect(() => {
    if (variant.controller) {
      env.controls([
        ["expandAll()", () => controller.expandAll()],
        ["collapseAll()", () => controller.collapseAll()],
        ["reveal('flags')", () => controller.reveal("flags")],
      ])
    }
  })
  // Without columns it has no children, so it renders a row for every span.
  // A prop, since template children are always a render function.
  return (
    <Waterfall
      aria-label={waterfallFixture.label}
      items={items}
      controller={controller}
      range={variant.range}
      format={variant.format && formats[variant.format]}
      getBarLabel={variant.barLabel && barLabels[variant.barLabel]}
      {...variant.options}
      onValueChange={(value, details) =>
        env.log(`valueChange ${value} (${details.reason})`)
      }
      onExpandedChange={(expanded, details) =>
        env.log(`expandedChange [${expanded}] (${details.reason})`)
      }
      children={variant.columns ? <Columns /> : undefined}
    />
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links to, so this page shows as React's.
  kitchenSink(root, "octane", (slot, variant, env) =>
    createRoot(slot).render(<VariantWaterfall variant={variant} env={env} />)
  )
}

export { mount }
