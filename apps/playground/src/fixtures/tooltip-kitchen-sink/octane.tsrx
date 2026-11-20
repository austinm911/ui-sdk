"use strong"
import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTitle,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import { mergeProps } from "@ui-sdk/octane/primitive"
import {
  Tooltip,
  TooltipArrow,
  TooltipContent,
  TooltipShortcut,
  TooltipTrigger,
  type TooltipContentState,
} from "@ui-sdk/octane/tooltip"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import { rows, toolbar, type Variant } from "./variants"

// Octane compiles template children into a function, so text that depends on
// the content's state comes as `label`, not as a function child.
function Content({
  variant,
  env,
  shortcut = !!(variant.options?.shortcut || variant.partShortcut),
  label,
  children,
}: {
  variant: Variant
  env: Env
  shortcut?: boolean
  label?: (state: TooltipContentState) => unknown
  children?: unknown
}) {
  return (
    <TooltipContent
      className={classes.content(variant.animation)}
      sideOffset={6}
      {...variant.content}
      anchor={env.anchor}
    >
      {(state: TooltipContentState) => (
        <>
          @if (variant.arrow !== false) {
            <TooltipArrow className={classes.arrow} />
          }
          {label ? label(state) : children}
          @if (shortcut) {
            <TooltipShortcut
              className={classes.shortcut}
              shortcut={variant.partShortcut}
            />
          }
        </>
      )}
    </TooltipContent>
  )
}

function Trigger({
  variant,
  onClick,
}: {
  variant: Variant
  onClick: () => void
}) {
  if (variant.compose === "link") {
    return (
      <TooltipTrigger
        render={(props) => (
          <a
            {...mergeProps(props, {
              href: "#docs",
              className: classes.link,
              onClick,
            })}
          />
        )}
      >
        {variant.trigger}
      </TooltipTrigger>
    )
  }
  if (variant.compose === "popover-trigger") {
    return (
      <TooltipTrigger
        render={(props) => (
          <PopoverTrigger
            {...mergeProps(props, { className: classes.trigger })}
          >
            {variant.trigger}
          </PopoverTrigger>
        )}
      />
    )
  }
  return (
    <TooltipTrigger
      className={variant.icon ? classes.iconTrigger : classes.trigger}
      aria-label={variant.label}
      aria-disabled={variant.ariaDisabled || undefined}
      onClick={onClick}
    >
      @if (variant.icon) {
        <span aria-hidden="true">{variant.trigger}</span>
      } @else {
        <>{variant.trigger ?? "Hover me"}</>
      }
    </TooltipTrigger>
  )
}

function VariantTooltip({ variant, env }: { variant: Variant; env: Env }) {
  const [open, setOpen] = React.useState(false)
  const [copied, setCopied] = React.useState(false)
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
    onOpenChangeComplete: (next: boolean) => {
      if (!next) {
        setCopied(false)
      }
      env.log(`openChangeComplete ${next}`)
    },
  }
  const text = copied ? "Copied" : (variant.text ?? variant.title)
  const press = () => {
    if (variant.ariaDisabled) {
      return env.log("press ignored, aria-disabled")
    }
    if (variant.copy) {
      setCopied(true)
    }
    env.log("press")
  }

  if (variant.compose === "toolbar") {
    return (
      <div role="toolbar" aria-label="Formatting" className={classes.toolbar}>
        @for (const item of toolbar; key item.text) {
          <Tooltip {...root} shortcut={item.shortcut}>
            <TooltipTrigger className={classes.toolbarButton}>
              <span aria-hidden="true">{item.icon}</span>
            </TooltipTrigger>
            <Content variant={variant} env={env} shortcut={!!item.shortcut}>
              {item.text}
            </Content>
          </Tooltip>
        }
      </div>
    )
  }

  if (variant.controller) {
    return (
      <div className="flex gap-2">
        @for (const row of rows; key row) {
          <TooltipTrigger
            className={classes.trigger}
            controller={env.controller}
            payload={row}
          >
            {row}
          </TooltipTrigger>
        }
        <Tooltip {...root} controller={env.controller}>
          <Content
            variant={variant}
            env={env}
            label={(state) => `Open ${state.payload ?? "nothing"}`}
          />
        </Tooltip>
      </div>
    )
  }

  if (variant.compose === "in-popover") {
    return (
      <Popover container={env.container}>
        <PopoverTrigger className={classes.trigger}>
          {variant.trigger}
        </PopoverTrigger>
        <PopoverContent className={classes.popover} sideOffset={8}>
          <PopoverTitle className={classes.popoverTitle}>
            {"Formatting"}
          </PopoverTitle>
          <div className="flex gap-2">
            <Tooltip {...root}>
              <TooltipTrigger className={classes.button}>
                {"Help"}
              </TooltipTrigger>
              <Content variant={variant} env={env}>
                {"Opens the help center"}
              </Content>
            </Tooltip>
            <PopoverClose className={classes.button}>{"Close"}</PopoverClose>
          </div>
        </PopoverContent>
      </Popover>
    )
  }

  const tooltip = (
    <Tooltip {...root}>
      <Trigger variant={variant} onClick={press} />
      <Content variant={variant} env={env}>
        {text}
      </Content>
    </Tooltip>
  )

  return (
    <div className="flex items-center gap-3">
      @if (variant.compose === "popover-trigger") {
        <Popover
          container={env.container}
          onOpenChange={(next, details) =>
            env.log(`popover openChange ${next} (${details.reason})`)
          }
        >
          {tooltip}
          <PopoverContent className={classes.popover} sideOffset={8}>
            <PopoverTitle className={classes.popoverTitle}>
              {"Profile settings"}
            </PopoverTitle>
            <PopoverClose className={classes.button}>{"Close"}</PopoverClose>
          </PopoverContent>
        </Popover>
      } @else {
        <>{tooltip}</>
      }
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
  kitchenSink(root, "react", (slot, variant, env) =>
    createRoot(slot).render(<VariantTooltip variant={variant} env={env} />)
  )
}

export { mount }
