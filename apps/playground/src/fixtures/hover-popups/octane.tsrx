"use strong"
import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from "@ui-sdk/octane/hover-card"
import { Popover, PopoverContent, PopoverTrigger } from "@ui-sdk/octane/popover"
import { Tooltip, TooltipContent, TooltipTrigger } from "@ui-sdk/octane/tooltip"
import * as React from "octane"
import { createRoot } from "octane"
import {
  describeChange,
  hoverPopupsFixture as fixture,
} from "tests/fixtures/hover-popups.ts"

function Fixture() {
  const [change, setChange] = React.useState("")
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Tooltip
        delay={0}
        onOpenChange={(open, { event }) =>
          open && setChange(describeChange("tooltip", "open", event))
        }
        onPayloadChange={(payload, { event }) =>
          setChange(describeChange("tooltip", `payload ${payload}`, event))
        }
      >
        @for (const day of fixture.days; key day) {
          <TooltipTrigger payload={day.toLowerCase()}>{day}</TooltipTrigger>
        }
        <TooltipContent className="tooltip">
          {(state: { payload: unknown }) => `Tip for ${state.payload}`}
        </TooltipContent>
      </Tooltip>
      <HoverCard
        delay={0}
        closeDelay={0}
        onOpenChange={(open, { event }) =>
          open && setChange(describeChange("hover card", "open", event))
        }
        onPayloadChange={(payload, { event }) =>
          setChange(describeChange("hover card", `payload ${payload}`, event))
        }
      >
        @for (const person of fixture.people; key person) {
          <HoverCardTrigger href={`#${person}`} payload={person.toLowerCase()}>
            {person}
          </HoverCardTrigger>
        }
        <HoverCardContent className="hover-card">
          {(state: { payload: unknown }) => `Card for ${state.payload}`}
        </HoverCardContent>
      </HoverCard>
      <Popover
        openOnHover
        delay={0}
        closeDelay={0}
        onOpenChange={(open, { event }) =>
          open && setChange(describeChange("popover", "open", event))
        }
      >
        <PopoverTrigger>{fixture.popover.trigger}</PopoverTrigger>
        <PopoverContent className="popup">
          {fixture.popover.content}
        </PopoverContent>
      </Popover>
      <output role="status" aria-label="Last change">
        {change}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
