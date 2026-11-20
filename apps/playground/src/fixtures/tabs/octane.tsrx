"use strong"
import { createTabsController } from "@ui-sdk/core/tabs"
import {
  Tabs,
  TabsIndicator,
  TabsList,
  TabsPanel,
  TabsTab,
} from "@ui-sdk/octane/tabs"
import * as React from "octane"
import { createRoot } from "octane"
import { tabsOptions } from "tests/fixtures/page.ts"
import { tabsFixture } from "tests/fixtures/tabs.ts"

const controller = createTabsController()

// Each tab's panel, with its field when it has one. A component of its own:
// a keyed @for written beside <TabsList>, whose children hold a @for too,
// renders before the list, so Tab from Before lands on a panel
// (octanejs/octane#3094).
function Panels({ keepMounted }: { keepMounted: boolean }) @{
  @for (const tab of tabsFixture.tabs; key tab.value) {
    <TabsPanel className="panel" value={tab.value} keepMounted={keepMounted}>
      {tab.content}
      @if (tab.field) {
        <label>
          {" "}
          {tab.field} <input type="password" />
        </label>
      }
    </TabsPanel>
  }
}

function Fixture() {
  const [action, setAction] = React.useState("")
  // The page's options, read once, as the page's URL never changes.
  const { cancel, keepMounted, ...options } = React.useInitialValue(tabsOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Tabs
        className="tabs"
        controller={controller}
        {...options}
        onValueChange={(value, details) => {
          if (value === cancel) {
            return details.cancel()
          }
          setAction(value ?? "")
        }}
      >
        <TabsList className="tablist" aria-label={tabsFixture.label}>
          @for (const tab of tabsFixture.tabs; key tab.value) {
            <TabsTab className="tab" value={tab.value} disabled={tab.disabled}>
              {tab.label}
            </TabsTab>
          }
          <TabsIndicator className="indicator" />
        </TabsList>
        <Panels keepMounted={keepMounted} />
      </Tabs>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <button onClick={() => controller.select("notifications")}>
        {"Show notifications"}
      </button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
