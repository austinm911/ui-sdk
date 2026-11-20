"use strong"
import {
  createDrawerController,
  Drawer,
  DrawerBackdrop,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerHandle,
  DrawerOutlet,
  DrawerShortcut,
  DrawerTitle,
  DrawerTrigger,
} from "@ui-sdk/octane/drawer"
import * as React from "octane"
import { createRoot } from "octane"
import {
  drawerFixture,
  drawerOptions,
  drawerParts,
  exposeDrawerFixture,
  recordDrawer,
} from "tests/fixtures/drawer.ts"

const controller = createDrawerController()
exposeDrawerFixture(controller)

const parts = drawerParts()

function Fixture() {
  const [action, setAction] = React.useState("")
  const [more, setMore] = React.useState(false)
  // The page's options, read once, as the page's URL never changes.
  const options = React.useInitialValue(drawerOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Drawer
        controller={controller}
        {...options}
        onOpenChange={(open, details) =>
          recordDrawer(`drawer:${open}:${details.reason}`)
        }
        onSnapPointChange={(snapPoint, details) =>
          recordDrawer(`${snapPoint}:${details.reason}`)
        }
        onDismissAttempt={(details) =>
          recordDrawer(`attempt:${details.reason}`)
        }
      >
        <DrawerTrigger>{drawerFixture.trigger}</DrawerTrigger>
        @if (parts.backdrop) {
          <DrawerBackdrop className="drawer-backdrop" />
        }
        <DrawerContent className="drawer">
          <DrawerHandle className="handle" aria-label={drawerFixture.handle} />
          <DrawerTitle className="title">{drawerFixture.title}</DrawerTitle>
          <DrawerDescription className="description">
            {drawerFixture.description}
          </DrawerDescription>
          @if (parts.field) {
            <label className="field">
              {drawerFixture.field}
              <input />
            </label>
          }
          @if (parts.scroll) {
            <ul
              className="scroll"
              aria-label={drawerFixture.scroll.label}
              tabIndex={0}
            >
              @for (const item of drawerFixture.scroll.items; key item) {
                <li>{item}</li>
              }
            </ul>
          }
          @if (parts.grow) {
            <>
              <button onClick={() => setMore(true)}>
                {drawerFixture.grow.button}
              </button>
              @if (more) {
                <p className="more">{drawerFixture.grow.text}</p>
              }
            </>
          }
          <div className="actions">
            <button onClick={() => setAction("submit")}>
              {drawerFixture.action}
            </button>
            <DrawerClose>{drawerFixture.close}</DrawerClose>
          </div>
          @if (parts.nested) {
            <Drawer
              onOpenChange={(open, details) =>
                recordDrawer(`nested:${open}:${details.reason}`)
              }
            >
              <DrawerTrigger>{drawerFixture.nested.trigger}</DrawerTrigger>
              @if (parts.backdrop) {
                <DrawerBackdrop className="drawer-backdrop" />
              }
              <DrawerContent className="drawer">
                <DrawerTitle className="title">
                  {drawerFixture.nested.title}
                </DrawerTitle>
                <DrawerClose>{drawerFixture.nested.close}</DrawerClose>
              </DrawerContent>
            </Drawer>
          }
        </DrawerContent>
      </Drawer>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <button onClick={() => controller.open()}>
        {drawerFixture.controller}
      </button>
      <button onClick={() => setAction("page")}>{drawerFixture.page}</button>
      @if (parts.shortcut) {
        <DrawerTrigger
          controller={controller}
          shortcut={drawerFixture.shortcut.keys}
        >
          {`${drawerFixture.shortcut.trigger} `}
          <DrawerShortcut />
        </DrawerTrigger>
      }
      @if (parts.outlet) {
        <DrawerOutlet
          controller={controller}
          className="outlet"
          role="region"
          aria-label={drawerFixture.outlet.label}
          keyframes={drawerFixture.outlet.keyframes}
        />
      }
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
