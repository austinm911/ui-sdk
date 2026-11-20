"use strong"
import {
  Drawer,
  DrawerBackdrop,
  DrawerClose,
  DrawerContent,
  DrawerTitle,
  DrawerTrigger,
} from "@ui-sdk/octane/drawer"
import * as React from "octane"
import { createRoot } from "octane"
import { drawerOptions } from "tests/fixtures/drawer.ts"
import { perfItems, perfSize } from "tests/fixtures/perf.ts"

// A drawer whose content has many lines, for the counts specs. ?driver picks its driver.
const items = perfItems(perfSize())

function Fixture() {
  // The page's options, read once, as the page's URL never changes.
  const options = React.useInitialValue(drawerOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Drawer {...options}>
        <DrawerTrigger>{"Open"}</DrawerTrigger>
        <DrawerBackdrop className="drawer-backdrop" />
        <DrawerContent className="drawer">
          <DrawerTitle className="title">{"Drawer"}</DrawerTitle>
          @for (const item of items; key item.value) {
            <p>{item.label}</p>
          }
          <DrawerClose>{"Close"}</DrawerClose>
        </DrawerContent>
      </Drawer>
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
