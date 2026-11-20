"use strong"
import {
  HoverCard,
  HoverCardArrow,
  HoverCardContent,
  HoverCardTrigger,
} from "@ui-sdk/octane/hover-card"
import * as React from "octane"
import { createRoot } from "octane"
import {
  hoverCardContentOptions,
  hoverCardFixture,
  hoverCardOptions,
} from "tests/fixtures/hover-card.ts"

function Fixture() {
  const [action, setAction] = React.useState("")
  const fixture = hoverCardFixture
  // The page's options, read once, as the page's URL never changes.
  const options = React.useInitialValue(hoverCardOptions)
  const contentOptions = React.useInitialValue(hoverCardContentOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <HoverCard
        {...options}
        onOpenChange={(open, { reason }) =>
          setAction(`${open ? "open" : "close"}: ${reason}`)
        }
      >
        <HoverCardTrigger href={fixture.href}>
          {fixture.trigger}
        </HoverCardTrigger>
        <HoverCardContent className="hover-card" {...contentOptions}>
          <HoverCardArrow className="arrow" />
          <p>
            <strong>{fixture.name}</strong>
          </p>
          <p>{fixture.bio}</p>
          <a href={fixture.linkHref}>{fixture.link}</a>
        </HoverCardContent>
      </HoverCard>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
