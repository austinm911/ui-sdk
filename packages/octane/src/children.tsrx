"use strong"
// Where a root's content part says it's there. Octane can't read a part out
// of the children, so the part tells its root when it mounts, before the page
// paints, even inside a component of the app's own, like a styled
// `SelectContent`.
import * as React from "octane"

const PlacedContext = React.createContext<(() => () => void) | null>(null)

// How many content parts are placed, and whether the root committed. A store,
// so a part mounting re-renders its root through useSyncExternalStore, not a
// state update from an effect.
function placedStore() {
  let count = 0
  let committed = false
  const listeners = new Set<() => void>()
  const notify = () => listeners.forEach((listener) => listener())
  return {
    subscribe(listener: () => void) {
      listeners.add(listener)
      return () => {
        listeners.delete(listener)
      }
    },
    // Whether the root renders its own content part.
    renderOwn: () => committed && count === 0,
    commit() {
      if (!committed) {
        committed = true
        notify()
      }
    },
    register() {
      count++
      notify()
      return () => {
        count--
        notify()
      }
    },
  }
}

/**
 * For a root that renders its own content part when the app places none:
 * whether to render it, and the value of the provider its children go in.
 * Its own part goes in `<Placed value={null}>`, so it doesn't count. Placed
 * parts register as they mount, after the root renders, so the root renders
 * its own only once it committed and none registered. Otherwise both would
 * be in the page for a commit.
 */
function usePlacedContent() {
  const store = React.useInitialValue(placedStore)
  React.useLayoutEffect(() => store.commit())
  const renderOwn = React.useSyncExternalStore(store.subscribe, store.renderOwn)
  return [renderOwn, store.register] as const
}

const Placed = PlacedContext

/** Called by a content part, so its root doesn't render one of its own as well. */
function usePlaceContent() {
  const register = React.useContext(PlacedContext)
  React.useLayoutEffect(() => register?.())
}

export { Placed, usePlaceContent, usePlacedContent }
