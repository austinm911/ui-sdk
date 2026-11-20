"use strong"
import {
  Timeline,
  TimelineConnector,
  TimelineDescription,
  TimelineItem,
  TimelineMarker,
  TimelineTime,
  TimelineTitle,
  createTimelineController,
} from "@ui-sdk/octane/timeline"
import {
  Collapsible,
  CollapsiblePanel,
  CollapsibleTrigger,
} from "@ui-sdk/octane/collapsible"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import type { Variant } from "./variants"

function VariantTimeline({ variant, env }: { variant: Variant; env: Env }) {
  const controller = React.useInitialValue(() =>
    variant.controller ? createTimelineController() : undefined
  )
  React.useEffect(() => {
    if (!controller) {
      return
    }
    env.controls([
      ['focus("shipped")', () => controller.focus("shipped")],
      ["focus()", () => controller.focus()],
    ])
  })
  return (
    <Timeline
      className={classes.root}
      aria-label={variant.title}
      controller={controller}
      {...variant.options}
    >
      @for (const event of variant.events; key event.value) {
        <TimelineItem
          className={classes.item}
          value={event.value}
          status={event.status}
          onFocus={(focusEvent: FocusEvent) =>
            focusEvent.target === focusEvent.currentTarget &&
            env.log(`focus ${event.value}`)
          }
        >
          <TimelineMarker className={classes.marker} />
          <TimelineConnector className={classes.connector} />
          <TimelineTitle className={classes.title}>{event.title}</TimelineTitle>
          <TimelineTime className={classes.time} dateTime={event.dateTime}>
            {event.time}
          </TimelineTime>
          <TimelineDescription className={classes.description}>
            {event.description}
          </TimelineDescription>
          @if (event.link) {
            <a className={classes.link} href={`#${event.value}`}>
              {event.link}
            </a>
          }
          @if (variant.details) {
            <Collapsible className="col-start-2">
              <CollapsibleTrigger className={classes.link}>
                {"Details"}
              </CollapsibleTrigger>
              <CollapsiblePanel className={classes.description}>
                {`Handled by the ${event.title.toLowerCase()} team.`}
              </CollapsiblePanel>
            </Collapsible>
          }
        </TimelineItem>
      }
    </Timeline>
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links to, so this page shows as React's.
  kitchenSink(root, "react", (slot, variant, env) =>
    createRoot(slot).render(<VariantTimeline variant={variant} env={env} />)
  )
}

export { mount }
