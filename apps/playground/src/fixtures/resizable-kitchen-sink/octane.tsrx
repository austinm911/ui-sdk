"use strong"
import {
  createResizableController,
  Resizable,
  ResizableHandle,
  ResizablePanel,
} from "@ui-sdk/octane/resizable"
import * as React from "octane"
import { createRoot } from "octane"
import { classes as c } from "./classes"
import { describe, isHandleDisabled, renderShell, type Log } from "./shell"
import { presets, type GroupSpec, type Variant } from "./variants"

function Group({
  group,
  log,
  nested = false,
  onLayout,
  ...props
}: {
  group: GroupSpec
  log: Log
  nested?: boolean
  onLayout?: (layout: number[]) => void
} & Partial<Parameters<typeof Resizable>[0]>) {
  // Each panel with the handle before it, which the first has none of.
  const rows = group.panels.map(
    ({ label, nested: inner, ...sizes }, index) => ({
      label,
      inner,
      sizes,
      handle:
        index > 0
          ? {
              label: `Resize ${group.panels[index - 1].label}`,
              disabled: isHandleDisabled(group, index - 1),
            }
          : undefined,
    })
  )
  return (
    <Resizable
      className={nested ? c.nested : c.group}
      {...group.options}
      onLayoutChange={(layout, details) => {
        log.change(`${describe(layout)} (${details.reason})`)
        onLayout?.(layout)
      }}
      onLayoutCommit={(layout, details) =>
        log.commit(`${describe(layout)} (${details.reason})`)
      }
      {...props}
    >
      @for (const row of rows; key row.label) {
        <>
          @if (row.handle) {
            <ResizableHandle
              className={c.handle}
              aria-label={row.handle.label}
              disabled={row.handle.disabled}
            />
          }
          <ResizablePanel className={c.panel} {...row.sizes}>
            @if (row.inner) {
              <Group group={row.inner} log={log} nested />
            } @else {
              <>{row.label}</>
            }
          </ResizablePanel>
        </>
      }
    </Resizable>
  )
}

// Where the group sits.
function Place({
  place,
  children,
}: {
  place: Variant["place"]
  children?: unknown
}) @{
  @if (place === "rtl") {
    <div dir="rtl">{children}</div>
  } @else if (place === "transformed") {
    <div className={c.transformed}>{children}</div>
  } @else if (place === "scroll") {
    <div className={c.scroll}>{children}</div>
  } @else {
    <>{children}</>
  }
}

function Card({ variant, log }: { variant: Variant; log: Log }) {
  const [layout, setLayout] = React.useState(presets[0])
  const controller = React.useInitialValue(createResizableController)
  const [extra, setExtra] = React.useState(false)
  const group = extra
    ? {
        ...variant.group,
        panels: [...variant.group.panels, { label: "Extra", id: "extra" }],
      }
    : variant.group
  return (
    <>
      <Place place={variant.place}>
        <Group
          group={group}
          log={log}
          controller={variant.controller ? controller : undefined}
          {...(variant.controlled && { layout, onLayout: setLayout })}
        />
      </Place>
      <div className={c.row}>
        @if (variant.controlled) {
          @for (const preset of presets; key describe(preset)) {
            <button
              type="button"
              className={c.button}
              onClick={() => setLayout(preset)}
            >
              {`Set ${describe(preset)}`}
            </button>
          }
        }
        @if (variant.controller) {
          <>
            <button
              type="button"
              className={c.button}
              onClick={() => controller.collapse("sidebar")}
            >
              {"Collapse"}
            </button>
            <button
              type="button"
              className={c.button}
              onClick={() => controller.expand("sidebar")}
            >
              {"Expand"}
            </button>
            <button
              type="button"
              className={c.button}
              onClick={() => controller.resize("sidebar", "160px")}
            >
              {"160px"}
            </button>
          </>
        }
        @if (variant.conditional) {
          <button
            type="button"
            className={c.button}
            onClick={() => setExtra(!extra)}
          >
            {extra ? "Remove panel" : "Add panel"}
          </button>
        }
      </div>
    </>
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links to, so this page shows as React's.
  renderShell(root, "octane", (slot, variant, log) =>
    createRoot(slot).render(<Card variant={variant} log={log} />)
  )
}

export { mount }
