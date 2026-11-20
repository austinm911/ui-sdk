"use strong"
import {
  createTreeController,
  Tree,
  TreeGroup,
  TreeItem,
  TreeItemCheckbox,
  TreeItemIndicator,
  TreeItemLabel,
} from "@ui-sdk/octane/tree"
import * as React from "octane"
import { createRoot } from "octane"
import {
  describeTree,
  treeFixture,
  type TreeFixtureItem,
} from "tests/fixtures/tree.ts"
import { treeOptions } from "tests/fixtures/page.ts"

const controller = createTreeController()

// A label rendered as a link to `href`.
const linkTo = (href: string) => (props: Record<string, any>) => (
  <a href={href} {...props} />
)

function Items({
  items,
  checkable,
}: {
  items: TreeFixtureItem[]
  checkable: boolean
}) @{
  @for (const item of items; key item.value) {
    <TreeItem className="tree-item" value={item.value} disabled={item.disabled}>
      @if (item.children) {
        <TreeItemIndicator className="tree-indicator">{"▸"}</TreeItemIndicator>
      }
      @if (checkable) {
        <TreeItemCheckbox className="tree-checkbox" />
      }
      <TreeItemLabel
        className="tree-label"
        render={item.href ? linkTo(item.href) : undefined}
      >
        {item.label}
      </TreeItemLabel>
      @if (item.children) {
        <TreeGroup className="tree-group">
          <Items items={item.children} checkable={checkable} />
        </TreeGroup>
      }
    </TreeItem>
  }
}

function Fixture() {
  const [action, setAction] = React.useState("")
  const { cancel, ...options } = React.useInitialValue(treeOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Tree
        className="tree"
        aria-label={treeFixture.label}
        controller={controller}
        {...options}
        onValueChange={(value) => setAction(describeTree("selected", value))}
        onExpandedChange={(expanded, details) => {
          if (
            cancel &&
            expanded.includes(cancel) &&
            !controller.isExpanded(cancel)
          ) {
            return details.cancel()
          }
          setAction(describeTree("expanded", expanded))
        }}
        onCheckedChange={(checked) =>
          setAction(describeTree("checked", checked))
        }
        onAction={(value) => setAction(describeTree("action", value))}
      >
        <Items items={treeFixture.items} checkable={options.checkable} />
      </Tree>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <button onClick={() => controller.expandAll()}>{"Expand all"}</button>
      <button onClick={() => controller.collapseAll()}>{"Collapse all"}</button>
      <button onClick={() => controller.reveal("dialog.tsx")}>
        {"Reveal dialog"}
      </button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, Items, mount }
