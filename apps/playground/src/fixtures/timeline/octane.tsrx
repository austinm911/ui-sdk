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
import * as React from "octane"
import { createRoot } from "octane"
import {
  advance,
  timelineFixture as f,
  timelineOptions,
  type TimelineFixtureEvent,
} from "tests/fixtures/timeline.ts"

const controller = createTimelineController()

function Fixture() {
  const [events, setEvents] = React.useState<readonly TimelineFixtureEvent[]>(
    f.events
  )
  const options = React.useInitialValue(timelineOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Timeline
        className="timeline"
        aria-label={f.label}
        controller={controller}
        {...options}
      >
        @for (const event of events; key event.value) {
          <TimelineItem value={event.value} status={event.status}>
            <TimelineMarker />
            <TimelineConnector />
            <TimelineTitle>{event.title}</TimelineTitle>
            <TimelineTime dateTime={event.dateTime}>{event.time}</TimelineTime>
            <TimelineDescription>{event.description}</TimelineDescription>
            @if (event.link) {
              <a href={event.link.href}>{event.link.label}</a>
            }
          </TimelineItem>
        }
      </Timeline>
      <button>{"After"}</button>
      <button onClick={() => setEvents([f.added, ...events])}>
        {"Add Event"}
      </button>
      <button onClick={() => setEvents([...events].reverse())}>
        {"Reverse"}
      </button>
      <button onClick={() => controller.focus("shipped")}>
        {"Focus Current"}
      </button>
      <button onClick={() => setEvents(advance(events))}>{"Advance"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
