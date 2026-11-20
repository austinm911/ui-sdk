"use strong"
import { Dialog, DialogContent, DialogTrigger } from "@ui-sdk/octane/dialog"
import { Drawer, DrawerContent, DrawerTrigger } from "@ui-sdk/octane/drawer"
import {
  Menu,
  MenuContent,
  MenuGroup,
  MenuGroupLabel,
  MenuItem,
  MenuTrigger,
} from "@ui-sdk/octane/menu"
import {
  createPopoverController,
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import * as React from "octane"
import { createRoot } from "octane"
import {
  contentFor,
  describeChange,
  payloadOf,
  popupPayloadsFixture as fixture,
} from "tests/fixtures/popup-payloads.ts"

type Details = { event?: Event }

const people = createPopoverController<string>()

function Fixture() {
  const [lastOpen, setLastOpen] = React.useState("")
  const [lastPayload, setLastPayload] = React.useState("")
  // The callbacks every popup reports through.
  const report = (name: string) => ({
    onOpenChange: (open: boolean, { event }: Details) =>
      open && setLastOpen(describeChange(name, "open", event)),
    onPayloadChange: (payload: unknown, { event }: Details) =>
      setLastPayload(describeChange(name, `payload ${payload}`, event)),
  })
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Menu {...report("menu")}>
        @for (const label of fixture.menu.triggers; key label) {
          <MenuTrigger payload={payloadOf(label)}>{label}</MenuTrigger>
        }
        <MenuContent className="popup">
          {(state: { payload: unknown }) => (
            <MenuGroup>
              <MenuGroupLabel>{contentFor(state.payload)}</MenuGroupLabel>
              <MenuItem className="item" value="open">
                {fixture.menu.item}
              </MenuItem>
            </MenuGroup>
          )}
        </MenuContent>
      </Menu>
      <Popover controller={people} {...report("popover")}>
        @for (const label of fixture.popover.triggers; key label) {
          <PopoverTrigger payload={payloadOf(label)}>{label}</PopoverTrigger>
        }
        <PopoverContent className="popup">
          {(state: { payload: unknown }) => (
            <>
              {contentFor(state.payload)}
              <button
                onClick={() =>
                  people.open({ payload: fixture.popover.show.payload })
                }
              >
                {fixture.popover.show.label}
              </button>
            </>
          )}
        </PopoverContent>
      </Popover>
      <Dialog modal={false} {...report("dialog")}>
        @for (const label of fixture.dialog.triggers; key label) {
          <DialogTrigger payload={payloadOf(label)}>{label}</DialogTrigger>
        }
        <DialogContent className="dialog">
          {(state: { payload: unknown }) => contentFor(state.payload)}
        </DialogContent>
      </Dialog>
      <Drawer modal={false} {...report("drawer")}>
        @for (const label of fixture.drawer.triggers; key label) {
          <DrawerTrigger payload={payloadOf(label)}>{label}</DrawerTrigger>
        }
        <DrawerContent className="drawer">
          {(state: { payload: unknown }) => contentFor(state.payload)}
        </DrawerContent>
      </Drawer>
      <output role="status" aria-label="Last open">
        {lastOpen}
      </output>
      <output role="status" aria-label="Last payload">
        {lastPayload}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
