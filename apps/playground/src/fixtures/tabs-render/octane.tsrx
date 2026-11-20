"use strong"
import { Tabs, TabsList, TabsPanel, TabsTab } from "@ui-sdk/octane/tabs"
import * as React from "octane"
import { createRoot } from "octane"
import { tabsOptions } from "tests/fixtures/page.ts"

const panels = ["overview", "activity", "watched", "plain"]

function Fixture() {
  const [action, setAction] = React.useState("")
  const [reason, setReason] = React.useState("")
  const { activation } = React.useInitialValue(tabsOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Tabs
        className="tabs"
        defaultValue="overview"
        activation={activation}
        onValueChange={(value, details) => {
          setAction(value ?? "")
          setReason(details.reason)
        }}
      >
        <TabsList className="tablist" aria-label="Project">
          <TabsTab
            className="tab"
            value="overview"
            render={(props) => <a href="#overview" {...props} />}
          >
            {"Overview"}
          </TabsTab>
          <TabsTab
            className="tab"
            value="activity"
            render={(props) => <a href="#activity" {...props} />}
          >
            {"Activity"}
          </TabsTab>
          <TabsTab
            className="tab"
            value="watched"
            render={(props, state) => (
              <button {...props}>
                {props.children}
                @if (state.selected) {
                  <span aria-hidden>{" •"}</span>
                }
              </button>
            )}
          >
            {"Watched"}
          </TabsTab>
          <TabsTab
            value="plain"
            className={(state) =>
              `tab ${state.selected ? "is-selected" : "is-unselected"}`
            }
          >
            {"Plain"}
          </TabsTab>
        </TabsList>
        @for (const value of panels; key value) {
          <TabsPanel className="panel" value={value}>
            {`The ${value} panel.`}
          </TabsPanel>
        }
      </Tabs>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <output role="status" aria-label="Reason">
        {reason}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
