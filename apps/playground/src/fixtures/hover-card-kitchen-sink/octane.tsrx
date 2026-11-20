"use strong"
import {
  HoverCard,
  HoverCardArrow,
  HoverCardContent,
  HoverCardTrigger,
} from "@ui-sdk/octane/hover-card"
import { Tooltip, TooltipContent, TooltipTrigger } from "@ui-sdk/octane/tooltip"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import { authors, type Variant } from "./variants"

// The long body's lines, which name themselves.
const lines = Array.from({ length: 30 }, (_, index) => index + 1)

function Body({ variant, name }: { variant: Variant; name: string }) {
  const heading = (
    <div className="flex items-center gap-3">
      <div className={classes.avatar} aria-hidden="true">
        {name.slice(0, 1).toUpperCase()}
      </div>
      <div>
        <div className={classes.name}>{name}</div>
        <div className={classes.handle}>{`@${name}`}</div>
      </div>
    </div>
  )
  const bio = (
    <p className={classes.bio}>
      {variant.note ?? "Writes about headless components."}
    </p>
  )
  if (variant.body === "text") {
    return (
      <>
        {heading}
        {bio}
      </>
    )
  }
  if (variant.body === "long") {
    return (
      <>
        {heading}
        @for (const line of lines; key line) {
          <p>{`Line ${line}`}</p>
        }
      </>
    )
  }
  if (variant.body === "tooltip") {
    return (
      <>
        {heading}
        {bio}
        <div className="mt-3">
          <Tooltip delay={100}>
            <TooltipTrigger className={classes.button}>
              {"Follow"}
            </TooltipTrigger>
            <TooltipContent className={classes.tooltip} sideOffset={6}>
              {`Get updates from @${name}`}
            </TooltipContent>
          </Tooltip>
        </div>
      </>
    )
  }
  return (
    <>
      {heading}
      {bio}
      <div className="mt-3 flex items-center gap-3">
        <a href={`#${name}`} className={classes.link}>
          {"View profile"}
        </a>
        <button className={classes.button}>{"Follow"}</button>
      </div>
    </>
  )
}

function Content({ variant, env }: { variant: Variant; env: Env }) {
  return (
    <HoverCardContent
      className={classes.content(variant.animation, variant.body === "long")}
      sideOffset={8}
      {...variant.content}
      anchor={env.anchor}
    >
      {(state: { payload: unknown }) => (
        <>
          @if (variant.arrow !== false) {
            <HoverCardArrow className={classes.arrow} />
          }
          <Body
            variant={variant}
            name={
              variant.controller
                ? String(state.payload ?? "nobody")
                : variant.id
            }
          />
        </>
      )}
    </HoverCardContent>
  )
}

function VariantHoverCard({ variant, env }: { variant: Variant; env: Env }) {
  const [open, setOpen] = React.useState(false)
  const root = {
    ...variant.options,
    container: env.container,
    ...(variant.controlled && { open }),
    onOpenChange: (next: boolean, details: { reason: string }) => {
      if (variant.controlled) {
        setOpen(next)
      }
      env.log(`openChange ${next} (${details.reason})`)
    },
    onOpenChangeComplete: (next: boolean) =>
      env.log(`openChangeComplete ${next}`),
  }

  if (variant.controller) {
    return (
      <div className="flex gap-3">
        @for (const author of authors; key author) {
          <HoverCardTrigger
            href={`#${author}`}
            className={classes.trigger}
            controller={env.controller}
            payload={author}
          >
            {`@${author}`}
          </HoverCardTrigger>
        }
        <HoverCard {...root} controller={env.controller}>
          <Content variant={variant} env={env} />
        </HoverCard>
      </div>
    )
  }

  return (
    <div className="flex items-center gap-3">
      <HoverCard {...root}>
        <HoverCardTrigger href={`#${variant.id}`} className={classes.trigger}>
          {variant.trigger ?? `@${variant.id}`}
        </HoverCardTrigger>
        <Content variant={variant} env={env} />
      </HoverCard>
      @if (variant.controlled) {
        <label className="flex items-center gap-1.5 text-xs text-neutral-600">
          <input
            type="checkbox"
            checked={open}
            onChange={(event) => setOpen(event.currentTarget.checked)}
          />
          {"open"}
        </label>
      }
    </div>
  )
}

function mount(root: HTMLElement) {
  kitchenSink(root, "octane", (slot, variant, env) =>
    createRoot(slot).render(<VariantHoverCard variant={variant} env={env} />)
  )
}

export { mount }
