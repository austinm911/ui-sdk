"use strong"
import { createTooltipController } from "@ui-sdk/core/tooltip"
import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTitle,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import {
  Tooltip,
  TooltipArrow,
  TooltipContent,
  TooltipShortcut,
  TooltipTrigger,
} from "@ui-sdk/octane/tooltip"
import * as React from "octane"
import { createRoot } from "octane"
import {
  tooltipContentOptions,
  tooltipFixture,
  tooltipOptions,
  tooltipParts,
} from "tests/fixtures/tooltip.ts"

const controller = createTooltipController()

const parts = tooltipParts()

function Fixture() {
  const [action, setAction] = React.useState("")
  // The page's options, read once, as the page's URL never changes.
  const options = React.useInitialValue(tooltipOptions)
  const contentOptions = React.useInitialValue(tooltipContentOptions)
  const { save, toolbar, profile, info, publish, iconPopover } = tooltipFixture
  return (
    <div className="fixture tooltip-page">
      <button>{"Before"}</button>
      <Tooltip
        {...options}
        controller={controller}
        defaultOpen={parts.open}
        shortcut={save.shortcut}
      >
        <TooltipTrigger
          disabled={parts.nativeDisabled}
          onClick={() => setAction("save")}
        >
          {save.trigger}
        </TooltipTrigger>
        <TooltipContent className="tooltip" {...contentOptions}>
          <TooltipArrow className="arrow" />
          {save.content}
          <TooltipShortcut />
        </TooltipContent>
      </Tooltip>
      <div className="toolbar" role="group" aria-label="Formatting">
        @for (const item of toolbar; key item.content) {
          <Tooltip {...options}>
            <TooltipTrigger>
              <span aria-hidden="true">{item.icon}</span>
            </TooltipTrigger>
            <TooltipContent className="tooltip">{item.content}</TooltipContent>
          </Tooltip>
        }
      </div>
      <Popover container={options.container}>
        <Tooltip {...options}>
          <TooltipTrigger
            render={(props) => (
              <PopoverTrigger {...props}>{profile.trigger}</PopoverTrigger>
            )}
          />
          <TooltipContent className="tooltip">{profile.content}</TooltipContent>
        </Tooltip>
        <PopoverContent className="popup" sideOffset={8}>
          <PopoverTitle className="title">{profile.popover}</PopoverTitle>
          <div className="actions">
            <Tooltip {...options}>
              <TooltipTrigger>{profile.help.trigger}</TooltipTrigger>
              <TooltipContent className="tooltip">
                {profile.help.content}
              </TooltipContent>
            </Tooltip>
            <PopoverClose>{profile.close}</PopoverClose>
          </div>
        </PopoverContent>
      </Popover>
      <Tooltip {...options} toggleable>
        <TooltipTrigger aria-label={info.trigger}>
          <span aria-hidden="true">{"i"}</span>
        </TooltipTrigger>
        <TooltipContent className="tooltip">{info.content}</TooltipContent>
      </Tooltip>
      @if (parts.disabled) {
        <Tooltip {...options}>
          <TooltipTrigger
            aria-disabled="true"
            onClick={(event) =>
              event.currentTarget.getAttribute("aria-disabled") !== "true" &&
              setAction(publish.action)
            }
          >
            {publish.trigger}
          </TooltipTrigger>
          <TooltipContent className="tooltip">{publish.content}</TooltipContent>
        </Tooltip>
      }
      @if (parts.iconPopover) {
        <>
          <Popover container={options.container}>
            <Tooltip {...options}>
              <TooltipTrigger
                render={(props) => (
                  <PopoverTrigger {...props}>
                    <span aria-hidden="true">{iconPopover.icon}</span>
                  </PopoverTrigger>
                )}
              />
              <TooltipContent className="tooltip">
                {iconPopover.content}
              </TooltipContent>
            </Tooltip>
            <PopoverContent className="popup">
              {iconPopover.popover}
            </PopoverContent>
          </Popover>
          <Popover container={options.container}>
            <PopoverTrigger>
              <span aria-hidden="true">{iconPopover.unnamed}</span>
            </PopoverTrigger>
            <PopoverContent className="popup">
              {iconPopover.popover}
            </PopoverContent>
          </Popover>
        </>
      }
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <button onClick={() => controller.open()}>
        {"Open with controller"}
      </button>
      @if (parts.shortcut) {
        <TooltipTrigger controller={controller}>
          {`${tooltipFixture.shortcut.trigger} `}
          <TooltipShortcut />
        </TooltipTrigger>
      }
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
