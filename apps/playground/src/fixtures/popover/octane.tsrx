"use strong"
import { createPopoverController } from "@ui-sdk/core/popover"
import { Menu, MenuContent, MenuItem, MenuTrigger } from "@ui-sdk/octane/menu"
import {
  Popover,
  PopoverArrow,
  PopoverClose,
  PopoverContent,
  PopoverDescription,
  PopoverShortcut,
  PopoverTitle,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import * as React from "octane"
import { createRoot } from "octane"
import {
  popoverContentOptions,
  popoverFixture,
  popoverOptions,
  popoverParts,
} from "tests/fixtures/popover.ts"

const controller = createPopoverController()

const parts = popoverParts()

function Fixture() {
  const [action, setAction] = React.useState("")
  const [triggerShown, setTriggerShown] = React.useState(true)
  // The page's options, read once, as the page's URL never changes.
  const options = React.useInitialValue(popoverOptions)
  const contentOptions = React.useInitialValue(popoverContentOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Popover controller={controller} {...options}>
        @if (triggerShown) {
          <PopoverTrigger
            shortcut={
              parts.shortcut ? popoverFixture.shortcut.trigger : undefined
            }
          >
            {popoverFixture.trigger}
            @if (parts.shortcut) {
              <PopoverShortcut />
            }
          </PopoverTrigger>
        }
        <PopoverContent className="popup" sideOffset={8} {...contentOptions}>
          <PopoverArrow className="arrow" />
          @if (parts.title) {
            <PopoverTitle className="title">
              {popoverFixture.title}
            </PopoverTitle>
          }
          <PopoverDescription className="description">
            {popoverFixture.description}
          </PopoverDescription>
          <label className="field">
            {popoverFixture.field}
            <input defaultValue={popoverFixture.defaultValue} />
          </label>
          <div className="actions">
            <button onClick={() => setAction("save")}>
              {popoverFixture.action}
              @if (parts.shortcut) {
                <PopoverShortcut shortcut={popoverFixture.shortcut.save} />
              }
            </button>
            <PopoverClose>{popoverFixture.close}</PopoverClose>
            @if (parts.removable) {
              <button onClick={() => setTriggerShown(false)}>
                {popoverFixture.remove}
              </button>
            }
          </div>
          @if (parts.menu) {
            <Menu container={options.container} onAction={setAction}>
              <MenuTrigger>{popoverFixture.menu.trigger}</MenuTrigger>
              <MenuContent className="popup">
                @for (const item of popoverFixture.menu.items; key item.value) {
                  <MenuItem value={item.value} className="item">
                    {item.label}
                  </MenuItem>
                }
              </MenuContent>
            </Menu>
          }
          @if (parts.nested) {
            <Popover>
              <PopoverTrigger>{popoverFixture.nested.trigger}</PopoverTrigger>
              <PopoverContent className="popup">
                <PopoverTitle className="title">
                  {popoverFixture.nested.title}
                </PopoverTitle>
                <button onClick={() => setAction("archive")}>
                  {popoverFixture.nested.action}
                </button>
              </PopoverContent>
            </Popover>
          }
        </PopoverContent>
      </Popover>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <button onClick={() => controller.open()}>
        {"Open with controller"}
      </button>
      @if (parts.shortcut) {
        <PopoverTrigger
          controller={controller}
          shortcut={popoverFixture.shortcut.remote.keys}
        >
          {popoverFixture.shortcut.remote.trigger}
          <PopoverShortcut />
        </PopoverTrigger>
      }
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
