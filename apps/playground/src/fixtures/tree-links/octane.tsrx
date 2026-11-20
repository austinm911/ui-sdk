"use strong"
import { Tree } from "@ui-sdk/octane/tree"
import * as React from "octane"
import { createRoot } from "octane"
import { treeLinksFixture } from "tests/fixtures/tree.ts"
import { Items } from "../tree/octane.tsrx"

// The current page: the address's, or the first page until a link changes it.
function addressStore() {
  const store = {
    current: location.hash.slice(1) || "usage",
    subscribe(listener: () => void) {
      const changed = () => {
        store.current = location.hash.slice(1)
        listener()
      }
      window.addEventListener("hashchange", changed)
      return () => window.removeEventListener("hashchange", changed)
    },
    get: () => store.current,
  }
  return store
}

// A tree of links, rendered with the tree fixture's classes. The current page follows the address.
function Fixture() {
  const address = React.useInitialValue(addressStore)
  const current = React.useSyncExternalStore(address.subscribe, address.get)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Tree
        className="tree"
        aria-label={treeLinksFixture.label}
        items={treeLinksFixture.items}
        mode="none"
        current={current}
      >
        <Items items={treeLinksFixture.items} checkable={false} />
      </Tree>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {current}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
