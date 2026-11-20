"use strong"
import {
  Accordion,
  AccordionHeader,
  AccordionItem,
  AccordionPanel,
  AccordionTrigger,
} from "@ui-sdk/octane/accordion"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { itemsOf, kitchenSink, type Env } from "./shell"
import type { Variant } from "./variants"

function Grow() {
  const [lines, setLines] = React.useState(1)
  const numbers = Array.from({ length: lines }, (_, index) => index + 1)
  return (
    <div className="flex flex-col gap-1">
      @for (const line of numbers; key line) {
        <p>{`Line ${line}`}</p>
      }
      <button
        className={`${classes.button} self-start`}
        onClick={() => setLines((count) => count + 1)}
      >
        {"Add a line"}
      </button>
    </div>
  )
}

const longLines = Array.from({ length: 20 }, (_, index) => index + 1)

// An accordion in every item, two levels deep. Events are logged with the item's path.
function Nested({
  env,
  path,
  depth = 1,
}: {
  env: Env
  path: string
  depth?: number
}) {
  return (
    <Accordion className={classes.root} multiple>
      @for (const label of ["One", "Two"]; key label) {
        <AccordionItem
          value={label}
          onOpenChange={(open) =>
            env.log(`${path}/${label} openChange ${open}`)
          }
          onOpenChangeComplete={(open) =>
            env.log(`${path}/${label} openChangeComplete ${open}`)
          }
        >
          <AccordionHeader className={classes.header}>
            <AccordionTrigger className={classes.trigger}>
              {`Level ${depth}, ${label.toLowerCase()}`}
            </AccordionTrigger>
          </AccordionHeader>
          <AccordionPanel className={classes.panel()}>
            <div className={classes.inner}>
              @if (depth < 2) {
                <Nested env={env} path={`${path}/${label}`} depth={depth + 1} />
              } @else {
                <>{`Inside ${path}/${label}.`}</>
              }
            </div>
          </AccordionPanel>
        </AccordionItem>
      }
    </Accordion>
  )
}

// What the second item's panel holds.
function Body({
  variant,
  content,
  env,
}: {
  variant: Variant
  content: string
  env: Env
}) @{
  @if (variant.body === "long") {
    @for (const line of longLines; key line) {
      <p>{`Line ${line}`}</p>
    }
  } @else if (variant.body === "form") {
    <label className="flex flex-col">
      {content}
      <input className={classes.input} defaultValue="Ada" aria-label="Name" />
    </label>
  } @else if (variant.body === "nested") {
    <Accordion className={classes.root}>
      @for (const label of ["Nested one", "Nested two"]; key label) {
        <AccordionItem value={label}>
          <AccordionHeader className={classes.header}>
            <AccordionTrigger className={classes.trigger}>
              {label}
            </AccordionTrigger>
          </AccordionHeader>
          <AccordionPanel className={classes.panel()}>
            <div className={classes.inner}>
              {`Inside ${label.toLowerCase()}.`}
            </div>
          </AccordionPanel>
        </AccordionItem>
      }
    </Accordion>
  } @else if (variant.body === "nested-deep") {
    <Nested env={env} path="b" />
  } @else if (variant.body === "grow") {
    <Grow />
  } @else {
    <>{content}</>
  }
}

function VariantAccordion({ variant, env }: { variant: Variant; env: Env }) {
  const [list, setList] = React.useState(() => itemsOf(variant))
  const [value, setValue] = React.useState<string[]>(
    () => variant.options?.defaultValue ?? []
  )
  // The second item, by position, which `panel` and `body` apply to.
  const second = list[1]?.value
  return (
    <div className="flex flex-col gap-2">
      <Accordion
        className={classes.root}
        {...variant.options}
        controller={env.controller}
        {...(variant.controlled && { value })}
        onValueChange={(next, details) => {
          if (variant.cancel && next.includes(variant.cancel)) {
            details.cancel()
            env.log(`valueChange ${JSON.stringify(next)} canceled`)
            return
          }
          if (variant.controlled) {
            setValue(next)
          }
          env.log(`valueChange ${JSON.stringify(next)} (${details.reason})`)
        }}
      >
        @for (const item of list; key item.value) {
          <AccordionItem
            className={classes.item}
            value={item.value}
            disabled={variant.disabledItems?.includes(item.value)}
            onOpenChange={(open, details) => {
              if (variant.itemCancel === item.value) {
                details.cancel()
              }
              env.log(
                `${item.value} openChange ${open}${details.canceled ? " canceled" : ""}`
              )
            }}
            onOpenChangeComplete={(open) =>
              env.log(`${item.value} openChangeComplete ${open}`)
            }
          >
            <AccordionHeader className={classes.header}>
              <AccordionTrigger
                className={classes.trigger}
                disabled={variant.disabledTriggers?.includes(item.value)}
                // The index comes from render state.
                render={
                  variant.index
                    ? (props, state) => (
                        <button {...props}>
                          {item.label}
                          <span className={classes.index}>{`#${state.index}`}</span>
                          <span aria-hidden className={classes.chevron}>
                            {"▾"}
                          </span>
                        </button>
                      )
                    : undefined
                }
              >
                {item.label}
                <span aria-hidden className={classes.chevron}>
                  {"▾"}
                </span>
              </AccordionTrigger>
            </AccordionHeader>
            <AccordionPanel
              className={classes.panel(variant.animation)}
              {...(item.value === second && variant.panel)}
            >
              <div className={classes.inner}>
                @if (item.value === second) {
                  <Body variant={variant} content={item.content} env={env} />
                } @else {
                  <>{item.content}</>
                }
              </div>
            </AccordionPanel>
          </AccordionItem>
        }
      </Accordion>
      @if (variant.index) {
        <button
          className={`${classes.button} self-start`}
          onClick={() => setList((items) => [...items].reverse())}
        >
          {"Reverse items"}
        </button>
      }
      @if (variant.controlled) {
        <div className="flex items-center gap-2 text-xs">
          <code className="text-neutral-500">{JSON.stringify(value)}</code>
          <button
            className="rounded border border-neutral-200 px-2 py-1"
            onClick={() => setValue([])}
          >
            {"Collapse all"}
          </button>
          <button
            className="rounded border border-neutral-200 px-2 py-1"
            onClick={() => setValue(list.map((item) => item.value))}
          >
            {"Expand all"}
          </button>
        </div>
      }
    </div>
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links to, so this page shows as React's.
  kitchenSink(root, "react", (slot, variant, env) =>
    createRoot(slot).render(<VariantAccordion variant={variant} env={env} />)
  )
}

export { mount }
